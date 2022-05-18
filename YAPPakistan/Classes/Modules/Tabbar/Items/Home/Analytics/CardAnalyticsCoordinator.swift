//
//  CardAnalyticsCoordinator.swift
//  YAP
//
//  Created by Zain on 21/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

public class CardAnalyticsCoordinator: Coordinator<ResultType<Void>> {
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
//    public override var feature: CoordinatorFeature { .analytics }
    private var localNavigationController: UINavigationController?
    var card: PaymentCard
    var date: Date?
    private let container: UserSessionContainer

    public init(root: UIViewController, container: UserSessionContainer, card: PaymentCard, date: Date? = nil) {
        self.container = container
        self.root = root
        self.card = card
        self.date = date
    }

    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        let viewModel = CardAnalyticsViewModel(repository: container.makeAnalyticsRepository(), themeService: container.themeService, card: card, accountCreatedDate: container.makeAccountProvider().currentAccount.map{$0?.creationDate ?? Date()}, date: date)
        let viewController = CardAnalyticsViewController(themeService: container.themeService, viewModel: viewModel)
        localNavigationController = UINavigationControllerFactory.createOpaqueNavigationBarNavigationController(rootViewController: viewController)

        root.present(localNavigationController!, animated: true, completion: nil)

        viewModel.outputs.close.subscribe(onNext: { [weak self] in
            self?.result.onNext(ResultType.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)

//        viewModel.outputs.selectedAnalyticData.subscribe(onNext: { [weak self] (data, type, color, date) in
//            self?.navigateToMerchantAnalyticsDetail(analyticsData: data, type: type, color: color, date: date)
//        }).disposed(by: rx.disposeBag)

        return result
    }

//    private func navigateToMerchantAnalyticsDetail(analyticsData: AnalyticsData, type: AnalyticsDataType, color: UIColor, date: Date) {
//        let viewModel = MerchantAnalyticsDetailViewModel(card: card, data: analyticsData, type: type, color: color, date: date)
//        let viewController = MerchantAnalyticsDetailViewController(viewModel: viewModel)
//        localNavigationController?.pushViewController(viewController, animated: true)
//    }
}
