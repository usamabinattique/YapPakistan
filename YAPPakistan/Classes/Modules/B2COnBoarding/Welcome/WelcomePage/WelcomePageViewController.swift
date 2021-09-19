//
//  WelcomePageViewController.swift
//  YAP
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WelcomePageViewController: UIPageViewController {
    fileprivate var viewModel: WelcomePageViewModelType!
    fileprivate var pages = [WelcomePageChildViewController]()

    private var currentIndex: Int = 0 {
        didSet { pages.forEach { $0.setCurrentPage(currentIndex) } }
    }

    init(viewModel: WelcomePageViewModelType) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        bindViews()
    }
}

// MARK: Actions

private extension WelcomePageViewController {
    @objc
    func tapped(_ tap: UITapGestureRecognizer) {
        guard currentIndex < pages.count - 1 else { return }
        pages[currentIndex].animatePop { [weak self] in
            guard let `self` = self else { return }
            self.setViewControllers([self.pages[self.currentIndex + 1]], direction: .forward, animated: true, completion: nil)
            self.currentIndex += 1
            self.viewModel.inputs.selectedPageObserver.onNext(self.currentIndex)
        }

    }
}

// MARK: Binding

extension WelcomePageViewController {
    fileprivate func bindViews() {
        viewModel.outputs.pageChildViewModels.subscribe(onNext: { [unowned self] viewModels in
            viewModels.enumerated().forEach { self.pages.append(WelcomePageChildViewController(viewModel: $0.1, index: $0.0)) }
            self.setViewControllers([self.pages.first!], direction: .forward, animated: false, completion: nil)
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: Page controller datasurce

extension WelcomePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let pageViewController = viewController as? WelcomePageChildViewController, let index = pages.firstIndex(of: pageViewController), index > 0 else { return nil }

        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageViewController = viewController as? WelcomePageChildViewController, let index = pages.firstIndex(of: pageViewController), index < pages.count - 1 else { return nil }

        return pages[index + 1]
    }
}

// MARK: Page controller delegate

extension WelcomePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard completed, let pageViewController = viewControllers?.first as? WelcomePageChildViewController, let index = pages.firstIndex(of: pageViewController) else { return }
        currentIndex = index
        viewModel.inputs.selectedPageObserver.onNext(index)
    }
}
