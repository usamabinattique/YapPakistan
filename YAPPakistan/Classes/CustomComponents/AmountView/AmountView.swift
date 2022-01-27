//
//  AmountView.swift
//  YAPComponents
//
//  Created by Yasir on 24/01/2022.
//


import Foundation
import RxSwift
import RxCocoa
import YAPComponents


//TODO: Remove viewmodel dependancy and use reactive extension

open class AmountView: UIView {
    public lazy var headingLabel: UILabel = UIFactory.makeLabel(font:.micro, alignment: .center) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)

    public lazy var amountTextField: UITextField = {
        let textfield = UITextField()
        textfield.textAlignment = .center
        textfield.autocorrectionType = .no
        textfield.keyboardType = .decimalPad
        textfield.adjustsFontSizeToFitWidth = true
        textfield.minimumFontSize = 10
        textfield.font = .title2
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()

    public lazy var amountContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.36) //UIColor.greyLight.withAlphaComponent(0.36)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let disposeBag = DisposeBag()
    private var viewModel: AmountViewModelType?
    public var allowedDecimal: Int = 2 {
        didSet {
            amountTextField.placeholder = CurrencyFormatter.defaultFormattedFee.split(separator: " ").last.map { String($0) }
        }
    }
    
    public var isCurrencyHidden: Bool = false {
        didSet {
            headingLabel.isHidden = isCurrencyHidden
        }
    }
    
    private let formattedAmountSubject = BehaviorSubject<String?>(value: "")

    public var formattedAmount: Observable<String?> { formattedAmountSubject.asObservable() }

    public init(viewModel: AmountViewModelType?) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open override func draw(_ rect: CGRect) {
        amountContainerView.layer.cornerRadius = 8
        amountContainerView.clipsToBounds = true
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        isInputValid = true
        setupViews()
        setupConstraints()
        localize()
        bind(viewModel: viewModel)
    }

    func setupViews() {
        amountContainerView.addSubview(amountTextField)
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(amountContainerView)
        amountTextField.keyboardType = UIKeyboardType.decimalPad
        amountTextField.delegate = self
        addSubview(stackView)
    }

    func setupConstraints() {
        stackView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom])

        amountContainerView
            .height(constant: 50)
            .width(constant: 175)

        amountTextField
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [10, 10, 10, 10])

        headingLabel
            .height(constant: 18)
    }

    func localize() {
        headingLabel.text =  "common_display_text_currency".localized
    }

    func bind(viewModel: AmountViewModelType?) {
        guard let viewModel = viewModel else { return }
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amountTextField.rx.text).disposed(by: disposeBag)
        viewModel.outputs.heading.subscribe(onNext: { [weak self] in
            self?.allowedDecimal = CurrencyFormatter.decimalPlaces(for: $0 ?? "AED")
        }).disposed(by: disposeBag)
        bindAmountFieldFormatting()
    }

    func bindAmountFieldFormatting() {
        func cacheFractionPart(string: String) -> String? {
            let currencyDecimalSeparator = localeNumberFormatter.currencyDecimalSeparator ?? "."
            return string.contains(currencyDecimalSeparator) ? currencyDecimalSeparator + (string.components(separatedBy: currencyDecimalSeparator).last ?? "") : nil
        }

        Observable
            .merge(
                amountTextField.rx.observe(String.self, "text"),
                amountTextField.rx.text.asObservable())
            .distinctUntilChanged()
            .unwrap()
            .map { $0.removingGroupingSeparator() }
            .map { (localeNumberFormatter.number(from: $0).flatMap { Double(exactly: $0) }, cacheFractionPart(string: $0)) }
            .map { (params: (Double?, String?)) -> String? in
                params.1 != nil ? params.0.map { $0<0 ? ceil($0):floor($0) }.map { $0.withGroupingSeparator() + params.1! } : params.0.map { $0.withGroupingSeparator() } }
            .bind(to: amountTextField.rx.text).disposed(by: disposeBag)
    }

    public var isInputValid: Bool = false {
        didSet {
            if isInputValid {
                amountContainerView.layer.borderColor = UIColor.clear.cgColor
                amountContainerView.layer.borderWidth = 1.0
            } else {
                amountContainerView.layer.borderColor = UIColor.red.cgColor
                amountContainerView.layer.borderWidth = 1.0
            }
        }
    }
}

extension AmountView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currencyDecimalSeparator = localeNumberFormatter.currencyDecimalSeparator ?? "."
        guard textField.text?.removingGroupingSeparator().count ?? 0 < 10 || string.count == 0 else { return false }
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }

        let newText = oldText.replacingCharacters(in: r, with: string).removingGroupingSeparator()
        let isNumeric = newText.isEmpty || (localeNumberFormatter.number(from: newText) != nil)
        let numberOfDots = newText.components(separatedBy: currencyDecimalSeparator).count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: Character(currencyDecimalSeparator)) {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        
        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= allowedDecimal
    }
}

// MARK: -
extension Reactive where Base: AmountView {
    public var isInputValid: Binder<Bool> {
        return Binder(self.base) { textField, isValid in
            textField.isInputValid = isValid
        }
    }

    public var currency: Binder<String?> {
        return self.base.headingLabel.rx.text
    }

    public var amount: Observable<Double> {
        return Observable
            .merge(
                self.base.amountTextField.rx.observe(String.self, "text"),
                self.base.amountTextField.rx.text.asObservable())
            .distinctUntilChanged()
            .map { $0?.removingGroupingSeparator() }
            .map { $0.flatMap { localeNumberFormatter.number(from: $0) } }
            .map { $0.flatMap { Double(exactly: $0) } ?? 0 }
    }
}
