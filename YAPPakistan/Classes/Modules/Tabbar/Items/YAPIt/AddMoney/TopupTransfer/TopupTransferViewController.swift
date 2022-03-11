//
//  TopupTransferViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 07/03/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class TopupTransferViewController: KeyboardAvoidingViewController {
    
    //MARK: - UIViews
    
    lazy var cardStackView = UIStackViewFactory.createStackView(with: .horizontal, distribution: .fillEqually, spacing: 25)
    lazy var cardDetailsStackView = UIStackViewFactory.createStackView(with: .vertical, spacing: 6)
    lazy var cardImageView = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    lazy var cardTitle = UIFactory.makeLabel(font: .small)//.primaryDark
    lazy var cardPANNumber = UIFactory.makeLabel(font: .micro)//.greyDark
    lazy var transactionFeeStackView = UIStackViewFactory.createStackView(with: .vertical, distribution: .fillEqually, spacing: 10)
    lazy var amountTitle = UIFactory.makeLabel(font: .small, alignment: .center)//.primaryDark
    lazy var balance: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    lazy var transactionFee: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center)//
    lazy var nextButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_next".localized, isEnable: false)
    
    private lazy var amountAlert: YAPAlert = {
        return YAPAlert()
    }()
    
    lazy var secureByYapView: SecureByYAPView = {
        let view = SecureByYAPView()
        return view
    }()
    
    private lazy var amountView: AmountView = {
        let vm = AmountViewModel(heading: "PKR")
        let view = AmountView(viewModel: vm)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var denominationAmountView: DenominationAmountCollectionView = {
        let view = DenominationAmountCollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var backButton: UIButton!
    
    // MARK: - Properties
    public let viewModel: TopupTransferViewModel
    private let themeService: ThemeService<AppTheme>
    let disposeBag: DisposeBag
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: TopupTransferViewModel) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        //        viewModel.inputs.requestProductLimitObserver.onNext(())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
}

// MARK: - Setup
extension TopupTransferViewController: ViewDesignable {
    
    func setupSubViews() {
        view.backgroundColor = .white
        
        cardDetailsStackView.addArrangedSubview(cardTitle)
        cardDetailsStackView.addArrangedSubview(cardPANNumber)
        cardDetailsStackView.addArrangedSubview(secureByYapView)
        cardStackView.addArrangedSubview(cardImageView)
        cardStackView.addArrangedSubview(cardDetailsStackView)
        
        view.addSubview(cardStackView)
        view.addSubview(amountTitle)
        view.addSubview(amountView)
        
        view.addSubview(denominationAmountView)
        view.addSubview(nextButton)
        transactionFeeStackView.addArrangedSubview(transactionFee)
        transactionFeeStackView.addArrangedSubview(balance)
        view.addSubview(transactionFeeStackView)
        
        backButton = addBackButton(of: .backEmpty)
        self.denominationAmountView.themeService = self.themeService
    }
    
    func setupConstraints() {
        
        cardStackView
            .alignEdgeWithSuperviewSafeArea(.top, .lessThanOrEqualTo, constant: 20)
            .alignEdgeWithSuperviewSafeArea(.top, .greaterThanOrEqualTo, constant: 6)
            .height(constant: 80)
            .width(constant: 260)
            .centerHorizontallyInSuperview()
        
        cardDetailsStackView
            .height(with: .height, ofView: cardStackView)
        
        amountTitle
            .toBottomOf(cardStackView, .lessThanOrEqualTo, constant: 26)
            .toBottomOf(cardStackView, .greaterThanOrEqualTo, constant: 6)
            .height(constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
        
        amountView
            .toBottomOf(amountTitle, constant: 15)
            .centerHorizontallyInSuperview()
        
        denominationAmountView
            .toBottomOf(amountView, constant: 30)
            .height(constant: 22)
            .alignEdgesWithSuperview([.left, .right], constants: [50, 50])
        
        transactionFeeStackView
            .toBottomOf(denominationAmountView, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .height(.greaterThanOrEqualTo, constant: 20, priority: .defaultLow)
        
        transactionFee
            .width(with: .width, ofView: transactionFeeStackView)
        
        balance
            .width(with: .width, ofView: transactionFeeStackView)
        
        nextButton
            .toBottomOf(balance, .greaterThanOrEqualTo, constant: 16)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 192)
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 15)
    }
    
