//
//  Colors.swift
//  Exhbt
//
//  Created by Shouvik Paul on 4/12/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

extension UIColor {
    static func Pink() -> UIColor {
        return UIColor(hex: 0xED77CF)
    }
    
    static func LightestGray() -> UIColor {
        return UIColor(hex: 0xE8E8E8)
    }
    
    static func LighterGray() -> UIColor {
        return UIColor(hex: 0xCCC8C8)
    }
    
    static func LightGray() -> UIColor {
        return UIColor(hex: 0x8B8B8B)
    }

    static func Gray() -> UIColor {
        return UIColor(hex: 0x111111)
    }
    
    static func DarkGray() -> UIColor {
        return UIColor(hex: 0x363636)
    }
    
    static func FacebookBlue() -> UIColor {
        return UIColor(hex: 0x3b5998)
    }
    
    static func EXRed() -> UIColor {
        return UIColor(hex: 0xF1474C)
    }
    
    convenience init(hex: Int) {
        let components = (
            r: CGFloat((hex >> 16) & 0xff) / 255,
            g: CGFloat((hex >> 08) & 0xff) / 255,
            b: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(
            red: components.r,
            green: components.g,
            blue: components.b,
            alpha: 1
        )
    }
}
