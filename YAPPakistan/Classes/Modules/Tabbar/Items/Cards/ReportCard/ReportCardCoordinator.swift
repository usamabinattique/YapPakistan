//
//  ReportCardCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 26/12/2021.
//

import RxSwift
import YAPCore
import YAPComponents

public class ReportCardCoordinator: Coordinator<ResultType<Void>> {

    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private var container: UserSessionContainer!

    var cardDetail: PaymentCard

    init(root: UIViewController, container: UserSessionContainer, cardDetail: PaymentCard) {
        self.root = root
        self.container = container
        self.cardDetail = cardDetail
        super.init()

        self.navigationRoot = makeNavigationController()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let cardsRepository = container.makeCardsRepository()
        let viewModel = ReportCardViewModel(paymentCard: self.cardDetail, cardsRepository: cardsRepository)
        let viewController = ReportCardViewController(themeService: container.themeService, viewModel: viewModel)
        
//        self.navigationRoot = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        
        self.navigationRoot.pushViewController(viewController, completion: nil)
        self.root.present(self.navigationRoot, animated: true, completion: nil)
        
        return result
    }
}

extension ReportCardCoordinator {
    
    func makeNavigationController(_ root: UIViewController? = nil) -> UINavigationController {

        var navigation: UINavigationController!
        if let root = root {
            navigation = UINavigationController(rootViewController: root)
        } else {
            navigation = UINavigationController()
        }
        navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.regular, NSAttributedString.Key.foregroundColor: UIColor(container.themeService.attrs.primary)]
        navigation.modalPresentationStyle = .fullScreen
        navigation.navigationBar.barTintColor = UIColor(container.themeService.attrs.primary)
        navigation.interactivePopGestureRecognizer?.isEnabled = false
        navigation.navigationBar.isTranslucent = false
        navigation.navigationBar.isOpaque = true
        navigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigation.navigationBar.shadowImage = UIImage()
        navigation.setNavigationBarHidden(false, animated: true)
        
        if #available(iOS 15, *) {
            let textAttributes = [NSAttributedString.Key.font: UIFont.regular, NSAttributedString.Key.foregroundColor: UIColor(container.themeService.attrs.primary)]
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = textAttributes
            appearance.backgroundColor = UIColor.white // UIColor(red: 0.0/255.0, green: 125/255.0, blue: 0.0/255.0, alpha: 1.0)
            appearance.shadowColor = .clear  //removing navigationbar 1 px bottom border.
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            
        }
        

        return navigation
    }
}
