//
//  UIColor+Extension.swift
//  YAPPakistan
//
//  Created by Umer on 09/09/2021.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(_ color: Color) {
        let hex = color.hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
}

public extension UIColor {
    static func colorFor(listItemIndex: Int) -> UIColor {
        switch listItemIndex % 6 {
        case 0: return UIColor(Color(hex: "#A682FF"))//.primarySoft
        case 1: return UIColor(Color(hex: "#F57F17")) //.secondaryOrange
        case 2: return UIColor(Color(hex: "#F44774")) //.secondaryMagenta
        case 3: return UIColor(Color(hex: "#478DF4")) //.secondaryBlue
        case 4: return UIColor(Color(hex: "#00B9AE")) //.secondaryGreen
        default: return UIColor(Color(hex: "#5E35B1"))  //.primary
        }
    }
    
    static func randomColor()-> UIColor {
        colorFor(listItemIndex: Int.random(in: 0...5))
    }
}
