//
//  UIColorExtensions.swift
//  Medyear
//
//  Created by Admin on 12/19/14.
//  Copyright (c) 2014 Personiform. All rights reserved.
//

import Foundation
import UIKit


extension UIColor{
    
    
    static var themeYellow: UIColor{
        get { return UIColor(hexStr: "#ffca28")}
    }
    static var themeGreyBtn: UIColor{
        get { return UIColor(hexStr: "#9ea7b0")}
    }
    
    static var themeLightGrey: UIColor{
        get { return UIColor(hexStr: "#E5E7EA")}
    }
    
    static var themeBlue: UIColor{
        get { return UIColor(hexStr: "#0073ff")}
    }
    static var themeDarkBlue: UIColor{
        get { return UIColor(hexStr: "#021930")}
    }
    static var themeGreen: UIColor{
        get { return UIColor(hexStr: "#4CAF50")}
    }
    static var themeBG: UIColor{
        get { return UIColor(hexStr: "#F6F7F8")}
    }
    static var themeBtn: UIColor{
        get { return UIColor(hexStr: "#F2F3F4")}
    }
    static var themeIconsColor: UIColor{
        get { return UIColor(hexStr: "#677582")}
    }
    static var placeHolderColor: UIColor{
        get { return UIColor(hexStr: "##212121")}
    }
    static var titleTextFiledColor: UIColor{
        get { return UIColor(hexStr: "##757575")}
    }
    static var themeWhite50: UIColor{
        get { return UIColor(hexStr: "#ffffff").withAlphaComponent(0.5)}
    }
    static var themeOrange2: UIColor{
        get {return UIColor(hexStr: "#ff8b00")}
    }
    static var themeOrange: UIColor{
        get { return UIColor(hexStr: "#FFB300")}
    }
    
    static var themeRed: UIColor{
        get { return UIColor(hexStr: "#E53935")}
    }
    
    convenience init(hexStr: String) {
        let hex = hexStr.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    
//
    class func colorWithRGB(r red:CGFloat, g green:CGFloat, b blue:CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

   
    class func updatesHeaderBgColor() -> UIColor{
        return self.colorWithRGB(r: 83.0, g: 132.0, b: 187.0)
    }

}

