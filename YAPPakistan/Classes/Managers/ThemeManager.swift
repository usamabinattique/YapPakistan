//
//  ThemeManager.swift
//  iOSApp
//
//  Created by Abbas on 06/06/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
//import KafkaRefresh
import SwifterSwift

let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .default)

let themeService = ThemeType.service(initial: ThemeType.currentTheme())

protocol Theme {
    /*
    var primary: UIColor { get }
    var primaryDark: UIColor { get }
    var secondary: UIColor { get }
    var secondaryDark: UIColor { get }
    var separator: UIColor { get }
    var text: UIColor { get }
    var textGray: UIColor { get }
    var background: UIColor { get }
    */
    
    var primary:UIColor { get }
    var primaryDark:UIColor { get }
    var primaryLight:UIColor { get }
    var primarySoft:UIColor { get }
    var primaryAlt:UIColor { get }
    var primaryFade:UIColor { get }
    var grey:UIColor { get }
    var greyDark:UIColor { get }
    var greyLight:UIColor { get }
    var greyExtraLight:UIColor { get }
    var greyMedium:UIColor { get }
    var success:UIColor { get }
    var warning:UIColor { get }
    var error:UIColor { get }
    var secondaryBlue:UIColor { get }
    var secondaryOrange:UIColor { get }
    var secondaryGreen:UIColor { get }
    var secondaryMagenta:UIColor { get }
    var white:UIColor { get }
    var black:UIColor { get }
    var separatorGrey:UIColor { get }
    var initials:UIColor { get }
    var tableViewCellGreen:UIColor { get }
    var iconHolder:UIColor { get }
    var icon:UIColor { get }
    
    var statusBarStyle: UIStatusBarStyle { get }
    var barStyle: UIBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }

    //init(colorTheme: ColorTheme)
}

struct LightTheme: Theme {
    var primary:UIColor             =    #colorLiteral(red: 0.1098039216, green: 0.1490196078, blue: 0.6588235294, alpha: 1)
    var primaryDark:UIColor         =    #colorLiteral(red: 0.9215686275, green: 0.9254901961, blue: 0.968627451, alpha: 1)
    var primaryLight:UIColor        =    #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)
    var primarySoft:UIColor         =    #colorLiteral(red: 0.1529999971, green: 0.1330000013, blue: 0.3840000033, alpha: 1)
    var primaryAlt:UIColor          =    #colorLiteral(red: 0.6509803922, green: 0.5098039216, blue: 1, alpha: 1)
    var primaryFade:UIColor         =    #colorLiteral(red: 0.7329999804, green: 0.2590000033, blue: 0.9219999909, alpha: 1)
    var grey:UIColor                =    #colorLiteral(red: 0.7879999876, green: 0.7839999795, blue: 0.8470000029, alpha: 1)
    var greyDark:UIColor            =    #colorLiteral(red: 0.8549019608, green: 0.878000021, blue: 0.9409999847, alpha: 1)
    var greyLight:UIColor           =    #colorLiteral(red: 0.9294117647, green: 0.9411764706, blue: 0.9725490196, alpha: 1)
    var greyExtraLight:UIColor      =    #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5176470588, alpha: 1)
    var greyMedium:UIColor          =    #colorLiteral(red: 0.5759999752, green: 0.5690000057, blue: 0.6940000057, alpha: 1)
    var success:UIColor             =    #colorLiteral(red: 0.2669999897, green: 0.8270000219, blue: 0.5370000005, alpha: 1)
    var warning:UIColor             =    #colorLiteral(red: 1, green: 0.7689999938, blue: 0.1879999936, alpha: 1)
    var error:UIColor               =    #colorLiteral(red: 1, green: 0.2310000062, blue: 0.1879999936, alpha: 1)
    var secondaryBlue:UIColor       =    #colorLiteral(red: 0.2784313725, green: 0.5529411765, blue: 0.9568627451, alpha: 1)
    var secondaryOrange:UIColor     =    #colorLiteral(red: 0.9607843137, green: 0.4980392157, blue: 0.09019607843, alpha: 1)
    var secondaryGreen:UIColor      =    #colorLiteral(red: 0, green: 0.7254901961, blue: 0.6823529412, alpha: 1)
    var secondaryMagenta:UIColor    =    #colorLiteral(red: 0.9568627451, green: 0.2784313725, blue: 0.4549019608, alpha: 1)
    var white:UIColor               =   .white
    var black:UIColor               =   .black
    var separatorGrey:UIColor       =    #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    var initials:UIColor            =    #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)
    var tableViewCellGreen:UIColor  =    #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9882352941, alpha: 1)
    var iconHolder:UIColor          =    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var icon:UIColor                =    #colorLiteral(red: 0.368627451, green: 0.2078431373, blue: 0.6941176471, alpha: 1)
    
    var statusBarStyle = UIStatusBarStyle.default
    var barStyle = UIBarStyle.default
    var keyboardAppearance = UIKeyboardAppearance.light
    var blurStyle = UIBlurEffect.Style.extraLight
}

