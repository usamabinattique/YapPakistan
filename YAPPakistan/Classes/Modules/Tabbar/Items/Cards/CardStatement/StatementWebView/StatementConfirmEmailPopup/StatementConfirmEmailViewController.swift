//
//  StatementConfirmEmailViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 08/05/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class StatementConfirmEmailViewController: UIViewController {

    // MARK: Views

    public lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var holder: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var headerTitle: UILabel = UIFactory.makeLabel(font: .title3, text: "Account details")
    
    // MARK: Properties
    public var window: UIWindow?
    public var viewTop: NSLayoutConstraint!
    public var start: CGFloat = 0
    private var viewModel: StatementConfirmEmailViewModel!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>,viewModel: StatementConfirmEmailViewModel) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupTheme()
        setupConstraints()
        setupBindings()
        addGestureRecognisers()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.resignKey()
        view.window?.removeFromSuperview()
        window = nil
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layoutIfNeeded()

        viewTop.constant = -1 * sheetView.bounds.height

        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.view.layoutIfNeeded()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeAction(_:)))

        self.sheetView.addGestureRecognizer(tap)

        self.sheetView.isUserInteractionEnabled = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        holder.roundView()
        sheetView.layer.cornerRadius = 18
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
    }

    public func addGestureRecognisers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.cancelsTouchesInView = false
        sheetView.addGestureRecognizer(pan)
    }
}

// MARK: View setup

extension StatementConfirmEmailViewController: ViewDesignable {
    
    func setupSubViews() {
        
    }
    
    func setupConstraints() {
        viewTop = sheetView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        viewTop.isActive = true
    }
    
    func setupBindings() {
        
    }
    
    func setupTheme() {
        
    }
}

extension StatementConfirmEmailViewController {
    @objc
    func closeAction(_ tap: UITapGestureRecognizer) {
        guard tap.location(in: view).y < sheetView.frame.origin.y + 50 else { return }

        completeHide(0)
    }

    @objc
    func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            start = pan.location(in: sheetView).y

        case .changed:
            changePosition(pan.location(in: view).y - start)

        case .ended:
            let progress = ((sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)) / sheetView.bounds.height)
            let velocity = pan.velocity(in: view).y
            if progress < 0.25 {
                velocity < 900 ? completeShow(velocity) : completeHide(velocity)
            } else {
                velocity > -900 ? completeHide(velocity) : completeShow(velocity)
            }

        default:
            break
        }
    }

    func changePosition(_ y: CGFloat) {
        guard y >= (view.bounds.height - sheetView.bounds.height) else { return }
        var frame = sheetView.frame
        frame.origin.y = y
        sheetView.frame = frame
        let progress = ((sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)) / sheetView.bounds.height)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5 * (1 - progress))
    }

    func completeShow(_ velocity: CGFloat) {
        let distance = sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)

        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.25
        time = time > 0.25 ? 0.25 : time

        UIView.animate(withDuration: time) {
            self.sheetView.frame.origin.y = self.view.bounds.height - self.sheetView.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }

    func completeHide(_ velocity: CGFloat) {
        let distance = view.bounds.height - sheetView.frame.origin.y

        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.25
        time = time > 0.25 ? 0.25 : time

        UIView.animate(withDuration: time, animations: {
            self.sheetView.frame.origin.y = self.view.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            guard completed else { return }
            self.navigationController?.dismiss(animated: false, completion: nil)
        }
    }
}

