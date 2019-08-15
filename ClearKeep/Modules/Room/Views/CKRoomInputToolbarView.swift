//
//  CKRoomInputToolbarView.swift
//  Riot
//
//  Created by Pham Hoa on 1/18/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import UIKit
import HPGrowingTextView
import MobileCoreServices
import GBDeviceInfo

@objc protocol CKRoomInputToolbarViewDelegate: MXKRoomInputToolbarViewDelegate {
    func roomInputToolbarView(_ toolbarView: MXKRoomInputToolbarView?, triggerMention: Bool, mentionText: String?)
}

enum RoomInputToolbarViewSendMode: Int {
    case send
    case reply
    case edit
}

final class CKRoomInputToolbarView: MXKRoomInputToolbarViewWithHPGrowingText {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mainToolbarMinHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainToolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainToolbarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var sendImageButton: UIButton!
    @IBOutlet weak var mentionButton: UIButton!

    // MARK: - Enums
    
    enum MessageContentType {
        case text(msg: String?)
        case photo(asset: PHAsset?)
        case file(url: URL?)
    }
    
    // MARK: - Constants
    
    
    // MARK: - Properties
    
    static let mentionTriggerCharacter: Character = "@"

    static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    // MARK: Public
    
    var growingTextView: HPGrowingTextView? {
        get {
            return self.value(forKey: "growingTextView") as? HPGrowingTextView
        }
        set {
            self.setValue(growingTextView, forKey: "growingTextView")
        }
    }
    
    var maxNumberOfLines: Int32 = 3 {
        didSet {
            self.growingTextView?.maxNumberOfLines = maxNumberOfLines
            self.growingTextView?.refreshHeight()
        }
    }
    
    /**
     Destination of the message in the composer.
     */
    var sendMode: RoomInputToolbarViewSendMode = .send {
        didSet {
            self.updatePlaceholder()
            self.updateToolbarButtonLabel() 
        }
    }

    
    // MARK: Private
    
    private var shadowTextView: UITextView = UITextView.init()
    
    private weak var ckDelegate: CKRoomInputToolbarViewDelegate? {
        get {
            return self.delegate as? CKRoomInputToolbarViewDelegate
        }
        set {
            self.delegate = newValue
        }
    }
    
    private var typingMessage: MessageContentType = .text(msg: nil) {
        didSet {
            switch typingMessage {
            case .text(msg: let msg):
                self.updateSendButton(enable: (msg?.count ?? 0) > 0)
                self.updateSendImageButton(highlight: false)
            case .photo(asset: let asset):
                self.updateSendButton(enable: asset != nil)
                self.updateSendImageButton(highlight: true)
            case .file(url: let url):
                self.updateSendButton(enable: url != nil)
                self.updateSendImageButton(highlight: false)
            }
        }
    }
    
    /**
     Current media picker
     */
    private var mediaPicker: UIImagePickerController?
    
    // MARK: - LifeCycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(shadowTextView)
        shadowTextView.delegate = self
        
        maxNumberOfLines = 3
        typingMessage = .text(msg: nil)
        
