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

public protocol Theme {
    var backgroundColor: UIColor    { get }
    var primary: UIColor            { get }
    var primaryLight: UIColor       { get }
    var primaryExtraLight: UIColor  { get }
    var primaryDark: UIColor        { get }
    var primarySoft: UIColor        { get }
    var primaryAlt: UIColor         { get }
    var grey: UIColor               { get }
    var greyDark: UIColor           { get }
    var greyLight: UIColor          { get }
    var greyExtraLight: UIColor     { get }
    var success: UIColor            { get }
    var warning: UIColor            { get }
    var error: UIColor              { get }
    var secondaryBlue: UIColor      { get }
    var secondaryGreen: UIColor     { get }
    var secondaryOrange: UIColor    { get }
    var secondaryMagenta: UIColor   { get }
    var initials: UIColor           { get }
    var cell: UIColor               { get }
    var icon: UIColor               { get }
    var iconHolder: UIColor         { get }
    
    var statusBarStyle: UIStatusBarStyle        { get }
    var barStyle: UIBarStyle                    { get }
    var keyboardAppearance: UIKeyboardAppearance{ get }
    var blurStyle: UIBlurEffect.Style           { get }
}

struct LightTheme: Theme {
    var primary: UIColor            {   #colorLiteral(red: 0.368627451, green: 0.2078431373, blue: 0.6941176471, alpha: 1)  }
    var primaryLight: UIColor       {   #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)  }
    var primaryExtraLight: UIColor  {   #colorLiteral(red: 0.9411764706, green: 0.9294117647, blue: 1, alpha: 1)  }
    var primaryDark: UIColor        {   #colorLiteral(red: 0.1529999971, green: 0.1330000013, blue: 0.3840000033, alpha: 1)  }
    var primarySoft: UIColor        {   #colorLiteral(red: 0.6509803922, green: 0.5098039216, blue: 1, alpha: 1)  }
    var primaryAlt: UIColor         {   #colorLiteral(red: 0.7329999804, green: 0.2590000033, blue: 0.9219999909, alpha: 1)  }
    var grey: UIColor               {   #colorLiteral(red: 0.7879999876, green: 0.7839999795, blue: 0.8470000029, alpha: 1)  }
    var greyDark: UIColor           {   #colorLiteral(red: 0.5759999752, green: 0.5690000057, blue: 0.6940000057, alpha: 1)  }
    var greyLight: UIColor          {   #colorLiteral(red: 0.8549019608, green: 0.878000021, blue: 0.9409999847, alpha: 1)  }
    var greyExtraLight: UIColor     {   #colorLiteral(red: 0.9294117647, green: 0.9411764706, blue: 0.9725490196, alpha: 1)  }
    var success: UIColor            {   #colorLiteral(red: 0.2669999897, green: 0.8270000219, blue: 0.5370000005, alpha: 1)  }
    var warning: UIColor            {   #colorLiteral(red: 1, green: 0.7689999938, blue: 0.1879999936, alpha: 1)  }
    var error: UIColor              {   #colorLiteral(red: 1, green: 0.2310000062, blue: 0.1879999936, alpha: 1)  }
    var secondaryBlue: UIColor      {   #colorLiteral(red: 0.2784313725, green: 0.5529411765, blue: 0.9568627451, alpha: 1)  }
    var secondaryGreen: UIColor     {   #colorLiteral(red: 0, green: 0.7254901961, blue: 0.6823529412, alpha: 1)  }
    var secondaryOrange: UIColor    {   #colorLiteral(red: 0.9607843137, green: 0.4980392157, blue: 0.09019607843, alpha: 1)  }
    var secondaryMagenta: UIColor   {   #colorLiteral(red: 0.9568627451, green: 0.2784313725, blue: 0.4549019608, alpha: 1)  }
    var initials: UIColor           {   #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)  }
    var cell: UIColor               {   #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9882352941, alpha: 1)  }
    var icon: UIColor               {   #colorLiteral(red: 0.368627451, green: 0.2078431373, blue: 0.6941176471, alpha: 1)  }
    var iconHolder: UIColor         {   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)  }
    var backgroundColor: UIColor    {   .white   }
    
    var statusBarStyle: UIStatusBarStyle    {   UIStatusBarStyle.default    }
    var barStyle: UIBarStyle                {   UIBarStyle.default          }
    var keyboardAppearance: UIKeyboardAppearance { UIKeyboardAppearance.light }
    var blurStyle: UIBlurEffect.Style       { UIBlurEffect.Style.extraLight }
}

struct DarkTheme: Theme {
    //TODO: update these values for dark mode
    var primary: UIColor            {   #colorLiteral(red: 0.368627451, green: 0.2078431373, blue: 0.6941176471, alpha: 1)  }
    var primaryLight: UIColor       {   #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)  }
    var primaryExtraLight: UIColor  {   #colorLiteral(red: 0.9411764706, green: 0.9294117647, blue: 1, alpha: 1)  }
    var primaryDark: UIColor        {   #colorLiteral(red: 0.1529999971, green: 0.1330000013, blue: 0.3840000033, alpha: 1)  }
    var primarySoft: UIColor        {   #colorLiteral(red: 0.6509803922, green: 0.5098039216, blue: 1, alpha: 1)  }
    var primaryAlt: UIColor         {   #colorLiteral(red: 0.7329999804, green: 0.2590000033, blue: 0.9219999909, alpha: 1)  }
    var grey: UIColor               {   #colorLiteral(red: 0.7879999876, green: 0.7839999795, blue: 0.8470000029, alpha: 1)  }
    var greyDark: UIColor           {   #colorLiteral(red: 0.5759999752, green: 0.5690000057, blue: 0.6940000057, alpha: 1)  }
    var greyLight: UIColor          {   #colorLiteral(red: 0.8549019608, green: 0.878000021, blue: 0.9409999847, alpha: 1)  }
    var greyExtraLight: UIColor     {   #colorLiteral(red: 0.9294117647, green: 0.9411764706, blue: 0.9725490196, alpha: 1)  }
    var success: UIColor            {   #colorLiteral(red: 0.2669999897, green: 0.8270000219, blue: 0.5370000005, alpha: 1)  }
    var warning: UIColor            {   #colorLiteral(red: 1, green: 0.7689999938, blue: 0.1879999936, alpha: 1)  }
    var error: UIColor              {   #colorLiteral(red: 1, green: 0.2310000062, blue: 0.1879999936, alpha: 1)  }
    var secondaryBlue: UIColor      {   #colorLiteral(red: 0.2784313725, green: 0.5529411765, blue: 0.9568627451, alpha: 1)  }
    var secondaryGreen: UIColor     {   #colorLiteral(red: 0, green: 0.7254901961, blue: 0.6823529412, alpha: 1)  }
    var secondaryOrange: UIColor    {   #colorLiteral(red: 0.9607843137, green: 0.4980392157, blue: 0.09019607843, alpha: 1)  }
    var secondaryMagenta: UIColor   {   #colorLiteral(red: 0.9568627451, green: 0.2784313725, blue: 0.4549019608, alpha: 1)  }
    var initials: UIColor           {   #colorLiteral(red: 0.4862745098, green: 0.3019607843, blue: 1, alpha: 1)  }
    var cell: UIColor               {   #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9882352941, alpha: 1)  }
    var icon: UIColor               {   #colorLiteral(red: 0.368627451, green: 0.2078431373, blue: 0.6941176471, alpha: 1)  }
    var iconHolder: UIColor         {   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)  }
    var backgroundColor: UIColor    {   .black  }
    
    var statusBarStyle: UIStatusBarStyle    {   UIStatusBarStyle.default    }
    var barStyle: UIBarStyle                {   UIBarStyle.default          }
    var keyboardAppearance: UIKeyboardAppearance { UIKeyboardAppearance.light }
    var blurStyle: UIBlurEffect.Style       { UIBlurEffect.Style.extraLight }
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
