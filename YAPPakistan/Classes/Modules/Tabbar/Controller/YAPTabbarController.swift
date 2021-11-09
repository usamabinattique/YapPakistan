//
//  YAPTabbarController.swift
//  YAP
//
//  Created by Muhammad Hussaan Saeed on 21/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import YAPComponents

//enum TabBarItem: Int {
//    case home = 0
//    case store
//    case yapIT
//    case cards
//    case more
//}

class YAPTabbarController: MenuViewController {

    lazy var button = UIButton()
    private let disposeBag = DisposeBag()
    private let buttonSize = CGFloat(94)
    private let buttonOffsetY = CGFloat(-30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        styleTabbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.addSubview(button)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let frame = tabBar.frame
        button.frame = CGRect(x: (frame.width/2) - (buttonSize/2), y: buttonOffsetY, width: buttonSize, height: buttonSize)
        
    }
    
    private func setupView() {
        button.setImage(UIImage(named: "icon_tabbar_yapit", in: .yapPakistan), for: .normal)
    }
    
    fileprivate func styleTabbar() {
        tabBar.backgroundImage = UIImage(color: .clear)
        tabBar.backgroundColor = .white
        tabBar.shadowImage = UIImage(color: .clear)
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1.0)
        tabBar.layer.shadowRadius = 2
        ///tabBar.layer.shadowColor = UIColor.appColor(ofType: .grey).cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.clipsToBounds = false
        ///tabBar.tintColor = .primary
    }
 
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = tabBar.items?.firstIndex(of: item) ?? 0
        isMenuEnabled = index == 0
        if  index != 0 {
            hideMenu()
        }
        
//        switch index {
//        case TabBarItem.home.rawValue:
//            AppAnalytics.shared.logEvent(DashboardEvent.tapHome())
//        case TabBarItem.store.rawValue:
//            AppAnalytics.shared.logEvent(DashboardEvent.tapStore())
//        case TabBarItem.yapIT.rawValue:
//            AppAnalytics.shared.logEvent(DashboardEvent.tapYapIt())
//        case TabBarItem.cards.rawValue:
//            AppAnalytics.shared.logEvent(DashboardEvent.tapCards())
//        case TabBarItem.more.rawValue:
//            AppAnalytics.shared.logEvent(DashboardEvent.tapMore())
//        default:
//            break
//        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, YAPTabBar.self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

fileprivate class YAPTabBar: UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + 65
        return sizeThatFits
    }
}