        mentionButton.setImage(#imageLiteral(resourceName: "ic_tagging").withRenderingMode(.alwaysTemplate), for: .normal)
        sendImageButton.setImage(#imageLiteral(resourceName: "ic_send_image_enabled").withRenderingMode(.alwaysTemplate), for: .normal)
        mentionButton.tintColor = themeService.attrs.secondTextColor
        sendImageButton.tintColor = themeService.attrs.secondTextColor
    }
    
    override class func nib() -> UINib? {
        return UINib.init(
            nibName: String(describing: CKRoomInputToolbarView.self),
            bundle: Bundle(for: self))
    }

    class func initRoomInputToolbarView() -> CKRoomInputToolbarView {
        if self.nib() != nil {
            return self.nib()?.instantiate(withOwner: nil, options: nil).first as! CKRoomInputToolbarView
        } else {
            return super.init() as! CKRoomInputToolbarView
        }
    }
    
    override func customizeRendering() {
        super.customizeRendering()
        
        // Remove default toolbar background color
        backgroundColor = UIColor.clear
        
        separatorView?.backgroundColor = kRiotAuxiliaryColor
        
        // Custom the growingTextView display
        growingTextView?.layer.cornerRadius = 0
        growingTextView?.layer.borderWidth = 0
        growingTextView?.backgroundColor = UIColor.clear

        growingTextView?.font = UIFont.systemFont(ofSize: 15)
        growingTextView?.textColor = kRiotPrimaryTextColor
        growingTextView?.tintColor = kRiotColorGreen
        
        growingTextView?.internalTextView?.keyboardAppearance = kRiotKeyboard
        growingTextView?.placeholder = "Type a Message"
    }
    
    override func onTouchUp(inside button: UIButton!) {
        if button == self.rightInputToolbarButton {
            switch typingMessage {
            case .text(msg: let msg):
                if let msg = msg {
                    self.sendText(message: msg)
                }
            case .photo(asset: let asset):
                self.addImagePickerAsInputView(false)
                if let asset = asset {
                    self.sendSelectedAssets([asset], with: MXKRoomInputToolbarCompressionModePrompt)
                }
            case .file(url: _):
                break
            }
        } else {
            super.onTouchUp(inside: button)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func clickedOnMentionButton(_ sender: Any) {
        if growingTextView?.isFirstResponder() != true {
            growingTextView?.becomeFirstResponder()
        }
        
        if var selectedRange = growingTextView?.selectedRange {
            let firstHalfString = (growingTextView?.text as NSString?)?.substring(to: selectedRange.location)
            let secondHalfString = (growingTextView?.text as NSString?)?.substring(from: selectedRange.location)

            let insertingString = String.init(CKRoomInputToolbarView.mentionTriggerCharacter)

            growingTextView?.text = "\(firstHalfString ?? "")\(insertingString)\(secondHalfString ?? "")"
            selectedRange.location += insertingString.count
            growingTextView?.selectedRange = selectedRange
        }
    }
        
    @IBAction func clickedOnShareImageButton(_ sender: Any) {
        if self.growingTextView?.isFirstResponder() != true && self.shadowTextView.isFirstResponder != true {
            shadowTextView.becomeFirstResponder()
            
            // delay for showing keyboard completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.addImagePickerAsInputView(true)
            }
        } else {
            if !shadowTextView.isFirstResponder {
                shadowTextView.becomeFirstResponder()

                self.addImagePickerAsInputView(true)
            }
        }
    }
    
    // MARK: - Private functions

//    func setSendMode(sendMode: RoomInputToolbarViewSendMode) {
//        self.sendMode = sendMode
//        
//        self.updatePlaceholder()
//        self.updateToolbarButtonLabel()
//    }
    
    func updatePlaceholder() {
        // Consider the default placeholder
        var placeholder = ""
        
        // Check the device screen size before using large placeholder
        let shouldDisplayLargePlaceholder = GBDeviceInfo.deviceInfo()?.family == .familyiPad || GBDeviceInfo.deviceInfo()?.displayInfo.display.rawValue ?? 0 >= GBDeviceDisplay.display4p7Inch.rawValue
//        [GBDeviceInfo deviceInfo].family == GBDeviceFamilyiPad || [GBDeviceInfo deviceInfo].displayInfo.display >= GBDeviceDisplay4p7Inch;
        if !shouldDisplayLargePlaceholder {
            switch self.sendMode {
            case .reply:
                placeholder = CKLocalization.string(byKey: "room_message_reply_to_short_placeholder")
                break
            default:
                placeholder = CKLocalization.string(byKey: "room_message_short_placeholder")
                break
            }
        } else {
            switch self.sendMode {
            case .reply:
                placeholder = CKLocalization.string(byKey: "encrypted_room_message_reply_to_placeholder")
                break
            default:
                placeholder = CKLocalization.string(byKey: "encrypted_room_message_placeholder")
                break
            }
        }
        self.placeholder = placeholder;
    }
    
    func updateToolbarButtonLabel() {
        var title = ""
        
        switch self.sendMode {
        case .reply:
            title = CKLocalization.string(byKey: "room_action_reply")
            break;
        case .edit:
            title = CKLocalization.string(byKey: "save")
            break;
        default:
            title = CKLocalization.string(byKey: "send")
            break;
        }
        
        self.rightInputToolbarButton.setTitle(title, for: .normal)
        self.rightInputToolbarButton.setTitle(title, for: .highlighted)
    }
}

// MARK: - Private functions

private extension CKRoomInputToolbarView {
    func triggerMentionUser(_ flag: Bool, text: String?) {
        ckDelegate?.roomInputToolbarView(self, triggerMention: flag, mentionText: text)
    }
    
    func addImagePickerAsInputView(_ adding: Bool) {
        if adding {
            // create new instance
            let imagePicker = ImagePickerController()
            
            // set data source and delegate
            imagePicker.delegate = self
            imagePicker.dataSource = self
            
            imagePicker.layoutConfiguration.showsFirstActionItem = true
            imagePicker.layoutConfiguration.showsSecondActionItem = true
            imagePicker.layoutConfiguration.showsCameraItem = true
            
            // number of items in a row (supported values > 0)
            imagePicker.layoutConfiguration.numberOfAssetItemsInRow = 2
            
            imagePicker.captureSettings.cameraMode = .photo
            
            // save capture assets to photo library?
            imagePicker.captureSettings.savesCapturedPhotosToPhotoLibrary = true
            
            imagePicker.collectionView.allowsMultipleSelection = false
            
            // presentation
            // before we present VC we can ask for authorization to photo library,
            // if we dont do it now, Image Picker will ask for it automatically
            // after it's presented.
            PHPhotoLibrary.requestAuthorization({ [unowned self] (_) in
                DispatchQueue.main.async {
                    imagePicker.layoutConfiguration.scrollDirection = .horizontal
                    
                    //if you want to present view as input view, you have to set flexible height
                    //to adopt natural keyboard height or just set an layout constraint height
                    //for specific height.
                    imagePicker.view.autoresizingMask = .flexibleHeight
                    self.shadowTextView.inputView = imagePicker.view
                    self.shadowTextView.reloadInputViews()
                    self.typingMessage = .photo(asset: nil)
                }
            })
        } else {
            self.shadowTextView.inputView = nil
            self.shadowTextView.reloadInputViews()
            self.typingMessage = .text(msg: textMessage)
            
            if self.shadowTextView.isFirstResponder {
                self.growingTextView?.becomeFirstResponder()
            }
        }
    }
    
    func getImageData(asset: PHAsset) -> Data? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        
        var imageData: Data?
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            imageData = data
        }
        return imageData
    }
    
