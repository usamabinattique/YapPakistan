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
        self.navigationRoot.modalPresentationStyle = .fullScreen
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let cardsRepository = container.makeCardsRepository()
        let viewModel = ReportCardViewModel(paymentCard: self.cardDetail, cardsRepository: cardsRepository)
        let viewController = ReportCardViewController(themeService: container.themeService, viewModel: viewModel)
        
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
        navigation.interactivePopGestureRecognizer?.isEnabled = false
        navigation.navigationBar.isTranslucent = true
        navigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigation.navigationBar.shadowImage = UIImage()
        navigation.setNavigationBarHidden(false, animated: true)

        return navigation
    }
}
