//
//  UIFont+Extensions.swift
//  YAPPakistan
//
//  Created by Sarmad Abbas on 27/08/2021.
//  Copyright © 2021 YAPPakistan. All rights reserved.
//

import UIKit

public enum AppFontWeight: Hashable {
    case ultraLight, thin, light, regular, medium, semibold, bold, heavy, black
}

public enum AppTextStyle: Hashable {
    case title1 (_ weight: AppFontWeight = .regular )
    case title2 (_ weight: AppFontWeight = .regular )
    case title3 (_ weight: AppFontWeight = .regular )
    case large  (_ weight: AppFontWeight = .regular )
    case regular(_ weight: AppFontWeight = .regular )
    case small  (_ weight: AppFontWeight = .regular )
    case micro  (_ weight: AppFontWeight = .regular )
    case nano   (_ weight: AppFontWeight = .regular )
}

public extension UIFont {
    static func title1 ( _ weight: AppFontWeight) -> UIFont { return AppTextStyle.title1(weight).font }
    static func title2 ( _ weight: AppFontWeight) -> UIFont { return AppTextStyle.title2(weight).font }
    static func title3 ( _ weight: AppFontWeight) -> UIFont { return AppTextStyle.title3(weight).font }
    static func large  ( _ weight: AppFontWeight) -> UIFont { return AppTextStyle.large(weight).font }
    static func regular( _ weight: AppFontWeight) -> UIFont { return AppTextStyle.regular(weight).font }
    static func small  ( _ weight: AppFontWeight) -> UIFont { return AppTextStyle.small(weight).font }
    static func micro  ( _ weight: AppFontWeight) -> UIFont { return AppTextStyle.micro(weight).font }

    static var title1: UIFont { return .title1( .regular) }
    /// Font size = 24
    static var title2: UIFont { return .title2( .regular) }
    /// Font size = 21
    static var title3: UIFont { return .title3( .regular) }
    /// Font size = 18
    static var large: UIFont { return .large(  .regular) }
    /// Font size = 16
    static var regular: UIFont { return .regular(.regular) }
    /// Font size = 14
    static var small: UIFont { return .small(  .regular) }
    /// Font size = 12
    static var micro: UIFont { return .micro(  .regular) }
}

fileprivate extension AppTextStyle {
    var fontSize: CGFloat {
        switch self {
        case .title1:   return 28.0
        case .title2:   return 24.0
        case .title3:   return 21.0
        case .large:    return 18.0
        case .regular:  return 16.0
        case .small:    return 14.0
        case .micro:    return 12.0
        case .nano:     return 10.0
        }
    }

    var font: UIFont {
        switch self {
        case .title1 (let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        case .title2 (let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        case .title3 (let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        case .large  (let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        case .regular(let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        case .small  (let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        case .micro  (let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        case .nano   (let wieght): return .systemFont(ofSize: fontSize, weight: wieght.systemFontWeight)
        }
    }
}

fileprivate extension AppFontWeight {
    var systemFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight:   return .ultraLight
        case .thin:         return .thin
        case .light:        return .light
        case .regular:      return .regular
        case .medium:       return .medium
        case .semibold:     return .semibold
        case .bold:         return .bold
        case .heavy:        return .heavy
        case .black:        return .black
        }
    }
}