    func getUIImage(asset: PHAsset) -> UIImage? {
        var img: UIImage?
        if let data = self.getImageData(asset: asset) {
            img = UIImage(data: data)
        }
        return img
    }
    
    func sendText(message: String) {
        // Reset message, disable view animation during the update to prevent placeholder distorsion.
        UIView.setAnimationsEnabled(false)
        textMessage = nil
        UIView.setAnimationsEnabled(true)

        // Send button has been pressed
        if message.count > 0 {
            ckDelegate?.roomInputToolbarView?(self, sendTextMessage: message)
        }
    }
    
    func updateSendButton(enable: Bool) {
        self.rightInputToolbarButton.isEnabled = enable
        
        if enable {
            self.rightInputToolbarButton.backgroundColor = CKColor.Misc.primaryGreenColor
            self.rightInputToolbarButton.borderWidth = 0
            self.rightInputToolbarButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.rightInputToolbarButton.backgroundColor = UIColor.clear
            self.rightInputToolbarButton.borderWidth = 1
            self.rightInputToolbarButton.borderColor = CKColor.Misc.borderColor
            self.rightInputToolbarButton.setTitleColor(CKColor.Text.darkGray, for: .normal)
        }
    }
    
    func updateSendImageButton(highlight: Bool) {
        if highlight {
            sendImageButton.theme.tintColor = themeService.attrStream{ $0.primaryTextColor }
        } else {
            sendImageButton.theme.tintColor = themeService.attrStream{ $0.secondTextColor }
        }
    }
    
