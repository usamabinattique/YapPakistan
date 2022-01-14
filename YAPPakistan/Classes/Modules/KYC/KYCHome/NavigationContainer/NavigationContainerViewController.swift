//
//  NavigationContainerViewController.swift
//  Adjust
//
//  Created by Sarmad on 06/12/2021.
//

import UIKit

class NavigationContainerViewController: UIViewController {
    // MARK: Views
    var childNavigation: UINavigationController!
    private var childView: UIView!

    // MARK: Initialization

    init(withChildNavigation childNav: UINavigationController) {
        super.init(nibName: nil, bundle: nil)
        self.childNavigation = childNav
        self.childView = childNav.view
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupContraints()
    }

    // MARK: View setup

    private func setupViews() {
        view.backgroundColor = .white
        childView.translatesAutoresizingMaskIntoConstraints = false
        addChild(childNavigation)
        view.addSubview(childView)
        childNavigation.didMove(toParent: self)
    }

    private func setupContraints() {
        childView.alignEdgesWithSuperview([.left, .right, .top, .bottom])
    }
}
