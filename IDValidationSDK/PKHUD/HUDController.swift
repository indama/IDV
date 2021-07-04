//
//  HUD.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/13/14.
//  Copyright (c) 2014 NSExceptional. All rights reserved.
//

import UIKit

/**
  HUDController controls showing and hiding of the HUD, as well as its contents and touch response behavior.
  It is recommended to use the PKHUD.Controller.sharedController instance, nevertheless you are free to instantiate your own.
*/
open class HUDController: NSObject {
    fileprivate struct Constants {
        static let sharedController = HUDController()
    }
    
    fileprivate let window = Window()
    
    open class var sharedController: HUDController {
        return Constants.sharedController
    }
    
    public override init () {
        super.init()
        userInteractionOnUnderlyingViewsEnabled = false
        window.frameView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    open var dimsBackground = true
    open var userInteractionOnUnderlyingViewsEnabled: Bool {
        get {
            return !window.isUserInteractionEnabled
        }
        set {
            window.isUserInteractionEnabled = !newValue
        }
    }
    
    open var contentView: UIView {
        get {
            return window.frameView.content
        }
        set {
            window.frameView.content = newValue
        }
    }
    
    open func show() {
        window.showFrameView()
        if dimsBackground {
            window.showBackground(animated: true)
        }
    }
    
    open func hide(animated anim: Bool = true) {
        window.hideFrameView(animated: anim)
        if dimsBackground {
            window.hideBackground(animated: true)
        }
    }
    
    fileprivate var hideTimer: Timer?
    open func hide(afterDelay delay: TimeInterval) {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(HUDController.hideAnimated), userInfo: nil, repeats: false)
    }
    
    // MARK: Helper
    
    @objc internal func hideAnimated() -> Void {
        hide(animated: true)
    }
    
    func setWindowLevel(_ level: UIWindow.Level) -> Void {
        self.window.windowLevel = level
    }
}
