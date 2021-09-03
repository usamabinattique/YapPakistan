//
//  ViewController.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit
import RxSwift
import RxCocoa
//import Localize_Swift
/*
class ViewController: UIViewController {

    var viewModel: ViewModel?
    var navigator: Navigator!

    init(viewModel: ViewModel?, navigator: Navigator) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }

    let isLoading = BehaviorRelay(value: false)
    let error = PublishSubject<ApiError>()

    var automaticallyAdjustsLeftBarButtonItem = true
    var canOpenFlex = true

    var navigationTitle = "" {
        didSet {
            navigationItem.title = navigationTitle
        }
    }

    let spaceBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

    let emptyDataSetButtonTap = PublishSubject<Void>()
    var emptyDataSetTitle = R.string.localizable.commonNoResults.key.localized()
    var emptyDataSetDescription = ""
    //var emptyDataSetImage = R.image.image_no_result()
    var emptyDataSetImageTintColor = BehaviorRelay<UIColor?>(value: nil)

    let languageChanged = BehaviorRelay<Void>(value: ())

    let orientationEvent = PublishSubject<Void>()
    let motionShakeEvent = PublishSubject<Void>()
    
    lazy var backBarButton: BarButtonItem = {
        let view = BarButtonItem()
        view.title = ""
        return view
    }()
    lazy var closeBarButton: BarButtonItem = {
        let view = BarButtonItem(image: UIImage(named: ""),
                                 style: .plain,
                                 target: self,
                                 action: nil)
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        /// Do any additional setup after loading the view.
        makeUI()
        bindViewModel()

        /// Observe device orientation change
        NotificationCenter.default
            .rx.notification(UIDevice.orientationDidChangeNotification).mapToVoid()
            .bind(to: orientationEvent).disposed(by: rx.disposeBag)

        orientationEvent.subscribe { [weak self] (event) in
            self?.orientationChanged()
        }.disposed(by: rx.disposeBag)

        /// Observe application did become active notification
        NotificationCenter.default
            .rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe { [weak self] (event) in
                self?.didBecomeActive()
            }.disposed(by: rx.disposeBag)

        NotificationCenter.default
            .rx.notification(UIAccessibility.reduceMotionStatusDidChangeNotification)
            .subscribe(onNext: { (event) in
                print("Motion Status changed")
            }).disposed(by: rx.disposeBag)

        /// Observe application did change language notification
        NotificationCenter.default
            .rx.notification(NSNotification.Name(LCLLanguageChangeNotification))
            .subscribe { [weak self] (event) in
                self?.languageChanged.accept(())
            }.disposed(by: rx.disposeBag)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if automaticallyAdjustsLeftBarButtonItem {
            adjustLeftBarButtonItem()
        }
        updateUI()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    deinit { print("============== \(type(of: self)): Deinited ==============") }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //logDebug("\(type(of: self)): Received Memory Warning")
    }

    func makeUI() {
        hero.isEnabled = true
        navigationItem.backBarButtonItem = backBarButton

        motionShakeEvent.subscribe(onNext: { () in
            let theme = themeService.type.toggled()
            themeService.switch(theme)
        }).disposed(by: rx.disposeBag)

        themeService.rx
            .bind({ $0.primaryDark }, to: view.rx.backgroundColor)
            .bind({ $0.secondary }, to: [backBarButton.rx.tintColor, closeBarButton.rx.tintColor])
            .bind({ $0.text }, to: self.rx.emptyDataSetImageTintColorBinder)
            .disposed(by: rx.disposeBag)

        updateUI()
    }

    func bindViewModel() {
        viewModel?.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel?.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)

        languageChanged.subscribe(onNext: { [weak self] () in
            //self?.emptyDataSetTitle = R.string.localizable.commonNoResults.key.localized()
        }).disposed(by: rx.disposeBag)

        isLoading.subscribe(onNext: { isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
        }).disposed(by: rx.disposeBag)
    }

    func updateUI() {

    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            motionShakeEvent.onNext(())
        }
    }

    func orientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateUI()
        }
    }

    func didBecomeActive() {
        self.updateUI()
    }

    // MARK: Adjusting Navigation Item

    func adjustLeftBarButtonItem() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 { // Pushed
            self.navigationItem.leftBarButtonItem = nil
        } else if self.presentingViewController != nil { // presented
            self.navigationItem.leftBarButtonItem = closeBarButton
        }
    }

    @objc func closeAction(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController {

    var inset: CGFloat {
        return Configs.BaseDimensions.inset
    }

    func emptyView(withHeight height: CGFloat) -> View {
        let view = View(height:height)
        return view
    }

}

extension Reactive where Base: ViewController {

    /// Bindable sink for `backgroundColor` property
    var emptyDataSetImageTintColorBinder: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.emptyDataSetImageTintColor.accept(attr)
        }
    }
}
*/
