//
//  File.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPCore

public enum YAPItAction {
    case sendMoney
    case addMoney
    case payBills
}

public class YAPItCoordinator: Coordinator<ResultType<YAPItAction>> {

    private let root: UIViewController
    private let result = PublishSubject<ResultType<YAPItAction>>()
    private var container: UserSessionContainer
    private var tabBarHeight: CGFloat

    public init(root: UIViewController,
                container: UserSessionContainer,
                tabBarHeight: CGFloat = 0) {
        self.root = root
        self.container = container
        self.tabBarHeight = tabBarHeight
    }

    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<YAPItAction>> {

        let viewModel = YAPItViewModel()
        let viewController = YAPItViewController(viewModel: viewModel, themeService: container.themeService, tabBarHeight: tabBarHeight)
        let nav = makeNavigationController(root: viewController)
        root.present(nav, animated: false, completion: nil)

        viewModel.outputs.hide.subscribe(onNext: { [unowned self] in
            nav.dismiss(animated: false, completion: nil)
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.addMoney.subscribe(onNext: { [unowned self] in
            nav.dismiss(animated: false, completion: nil)
            self.result.onNext(ResultType.success(.addMoney))
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.payBills.subscribe(onNext: { [unowned self] in
            nav.dismiss(animated: false, completion: nil)
            self.result.onNext(ResultType.success(.payBills))
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.sendMoney.subscribe(onNext: { [unowned self] in
            nav.dismiss(animated: false, completion: nil)
            self.result.onNext(ResultType.success(.sendMoney))
            self.result.onCompleted()
        }).disposed(by: rx.disposeBag)

        return result
    }

    func makeNavigationController(root: UIViewController) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: root)
        navigation.interactivePopGestureRecognizer?.isEnabled = false
        navigation.navigationBar.isTranslucent = true
        navigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigation.navigationBar.shadowImage = UIImage()
        navigation.setNavigationBarHidden(false, animated: true)
        navigation.modalPresentationStyle = .overCurrentContext
        return navigation
    }
}
