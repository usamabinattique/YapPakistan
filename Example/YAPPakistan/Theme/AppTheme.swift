//
//  AppTheme.swift
//  YAPPakistan_Example
//
//  Created by Umer on 04/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxTheme
import RxSwiftExt


public struct Color {
    let hex: String
}

public protocol Theme {
    var primary: Color            { get }
    var primaryLight: Color       { get }
    var primaryExtraLight: Color  { get }
    var primaryDark: Color        { get }
    var primarySoft: Color        { get }
    var primaryAlt: Color         { get }
    var grey: Color               { get }
    var greyDark: Color           { get }
    var greyLight: Color          { get }
    var greyExtraLight: Color     { get }
    var success: Color            { get }
    var warning: Color            { get }
    var error: Color              { get }
    var secondaryBlue: Color      { get }
    var secondaryGreen: Color     { get }
    var secondaryOrange: Color    { get }
    var secondaryMagenta: Color   { get }
    var initials: Color           { get }
    var cell: Color               { get }
    var icon: Color               { get }
    var iconHolder: Color         { get }
    var backgroundColor: Color    { get }
}

struct LightTheme: Theme {
    var primary: Color              { Color(hex: "#5E35B1") }
    var primaryLight: Color         { Color(hex: "#7C4DFF") }
    var primaryExtraLight: Color    { Color(hex: "#F0EDFF") }
    var primaryDark: Color          { Color(hex: "#272262") }
    var primarySoft: Color          { Color(hex: "#A682FF") }
    var primaryAlt: Color           { Color(hex: "#BB42EB") }
    var grey: Color                 { Color(hex: "#C9C8D8") }
    var greyDark: Color             { Color(hex: "#9391B1") }
    var greyLight: Color            { Color(hex: "#DAE0F0") }
    var greyExtraLight: Color       { Color(hex: "#EDF0F8") }
    var success: Color              { Color(hex: "#44D389") }
    var warning: Color              { Color(hex: "#FFC430") }
    var error: Color                { Color(hex: "#FF3B30") }
    var secondaryBlue: Color        { Color(hex: "#478DF4") }
    var secondaryGreen: Color       { Color(hex: "#00B9AE") }
    var secondaryOrange: Color      { Color(hex: "#F57F17") }
    var secondaryMagenta: Color     { Color(hex: "#F44774") }
    var initials: Color             { Color(hex: "#7C4DFF") }
    var cell: Color                 { Color(hex: "#F7F8FC") }
    var icon: Color                 { Color(hex: "#5E35B1") }
    var iconHolder: Color           { Color(hex: "#FFFFFF") }
    var backgroundColor: Color      { Color(hex: "#FFFFFF") }

}

struct DarkTheme: Theme {
    // TODO: update these values for dark mode
    var primary: Color              { Color(hex: "#5E35B1") }
    var primaryLight: Color         { Color(hex: "#7C4DFF") }
    var primaryExtraLight: Color    { Color(hex: "#F0EDFF") }
    var primaryDark: Color          { Color(hex: "#272262") }
    var primarySoft: Color          { Color(hex: "#A682FF") }
    var primaryAlt: Color           { Color(hex: "#BB42EB") }
    var grey: Color                 { Color(hex: "#C9C8D8") }
    var greyDark: Color             { Color(hex: "#9391B1") }
    var greyLight: Color            { Color(hex: "#DAE0F0") }
    var greyExtraLight: Color       { Color(hex: "#EDF0F8") }
    var success: Color              { Color(hex: "#44D389") }
    var warning: Color              { Color(hex: "#FFC430") }
    var error: Color                { Color(hex: "#FF3B30") }
    var secondaryBlue: Color        { Color(hex: "#478DF4") }
    var secondaryGreen: Color       { Color(hex: "#00B9AE") }
    var secondaryOrange: Color      { Color(hex: "#F57F17") }
    var secondaryMagenta: Color     { Color(hex: "#F44774") }
    var initials: Color             { Color(hex: "#7C4DFF") }
    var cell: Color                 { Color(hex: "#F7F8FC") }
    var icon: Color                 { Color(hex: "#5E35B1") }
    var iconHolder: Color           { Color(hex: "#FFFFFF") }
    var backgroundColor: Color      { Color(hex: "#FFFFFF") }
}

public enum AppTheme: ThemeProvider {
    case light
    case dark

    public var associatedObject: Theme {
        switch self {
        case .dark:
            return DarkTheme()
        case .light:
            return LightTheme()
       }
    }
}
