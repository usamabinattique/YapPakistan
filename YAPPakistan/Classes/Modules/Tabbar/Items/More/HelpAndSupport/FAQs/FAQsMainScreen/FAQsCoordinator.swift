//
//  FAQsCoordinator.swift
//  YAPPakistan
//
//  Created by Awais on 17/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import YAPCardScanner
import Alamofire

public class FAQsCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private let result = PublishSubject<ResultType<Void>>()
    private var localRoot: UINavigationController!
    
    private var container: UserSessionContainer!
    private let disposeBag = DisposeBag()
    
    
    public init(root: UIViewController, container: UserSessionContainer) {
        self.container = container
        self.root = root
    }
    
    override public func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        let viewModel = FAQsViewModel(repository: self.container.makeAccountRepository())
        let viewController = FAQsViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        viewModel.showFAQDetail.subscribe(onNext: { [unowned self] faq in
            self.naviagteToFAQDetails(faq: faq)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.back.subscribe(onNext: { [unowned self] _ in
            self.localRoot.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.search.subscribe(onNext: { [unowned self] faqs in
            self.navigateToSearchFAQS(faqs: faqs)
        }).disposed(by: disposeBag)
        
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        root.present(localRoot, animated: true, completion: nil)
        return result
    }
    
    fileprivate func navigateToSearchFAQS(faqs: [FAQsResponse]) {
        let viewModel = SearchFAQsViewModel(faqs: faqs)
        let viewController = SearchFAQsViewController(themeService: self.container.themeService, viewModel: viewModel)
        
        viewModel.outputs.cancel.subscribe(onNext: { [unowned self] _ in
            self.localRoot.popViewController(animated: true, nil)
        }).disposed(by: disposeBag)
        
        localRoot.pushViewController(viewController, completion: nil)
    }
    
    fileprivate func naviagteToFAQDetails(faq: FAQsResponse) {
        let viewModel = FAQDetailViewModel(faq: faq)
        let viewController = FAQDetailViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        viewModel.outputs.back.subscribe(onNext: { [unowned self] _ in
            self.localRoot.popViewController(animated: true, nil)
        }).disposed(by: disposeBag)
        
        localRoot.pushViewController(viewController, animated: true)
    }
}
