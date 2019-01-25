//
//  CameraCollectionViewCell.swift
//  Image Picker
//
//  Created by Peter Stajger on 08/09/2017.
//  Copyright © 2017 Inloop. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol CameraCollectionViewCellDelegate : class {
    func takePicture()
    func takeLivePhoto()
    func startVideoRecording()
    func stopVideoRecording()
    func flipCamera(_ completion: (() -> Void)?)
}

///
/// Each custom camera cell must inherit from this base class.
///
open class CameraCollectionViewCell : UICollectionViewCell {

    deinit {
        log("deinit: \(String(describing: self))")
    }
    
    /// contains video preview layer
    var previewView: AVPreviewView = {
        let view = AVPreviewView(frame: .zero)
        view.backgroundColor = UIColor.black
        return view
    }()
    
    ///
    /// holds static image that is above blur view to achieve nicer presentation
    /// - note: when capture session is interrupted, there is no input stream so
    /// output is black, adding image here will nicely hide this black background
    ///
    var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    var blurView: UIVisualEffectView?
    
    var isVisualEffectViewUsedForBlurring = false
    
    weak var delegate: CameraCollectionViewCellDelegate?
    
    // MARK: View Lifecycle Methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView = previewView
        previewView.addSubview(imageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundView = previewView
        previewView.addSubview(imageView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = previewView.bounds
        blurView?.frame = previewView.bounds
    }
    
    // MARK: Public Methods
    
    ///
    /// The cell can have multiple visual states based on autorization status. Use
    /// `updateCameraAuthorizationStatus()` func to udate UI.
    ///
    public internal(set) var authorizationStatus: AVAuthorizationStatus? {
        didSet { updateCameraAuthorizationStatus() }
    }
    
    ///
    /// Called each time an authorization status to camera is changed. Update your
    /// cell's UI based on current value of `authorizationStatus` property.
    ///
    open func updateCameraAuthorizationStatus() {
        
    }
    
    ///
    /// If live photos are enabled this method is called each time user captures
    /// a live photo. Override this method to update UI based on live view status.
    ///
    /// - parameter isProcessing: If there is at least 1 live photo being processed/captured
    /// - parameter shouldAnimate: If the UI change should be animated or not.
    ///
    open func updateLivePhotoStatus(isProcessing: Bool, shouldAnimate: Bool) {
        
    }
    
    ///
    /// If video recording is enabled this method is called each time user starts or stops
    /// a recording. Override this method to update UI based on recording status.
    ///
    /// - parameter isRecording: If video is recording or not
    /// - parameter shouldAnimate: If the UI change should be animated or not.
    ///
    open func updateRecordingVideoStatus(isRecording: Bool, shouldAnimate: Bool) {
    
    }
    
    open func videoRecodingDidBecomeReady() {
        
    }
    
    ///
    /// Flips camera from front/rear or rear/front. Flip is always supplemented with
    /// an flip animation.
    ///
    /// - parameter completion: A block is called as soon as camera is changed.
    ///
    @objc public func flipCamera(_ completion: (() -> Void)? = nil) {
        delegate?.flipCamera(completion)
    }
    
    ///
    /// Takes a picture
    ///
    @objc public func takePicture() {
        delegate?.takePicture()
    }
    
    ///
    /// Takes a live photo. Please note that live photos must be enabled when configuring Image Picker.
    ///
    @objc public func takeLivePhoto() {
        delegate?.takeLivePhoto()
    }
    
    @objc public func startVideoRecording() {
        delegate?.startVideoRecording()
    }
    
    @objc public func stopVideoRecording() {
        delegate?.stopVideoRecording()
    }
    
    // MARK: Internal Methods
    
    func blurIfNeeded(blurImage: UIImage?, animated: Bool, completion: ((Bool) -> Void)?) {
        
        var view: UIView
        
        if isVisualEffectViewUsedForBlurring == false {
        
            guard imageView.image == nil else {
                return
            }
            
            imageView.image = blurImage
            
            view = imageView
        }
        else {
            
            if blurView == nil {
                blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                previewView.addSubview(blurView!)
            }
            
            view = blurView!
            view.frame = previewView.bounds
        }
        
        view.alpha = 0

        if animated == false {
            view.alpha = 1
            completion?(true)
        }
        else {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowAnimatedContent, animations: {
                view.alpha = 1
            }, completion: completion)
        }
    }
    
    func unblurIfNeeded(unblurImage: UIImage?, animated: Bool, completion: ((Bool) -> Void)?) {
        
        var animationBlock: () -> ()
        var animationCompletionBlock: (Bool) -> ()
        
        if isVisualEffectViewUsedForBlurring == false {
        
            guard imageView.image != nil else {
                return
            }
            
            if let image = unblurImage {
                imageView.image = image
            }
            
            animationBlock = {
                self.imageView.alpha = 0
            }
            
            animationCompletionBlock = { finished in
                self.imageView.image = nil
                completion?(finished)
            }
        }
        else {
            
            animationBlock = {
                self.blurView?.alpha = 0
            }
            
            animationCompletionBlock = { finished in
                completion?(finished)
            }
        }

        if animated == false {
            animationBlock()
            animationCompletionBlock(true)
        }
        else {
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowAnimatedContent, animations: animationBlock, completion: animationCompletionBlock)
        }
    }
    
    ///
    /// When user taps a camera cell this method is called and the result is
    /// used when determining whether the tap should take a photo or not. This
    /// is used when user taps on a button so the button is triggered not the touch.
    ///
    func touchIsCaptureEffective(point: CGPoint) -> Bool {
        // find the topmost view that detected the touch at point and check if it's not any button or anything other than contentView
        if bounds.contains(point), let testedView = hitTest(point, with: nil), testedView === contentView {
            return true
        }
        return false
    }
 
    
}
