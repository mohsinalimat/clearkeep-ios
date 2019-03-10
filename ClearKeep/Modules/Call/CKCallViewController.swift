//
//  CKCallingViewController.swift
//  Riot
//
//  Created by Pham Hoa on 2/2/19.
//  Copyright © 2019 matrix.org. All rights reserved.
//

import Foundation

final class CKCallViewController: CallViewController {
    
    private let maxCallControlItemWidth: CGFloat = 55
    private let minCallControlsSpacing: CGFloat = 10
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: CKCallViewController.nibName, bundle: Bundle.init(for: CKCallViewController.self))
    }
    
    @IBOutlet weak var callControlContainerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roundButtons()
    }
    
    func roundButtons() {
        roundView(viewBoder: audioMuteButton)
        roundView(viewBoder: videoMuteButton)
        roundView(viewBoder: speakerButton)
        roundView(viewBoder: chatButton)
        roundView(viewBoder: endCallButton)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update layout
        let screenWidth = UIScreen.main.bounds.size.width
        let controlItemsCount: CGFloat = 5
        let minTotlaSpacing = (controlItemsCount + 1.0) * minCallControlsSpacing
        let maxAbleControlItemWidth = (screenWidth - minTotlaSpacing) / controlItemsCount
        
        if maxCallControlItemWidth > maxAbleControlItemWidth {
            self.callControlContainerHeightConstraint.constant = maxAbleControlItemWidth
        } else {
            self.callControlContainerHeightConstraint.constant = maxCallControlItemWidth
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func roundView(viewBoder: UIView, color: UIColor = CKColor.Background.primaryGreenColor) {
        viewBoder.backgroundColor = UIColor(white: 1, alpha: 0.35)
        viewBoder.layer.borderWidth = 1
        viewBoder.layer.borderColor = color.cgColor
        viewBoder.layer.cornerRadius = (viewBoder.bounds.height)/2
        viewBoder.layer.masksToBounds = true        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.roundButtons()
    }
    
    override func startActivityIndicator() {
        // TODO: Temporary fixing
    }
    
    override func call(_ call: MXCall, didEncounterError error: Error?) {
        
        guard let nsError = error as NSError? else {
            return
        }
        
        if nsError._domain == MXEncryptingErrorDomain && nsError._code == Int(MXEncryptingErrorUnknownDeviceCode.rawValue) {
            // There are unknown devices -> call anyway

            let unknownDevices = nsError.userInfo[MXEncryptingErrorUnknownDeviceDevicesKey] as? MXUsersDevicesMap<MXDeviceInfo>

            // Acknowledge the existence of all devices
            
            self.mainSession?.crypto?.setDevicesKnown(unknownDevices) {
                
                // Retry the call
                if call.isIncoming {
                    call.answer()
                } else {
                    call.call(withVideo: call.isVideoCall)
                }
            }
        } else {
            super.call(call, didEncounterError: error!)
        }
    }
    
    override func onButtonPressed(_ sender: Any!) {
        let sender = sender as? UIButton
        super.onButtonPressed(sender)
    }
    
}