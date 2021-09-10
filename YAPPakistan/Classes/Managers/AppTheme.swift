import UIKit
import RxTheme
import RxCocoa
import RxSwift

public let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .default)
public let themeService = AppTheme.service(initial: .light)

/*func appTheme<T>(_ mapper: @escaping ((Theme) -> T)) -> ThemeAttribute<T> {
    return themeService.attribute(mapper)
}*/

public func appTheme<T>(_ mapper: @escaping ((Theme) -> T)) -> Observable<T> {
    return themeService.attrStream(mapper)
}

public struct Color {
    let hex: String
}

public protocol Theme {
    var primary: Color              { get }
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
    var primary: Color              {   Color(hex: "#5E35B1")   }
    var primaryLight: Color         {   Color(hex: "#7C4DFF")   }
    var primaryExtraLight: Color    {   Color(hex: "#F0EDFF")   }
    var primaryDark: Color          {   Color(hex: "#272262")   }
    var primarySoft: Color          {   Color(hex: "#A682FF")   }
    var primaryAlt: Color           {   Color(hex: "#BB42EB")   }
    var grey: Color                 {   Color(hex: "#C9C8D8")   }
    var greyDark: Color             {   Color(hex: "#9391B1")   }
    var greyLight: Color            {   Color(hex: "#DAE0F0")   }
    var greyExtraLight: Color       {   Color(hex: "#EDF0F8")   }
    var success: Color              {   Color(hex: "#44D389")   }
    var warning: Color              {   Color(hex: "#FFC430")   }
    var error: Color                {   Color(hex: "#FF3B30")   }
    var secondaryBlue: Color        {   Color(hex: "#478DF4")   }
    var secondaryGreen: Color       {   Color(hex: "#00B9AE")   }
    var secondaryOrange: Color      {   Color(hex: "#F57F17")   }
    var secondaryMagenta: Color     {   Color(hex: "#F44774")   }
    var initials: Color             {   Color(hex: "#7C4DFF")   }
    var cell: Color                 {   Color(hex: "#F7F8FC")   }
    var icon: Color                 {   Color(hex: "#5E35B1")   }
    var iconHolder: Color           {   Color(hex: "#FFFFFF")   }
    var backgroundColor: Color      {   Color(hex: "#FFFFFF")   }

}

struct DarkTheme: Theme {
    //TODO: update these values for dark mode
    var primary: Color              {   Color(hex: "#5E35B1")   }
    var primaryLight: Color         {   Color(hex: "#7C4DFF")   }
    var primaryExtraLight: Color    {   Color(hex: "#F0EDFF")   }
    var primaryDark: Color          {   Color(hex: "#272262")   }
    var primarySoft: Color          {   Color(hex: "#A682FF")   }
    var primaryAlt: Color           {   Color(hex: "#BB42EB")   }
    var grey: Color                 {   Color(hex: "#C9C8D8")   }
    var greyDark: Color             {   Color(hex: "#9391B1")   }
    var greyLight: Color            {   Color(hex: "#DAE0F0")   }
    var greyExtraLight: Color       {   Color(hex: "#EDF0F8")   }
    var success: Color              {   Color(hex: "#44D389")   }
    var warning: Color              {   Color(hex: "#FFC430")   }
    var error: Color                {   Color(hex: "#FF3B30")   }
    var secondaryBlue: Color        {   Color(hex: "#478DF4")   }
    var secondaryGreen: Color       {   Color(hex: "#00B9AE")   }
    var secondaryOrange: Color      {   Color(hex: "#F57F17")   }
    var secondaryMagenta: Color     {   Color(hex: "#F44774")   }
    var initials: Color             {   Color(hex: "#7C4DFF")   }
    var cell: Color                 {   Color(hex: "#F7F8FC")   }
    var icon: Color                 {   Color(hex: "#5E35B1")   }
    var iconHolder: Color           {   Color(hex: "#FFFFFF")   }
    var backgroundColor: Color      {   Color(hex: "#FFFFFF")   }
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

extension Reactive where Base: RankView {
    var digitColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.digitColor = attr
        }
    }

    var digitBackgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.digitBackgroundColor = attr
        }
    }
}

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
struct Font {
    enum FontType {
        case custom(String)
        case system
        case systemBold
        case systemItatic
        case systemWeighted(weight: CGFloat)
        case monoSpacedDigit(size: CGFloat, weight: CGFloat)
    }
    enum FontSize {
        case standard(StandardSize)
        case custom(CGFloat)
        var value: CGFloat {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }

    enum StandardSize: CGFloat {
        case h1 = 28.0
        case h2 = 24.0
        case h3 = 21.0
        case h4 = 18.0
        case h5 = 16.0
        case h6 = 14.0
    }
    
    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension Font {
    var instance: UIFont {
        var instanceFont: UIFont!
        switch type {
        case .custom(let fontName):
            guard let font =  UIFont(name: fontName, size: size.value) else {
                fatalError("\(fontName) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .system:
            instanceFont = UIFont.systemFont(ofSize: size.value)
        case .systemBold:
            instanceFont = UIFont.boldSystemFont(ofSize: size.value)
        case .systemItatic:
            instanceFont = UIFont.italicSystemFont(ofSize: size.value)
        case .systemWeighted(let weight):
            instanceFont = UIFont.systemFont(ofSize: size.value,
                                             weight: UIFont.Weight(weight))
        case .monoSpacedDigit(let size, let weight):
            instanceFont = UIFont.monospacedDigitSystemFont(ofSize: size,
                                                            weight: UIFont.Weight(weight))
        }
        return instanceFont
    }
}


public extension UIFont {
    /// Font size = 28
    static var h1: UIFont {
        Font(.system, size: .standard(.h1)).instance
    }
    /// Font size = 24
    static var h2: UIFont {
        Font(.system, size: .standard(.h2)).instance
    }
    /// Font size = 21
    static var h3: UIFont {
        Font(.system, size: .standard(.h3)).instance
    }
    /// Font size = 18
    static var h4: UIFont {
        Font(.system, size: .standard(.h4)).instance
    }
    /// Font size = 16
    static var h5: UIFont {
        Font(.system, size: .standard(.h5)).instance
    }
    /// Font size = 14
    static var h6: UIFont {
        Font(.system, size: .standard(.h6)).instance
    }
}
*/
