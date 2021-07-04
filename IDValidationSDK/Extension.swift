//
//  Extension.swift
//  IDValidationSDK
//
//  Created by Iskandar Parpiev on 17/06/21.
//

import Foundation
import UIKit

extension NSObject {
    class func fromJson(_ jsonInfo: NSDictionary) -> Self {
        let object = self.init()
        
        return object
    }
    

    
    func propertyNames() -> [String] {
        var names: [String] = []
        var count: UInt32 = 0
        let properties = class_copyPropertyList(classForCoder, &count)
        for i in 0 ..< Int(count) {
            let property: objc_property_t = properties![i]
            let name: String = String(cString: property_getName(property))
            names.append(name)
        }
        free(properties)
        return names
    }
    
    func asJson() -> NSDictionary {
        var json:Dictionary<String, AnyObject> = [:]
        
        for name in propertyNames() {
            if let value: AnyObject = value(forKey: name) as AnyObject? {
                json[name] = value
            }
        }
        
        
        return json as NSDictionary
    }
}




// MARK: - Properties

public extension UIView {
    
    /// Size of view.
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
    
    /// Width of view.
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    /// Height of view.
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    
    func showHUD(_ title:String="Loading", subTitle: String)  {
        HUDController.sharedController.contentView = HUDContentView.ProgressStatusView(title: title, subtitle: subTitle)
        HUDController.sharedController.show()
    }
    
    func showSuccessHUD(_ title:String="Loading", subTitle: String, _ isShowSuccess:Bool = false)  {
        if isShowSuccess == true{
            HUDController.sharedController.contentView = HUDContentView.StatusView(title: title, subtitle: subTitle, image: HUDAssets.checkmarkImage)
            HUDController.sharedController.show()
            HUDController.sharedController.hide(afterDelay: 3)
        }else{
            HUDController.sharedController.hideAnimated()
        }
        
    }
    
//    func showErrorHUD(_ error:MDErrorModel, title:String="Error Occured")  {
//        HUDController.sharedController.contentView = HUDContentView.StatusView(
//                title:title,
//                subtitle: error.message,
//                image: HUDAssets.crossImage)
//        
//        HUDController.sharedController.show()
//        HUDController.sharedController.hide(afterDelay: 2.0)
//    }
    
    
}


public extension String{

    
    func localize() ->  String {
        return NSLocalizedString(self, comment: "")
    }
}
extension UIViewController{
    
    func getNavigationTitleViewNew(title: String) -> UILabel{
        let  titleView: UILabel = UILabel(frame: CGRect())
        // titleView.backgroundColor = UIColor.red
        titleView.font = UIFont.systemFont(ofSize: 20)
        titleView.textColor = UIColor.white
        titleView.text = title;
        titleView.sizeToFit()
        titleView.textAlignment = .left
        
        return titleView
    }
    
    func changeNavigationTitleView(_ title: String) ->  Void{
        if let titleV =  self.navigationItem.titleView as? UILabel {
            titleV.text = title
            titleV.sizeToFit()
        }else{
            self.navigationItem.titleView = self.getNavigationTitleViewNew(title: title)
        }
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 110, y: kPortraitHeight/2 - 100, width: 220, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.2, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
}
extension  UserDefaults{
    
    class func objectForKey(_ defaultName: String) -> AnyObject?{
        return UserDefaults.standard.object(forKey: defaultName) as AnyObject?
    }
    
    class func stringForKey(_ defaultName: String) -> String?{
        return UserDefaults.standard.string(forKey: defaultName)
    }
    
    class func setObject(_ value:Any, forKey: String) -> Void{
        UserDefaults.standard.set(value, forKey: forKey)
        UserDefaults.standard.synchronize()
    }
    
    class func removeObjectForKey(_ defaultName: String) -> Void{
        UserDefaults.standard.removeObject(forKey: defaultName)
        UserDefaults.standard.synchronize()
    }
    
    
}
