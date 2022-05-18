//
//  HelpAndSupportCoordinator.swift
//  YAPPakistan
//
//  Created by Awais on 11/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import YAPCardScanner

public class HelpAndSupportCoordinator: Coordinator<ResultType<Void>> {
    
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
        
        let viewModel = HelpAndSupportViewModel(cardsRepo: self.container.makeCardsRepository())
        let viewController = HelpAndSupportViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        viewModel.outputs.openFAQ.subscribe(onNext: { [unowned self] _ in naviagteToFAQs() }).disposed(by: disposeBag)
        
        localRoot = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primary), font: UIFont.regular)
        root.present(localRoot, animated: true, completion: nil)
        return result
    }
    
    fileprivate func naviagteToFAQs() {
        print("Navigate to FAQs")
        
        coordinate(to: FAQsCoordinator(root: self.localRoot, container: self.container)).subscribe(onNext: { _ in }).disposed(by: disposeBag)
    }
}

