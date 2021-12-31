//
//  ReportLostStollenCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/12/2021.
//

import RxSwift
import YAPCore

public class ReportLostStollenCoordinator: Coordinator<ResultType<Void>> {

    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var navigationRoot: UINavigationController!
    private var container: UserSessionContainer!

    var cardDetaild: PaymentCard?; #warning("FIXME")

    public init(root: UIViewController, container: UserSessionContainer) {
        self.root = root
        self.container = container

        super.init()

        self.navigationRoot = makeNavigationController()
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewController = UIViewController()
        viewController.view.backgroundColor = .gray
        viewController.view.rx.swipeGesture(.down).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.root.dismiss(animated: true, completion: nil)
                self.result.onNext(.success(()))
                self.result.onCompleted()
            })
            .disposed(by: rx.disposeBag)

        self.navigationRoot.pushViewController(viewController)
        self.navigationRoot.modalPresentationStyle = .fullScreen
        self.root.present(navigationRoot, animated: true, completion: nil)

        return result
    }

}

// MARK: - Helpers
extension ReportLostStollenCoordinator {
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