    func detectTagging(_ growingTextView: HPGrowingTextView!) {
        let firstHalfString = (growingTextView.text as NSString?)?.substring(to: growingTextView.selectedRange.location)
        
        if firstHalfString?.contains(String.init(CKRoomInputToolbarView.mentionTriggerCharacter)) == true {
            let mentionComponents = firstHalfString?.components(separatedBy: String.init(CKRoomInputToolbarView.mentionTriggerCharacter))
            let currentMentionComponent = mentionComponents?.last
            
            if let currentMentionComponent = currentMentionComponent,
                !currentMentionComponent.contains(" ") {
                triggerMentionUser(true, text: currentMentionComponent)
            } else {
                triggerMentionUser(false, text: nil)
            }
        } else {
            triggerMentionUser(false, text: nil)
        }
    }
}

// MARK: - UITextViewDelegate

extension CKRoomInputToolbarView: UITextViewDelegate {
    // handle for shadow textview
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.addImagePickerAsInputView(false)
    }
}

// MARK: - HPGrowingTextView Delegate

extension CKRoomInputToolbarView {
    
    override func growingTextViewDidEndEditing(_ growingTextView: HPGrowingTextView!) {
        super.growingTextViewDidEndEditing(growingTextView)
        
        self.addImagePickerAsInputView(false)
    }
    
    override func growingTextViewDidChange(_ growingTextView: HPGrowingTextView!) {
        // Clean the carriage return added on return press
        if (textMessage == "\n") {
            textMessage = nil
        }
        
        super.growingTextViewDidChange(growingTextView)
        self.typingMessage = .text(msg: textMessage)

        self.detectTagging(growingTextView)
    }
    
    override func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        // Update height of the main toolbar (message composer)
        var updatedHeight: CGFloat = CGFloat(height) + (messageComposerContainerTopConstraint.constant + messageComposerContainerBottomConstraint.constant)

        if updatedHeight < mainToolbarMinHeightConstraint.constant {
            updatedHeight = mainToolbarMinHeightConstraint.constant
        }
        
        mainToolbarHeightConstraint.constant = updatedHeight
        
        self.delegate?.roomInputToolbarView?(self, heightDidChanged: updatedHeight, completion: { (_) in
            //
        })
    }
    
    override func growingTextView(_ growingTextView: HPGrowingTextView!, shouldChangeTextIn range: NSRange, replacementText text: String!) -> Bool {
        return true
    }
    
    override func growingTextViewDidChangeSelection(_ growingTextView: HPGrowingTextView!) {
        self.detectTagging(growingTextView)
    }
}

// MARK: - ImagePickerControllerDelegate

extension CKRoomInputToolbarView : ImagePickerControllerDelegate {
    
    public func imagePicker(controller: ImagePickerController, didSelectActionItemAt index: Int) {
        print("did select action \(index)")
        
        if index == 0 && UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.mediaPicker = UIImagePickerController()
            self.mediaPicker?.delegate = self
            self.mediaPicker?.sourceType = .camera
            self.mediaPicker?.allowsEditing = true
            
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                self.mediaPicker?.mediaTypes = mediaTypes
            }
            