    func setupBindings() {
        
        self.title = "Top up using card"
        
        //denominationView binding
        denominationAmountView.rx.modelSelected.map { $0.replace(string: "-", replacement: "") }.map { $0.replace(string: "+", replacement: "") }
        .map { CurrencyFormatter.formatAmountInLocalCurrency(Double($0) ?? 0).amountFromFormattedAmount }
        .map { $0.removingGroupingSeparator().trimmingCharacters(in: .whitespacesAndNewlines) }
        .bind(to: amountView.amountTextField.rx.text).disposed(by: disposeBag)
        viewModel.outputs.denominationAmountViewModels.filter { $0.count > 0 }.bind(to: denominationAmountView.rx.items).disposed(by: disposeBag)
        
        //amountView binding
        viewModel.outputs.amountTitle.bind(to: amountTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.activateAction.bind(to: nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        amountView.rx.amount.skip(1)
            .do(onNext: { [weak self] _ in self?.amountView.isInputValid = true })
            .bind(to: viewModel.inputs.enteredAmountObserver)
            .disposed(by: disposeBag)
        
                viewModel.outputs.isValidAmount
                .map { argv in argv.0 }
                .unwrap()
                .bind(to: amountView.rx.isInputValid)
                .disposed(by: disposeBag)
        
        viewModel.outputs.isValidAmount
            .filter { $0.0! == false }
            .map { argv in return argv.1 }
            .unwrap()
            .bind(to: view.rx.showAlert(ofType: .error))
            .disposed(by: disposeBag)
        
        viewModel.outputs.isValidMaxLimit
            .filter { $0.0 == false }
            .do(onNext: { [weak self] _ in self?.amountView.isInputValid = false })
            .map { argv in return argv.1 }
            .unwrap()
            .bind(to: view.rx.showAlert(ofType: .error))
            .disposed(by: disposeBag)
        
        viewModel.outputs.amountError
            .map{ $0 == nil }
            .do(onNext: { [weak self] in self?.amountView.isInputValid = $0 })
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.outputs.amountError
                .subscribe(onNext: { [weak self] in
                    guard let `self` = self else { return }
                    guard $0 != nil else {
                        self.amountAlert.hide()
                        return
                    }
                    self.amountAlert.cancelAnimations()
                    self.amountAlert.show(inView: self.view, type: .error, text: $0!, autoHides: false)
                })
                .disposed(by: disposeBag)
                
                //nextButton Actions
                nextButton.rx.tap.do(onNext: { [weak self] _ in self?.dismissKeyboard() }).bind(to: viewModel.inputs.actionButtonObserver).disposed(by: disposeBag)
                
                //cardView binding
                viewModel.outputs.cardImage.bind(to: cardImageView.rx.image).disposed(by: disposeBag)
                    viewModel.outputs.cardTitle.bind(to: cardTitle.rx.text).disposed(by: disposeBag)
                    viewModel.outputs.panNumber.bind(to: cardPANNumber.rx.text).disposed(by: disposeBag)
                    //
                    //general binding
                    viewModel.outputs.availableBalance.bind(to: balance.rx.attributedText).disposed(by: disposeBag)
                    viewModel.outputs.transactionFee.bind(to: transactionFee.rx.attributedText).disposed(by: disposeBag)
                    viewModel.outputs.screenTitle.unwrap().bind(to: self.rx.title).disposed(by: disposeBag)
                    
                    viewModel.outputs.loading.subscribe(onNext: { flage in
                        switch flage {
                        case true:
                            YAPProgressHud.showProgressHud()
                        case false:
                            YAPProgressHud.hideProgressHud()
                        }
                    }).disposed(by: disposeBag)
                    
                    viewModel.outputs.error
                    .bind(to: view.rx.showAlert(ofType: .error, from: .top))
                    .disposed(by: disposeBag)
                    
                    viewModel.outputs.becomeResponder.filter{ $0 }.subscribe(onNext: { [weak self] _ in self?.amountView.amountTextField.becomeFirstResponder() }).disposed(by: disposeBag)
        
        self.backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: nextButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: nextButton.rx.disabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }
    
}