struct DarkTheme: Theme {
    var primary:UIColor             =    #colorLiteral(red: 0.1098039216, green: 0.1490196078, blue: 0.6588235294, alpha: 1)
    var primaryDark:UIColor         =    #colorLiteral(red: 0.9215686275, green: 0.9254901961, blue: 0.968627451, alpha: 1)
    var primaryLight:UIColor        =    #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)
    var primarySoft:UIColor         =    #colorLiteral(red: 0.1529999971, green: 0.1330000013, blue: 0.3840000033, alpha: 1)
    var primaryAlt:UIColor          =    #colorLiteral(red: 0.6509803922, green: 0.5098039216, blue: 1, alpha: 1)
    var primaryFade:UIColor         =    #colorLiteral(red: 0.7329999804, green: 0.2590000033, blue: 0.9219999909, alpha: 1)
    var grey:UIColor                =    #colorLiteral(red: 0.7879999876, green: 0.7839999795, blue: 0.8470000029, alpha: 1)
    var greyDark:UIColor            =    #colorLiteral(red: 0.8549019608, green: 0.878000021, blue: 0.9409999847, alpha: 1)
    var greyLight:UIColor           =    #colorLiteral(red: 0.9294117647, green: 0.9411764706, blue: 0.9725490196, alpha: 1)
    var greyExtraLight:UIColor      =    #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5176470588, alpha: 1)
    var greyMedium:UIColor          =    #colorLiteral(red: 0.5759999752, green: 0.5690000057, blue: 0.6940000057, alpha: 1)
    var success:UIColor             =    #colorLiteral(red: 0.2669999897, green: 0.8270000219, blue: 0.5370000005, alpha: 1)
    var warning:UIColor             =    #colorLiteral(red: 1, green: 0.7689999938, blue: 0.1879999936, alpha: 1)
    var error:UIColor               =    #colorLiteral(red: 1, green: 0.2310000062, blue: 0.1879999936, alpha: 1)
    var secondaryBlue:UIColor       =    #colorLiteral(red: 0.2784313725, green: 0.5529411765, blue: 0.9568627451, alpha: 1)
    var secondaryOrange:UIColor     =    #colorLiteral(red: 0.9607843137, green: 0.4980392157, blue: 0.09019607843, alpha: 1)
    var secondaryGreen:UIColor      =    #colorLiteral(red: 0, green: 0.7254901961, blue: 0.6823529412, alpha: 1)
    var secondaryMagenta:UIColor    =    #colorLiteral(red: 0.9568627451, green: 0.2784313725, blue: 0.4549019608, alpha: 1)
    var white:UIColor               =   .white
    var black:UIColor               =   .black
    var separatorGrey:UIColor       =    #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    var initials:UIColor            =    #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)
    var tableViewCellGreen:UIColor  =    #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9882352941, alpha: 1)
    var iconHolder:UIColor          =    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var icon:UIColor                =    #colorLiteral(red: 0.368627451, green: 0.2078431373, blue: 0.6941176471, alpha: 1)
    
    var statusBarStyle = UIStatusBarStyle.default
    var barStyle = UIBarStyle.default
    var keyboardAppearance = UIKeyboardAppearance.light
    var blurStyle = UIBlurEffect.Style.extraLight
}

enum ThemeType: ThemeProvider {
    case light
    case dark

    var associatedObject: Theme {
        switch self {
        case .light:    return LightTheme()
        case .dark:     return DarkTheme()
        }
    }

    var isDark: Bool {
        switch self {
        case .dark: return true
        default:    return false
        }
    }

    func toggled() -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light:    theme = ThemeType.dark
        case .dark:     theme = ThemeType.light
        }
        theme.save()
        return theme
    }

    func withColor() -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light: theme = ThemeType.light
        case .dark: theme = ThemeType.dark
        }
        theme.save()
        return theme
    }
}

extension ThemeType {
    static func currentTheme() -> ThemeType {
        let defaults = UserDefaults.standard
        let isDark = defaults.bool(forKey: "IsDarkKey")
        let theme = isDark ? ThemeType.dark : ThemeType.light
        //theme.save()
        return theme
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(self.isDark, forKey: "IsDarkKey")
    }
}

extension Reactive where Base: UIView {

    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }
}

extension Reactive where Base: UITextField {
    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.borderColor = attr
        }
    }

    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            if let color = attr {
                view.setPlaceHolderTextColor(color)
            }
        }
    }
}

extension Reactive where Base: UITableView {

    var separatorColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.separatorColor = attr
        }
    }
}

extension Reactive where Base: UINavigationBar {

    @available(iOS 11.0, *)
    var largeTitleTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(self.base) { view, attr in
            view.largeTitleTextAttributes = attr
        }
    }
}

public extension Reactive where Base: UISwitch {

    var onTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.onTintColor = attr
        }
    }

    var thumbTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.thumbTintColor = attr
        }
    }
}

extension Reactive where Base: UIApplication {

    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { view, attr in
            globalStatusBarStyle.accept(attr)
        }
    }
}

//func themed<T>(_ mapper: @escaping ((Theme) -> T)) -> ThemeAttribute<T> {
//    return themeService.attribute(mapper)
//}

/*
public extension ThemeProxy where Base: UIApplication {
    /// (set only) bind a stream to status-bar-style
    var statusBarStyle: ThemeAttribute<UIStatusBarStyle> {
        get { fatalError("set only") }
        set {
            globalStatusBarStyle.accept(newValue.value)
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.statusBarStyle)
            hold(disposable, for: "textColor")
        }
    }
}
*/

/*
extension Reactive where Base: KafkaRefreshDefaults {

    var themeColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.themeColor = attr
        }
    }
}
*/
