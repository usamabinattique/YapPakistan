//
//  DashboardMissingDocumentCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 08/06/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

public class DashboardMissingDocumentCoordinator: Coordinator<ResultType<Void>> {
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
//    public override var feature: CoordinatorFeature { .analytics }
    private var localNavigationController: UINavigationController?
   
    private let container: UserSessionContainer
    private let disposeBag = DisposeBag()

    public init(root: UIViewController, container: UserSessionContainer) {
        self.container = container
        self.root = root
    }

    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewModel = DashboardMissingDocumentViewModel()
        let viewController = DashboardMissingDocumentViewController(viewModel: viewModel, themeService: container.themeService)
        localNavigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)
        localNavigationController?.isNavigationBarHidden = true
        root.present(localNavigationController!, animated: true, completion: nil)

//        viewModel.outputs.selectedAnalyticData.subscribe(onNext: { [weak self] (data, type, color, date) in
//            self?.navigateToMerchantAnalyticsDetail(analyticsData: data, type: type, color: color, date: date)
//        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.doItLater.subscribe(onNext: { [weak self] in
            self?.root.dismiss(animated: true, completion: nil)
            self?.result.onNext(ResultType.cancel)
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
        
        return result
    }

//    private func navigateToMerchantAnalyticsDetail(analyticsData: AnalyticsData, type: AnalyticsDataType, color: UIColor, date: Date) {
//        let viewModel = MerchantAnalyticsDetailViewModel(repository: container.makeAnalyticsRepository(),themeService: container.themeService,card: card, data: analyticsData, type: type, color: color, date: date)
//        let viewController = MerchantAnalyticsDetailViewController(themeService: container.themeService, viewModel: viewModel)
//        localNavigationController?.pushViewController(viewController, animated: true)
//    }
}