            self.endEditing(true)
            self.ckDelegate?.roomInputToolbarView?(self, present: mediaPicker)
        }
        else if index == 1 && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.mediaPicker = UIImagePickerController()
            self.mediaPicker?.delegate = self
            self.mediaPicker?.sourceType = .photoLibrary
            
            self.endEditing(true)
            self.ckDelegate?.roomInputToolbarView?(self, present: self.mediaPicker)
        }
    }
    
    public func imagePicker(controller: ImagePickerController, didSelect asset: PHAsset) {
        print("selected assets: \(controller.selectedAssets.count)")
        self.typingMessage = .photo(asset: asset)
    }
    
    public func imagePicker(controller: ImagePickerController, didDeselect asset: PHAsset) {
        print("selected assets: \(controller.selectedAssets.count)")
    }
    
    public func imagePicker(controller: ImagePickerController, didTake image: UIImage) {
        print("did take image \(image.size)")
    }
    
    func imagePicker(controller: ImagePickerController, willDisplayActionItem cell: UICollectionViewCell, at index: Int) {
        switch cell {
        case let iconWithTextCell as IconWithTextCell:
            iconWithTextCell.titleLabel.textColor = UIColor.black
            switch index {
            case 0:
                iconWithTextCell.titleLabel.text = "Camera"
                iconWithTextCell.imageView.image = #imageLiteral(resourceName: "button-camera")
            case 1:
                iconWithTextCell.titleLabel.text = "Photos"
                iconWithTextCell.imageView.image = #imageLiteral(resourceName: "button-photo-library")
            default: break
            }
        default:
            break
        }
    }
    
    func imagePicker(controller: ImagePickerController, willDisplayAssetItem cell: ImagePickerAssetCell, asset: PHAsset) {
        switch cell {
            
        case let videoCell as CustomVideoCell:
            videoCell.label.text = CKRoomInputToolbarView.durationFormatter.string(from: asset.duration)
        case let imageCell as CustomImageCell:
            if asset.mediaSubtypes.contains(.photoLive) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-live")
            }
            else if asset.mediaSubtypes.contains(.photoPanorama) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-pano")
            }
            else if #available(iOS 10.2, *), asset.mediaSubtypes.contains(.photoDepthEffect) {
                imageCell.subtypeImageView.image = #imageLiteral(resourceName: "icon-depth")
            }
        default:
            break
        }
    }
    
}

// MARK: - ImagePickerControllerDataSource

extension CKRoomInputToolbarView: ImagePickerControllerDataSource {
    
    func imagePicker(controller: ImagePickerController, viewForAuthorizationStatus status: PHAuthorizationStatus) -> UIView {
        let infoLabel = UILabel(frame: .zero)
        infoLabel.backgroundColor = UIColor.green
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        switch status {
        case .restricted:
            infoLabel.text = "Access is restricted\n\nPlease open Settings app and update privacy settings."
        case .denied:
            infoLabel.text = "Access is denied by user\n\nPlease open Settings app and update privacy settings."
        default:
            break
        }
        return infoLabel
    }
    
}

// MARK: - Override UIImagePickerControllerDelegate

extension CKRoomInputToolbarView {
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if self.mediaPicker != nil {
            self.mediaPicker?.dismiss(animated: true, completion: nil)
        }

        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == kUTTypeImage as String {
                if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    // Media picker does not offer a preview
                    // so add a preview to let the user validates his selection
                    if picker.sourceType == .photoLibrary {
                        
                        guard let asset = info[UIImagePickerControllerPHAsset] as? PHAsset else { return }

                        let options = PHContentEditingInputRequestOptions()
                        options.isNetworkAccessAllowed = true //for icloud backup assets
                        
                        asset.requestContentEditingInput(with: options) { [weak self] (contentEditingInput, info) in
                            if let uniformTypeIdentifier = contentEditingInput?.uniformTypeIdentifier {
                                print(uniformTypeIdentifier)
                                
                                let mimetype = UTTypeCopyPreferredTagWithClass(uniformTypeIdentifier as CFString, kUTTagClassMIMEType)?.takeRetainedValue() as String?
                                if let mimetype = mimetype, let imageData = self?.getImageData(asset: asset) {
                                    self?.sendSelectedImage(imageData, withMimeType: mimetype, andCompressionMode: MXKRoomInputToolbarCompressionModePrompt, isPhotoLibraryAsset: true)
                                }
                            }
                        }
                    } else {
                        // Suggest compression before sending image
                        let imageData = UIImageJPEGRepresentation(selectedImage, 0.9)
                        sendSelectedImage(imageData, withMimeType: nil, andCompressionMode: MXKRoomInputToolbarCompressionModePrompt, isPhotoLibraryAsset: false)
                    }
                }
            }
            else if mediaType == kUTTypeMovie as String {
                let selectedVideo = info[UIImagePickerControllerMediaURL] as? URL
                sendSelectedVideo(selectedVideo, isPhotoLibraryAsset: (picker.sourceType == UIImagePickerController.SourceType.photoLibrary))
            }
        }

    }
    
    override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if self.mediaPicker != nil {
            self.mediaPicker?.dismiss(animated: true, completion: nil)
        }
    }
}
