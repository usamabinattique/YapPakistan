//
//  HomeBalanceToolbarUpdated.swift
//  YAPPakistan
//
//  Created by Yasir on 28/04/2022.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import YAPCore
import YAPComponents

public final class HomeBalanceToolbarUpdated: UIView, MultiProgressViewDelegate {
    
    private var currency: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = "PKR"
      //  label.font = UIFont.appFont(ofSize: 32, weigth: .regular, theme: .main)
       /// label.textColor = .primaryDark
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    public var ammount: UILabel = {
        let label = UILabel()
        //label.textColor = .primaryDark
        label.font = .regular //UIFont.appFont(ofSize: 32, weigth: .regular, theme: .main)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var progressViewSection: ProgressViewSection?
    private var progressViewHeight: CGFloat = 25
    fileprivate var isProgressViewShrinked = false
    fileprivate var month: String = ""
    weak public var delegate: ProgressBarDidTapped?
    private var progressViewHeightConstraint: NSLayoutConstraint!
    fileprivate var sortedData = [Category]()
    var categorySections = [StorageProgressSection]()
    fileprivate var sectionCount = 0
    fileprivate var sectionColor = [String]()

    private lazy var stack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fillProportionally, spacing: 4, arrangedSubviews: [currency, ammount])
    private var isLoadingForFirstTime = true
    
    fileprivate lazy var progressView: MultiProgressView = {
        let progress = MultiProgressView()
        progress.trackBackgroundColor = .white
        progress.lineCap = .round
        //progress.cornerRadius = progressViewHeight / 4
        progress.cornerRadiusProperty = progressViewHeight / 4
        return progress
    }()
    
    let todaysBalanceTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .left, numberOfLines: 0, lineBreakMode: .byClipping, text: "screen_home_todays_balance_title".localized, alpha: 1, adjustFontSize: true) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .regular, alignment: .left, numberOfLines: 0, lineBreakMode: .byClipping, text: "screen_home_todays_balance_title".localized, alpha: 1.0, adjustFontSize: true)
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
        isUserInteractionEnabled = true
        setupSensitiveViews()
    }
    
    func setupSensitiveViews() {
        //UIView.markSensitiveViews([ammount, todaysBalanceTitleLabel, currency])
    }
    
    // MAKR: Layouting
    
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view == self, let subView = view?.subviews.first else { return view }
        return subView
    }
}

// MARK: View setup

private extension HomeBalanceToolbarUpdated {
    func setupViews() {
        addSubview(stack)
        addSubview(todaysBalanceTitleLabel)
        addSubview(backgroundView)
        backgroundView.addSubview(progressView)
        progressView.backgroundColor = .white
    }
    
    @objc
    func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.delegate?.progressViewDidTapped(viewForMonth: month)
    }
    
    func setupConstraints() {
        stack
            .alignEdgesWithSuperview([.left, .top], constants: [19, 19])
            .height(constant: 38)
        
        todaysBalanceTitleLabel
            .toBottomOf(stack)
            .alignEdgeWithSuperview(.left, constant: 19)
        
        backgroundView.anchor(top: todaysBalanceTitleLabel.bottomAnchor,
                              left: safeAreaLayoutGuide.leftAnchor,
                              right: safeAreaLayoutGuide.rightAnchor,
                              paddingTop: 20,
                              paddingLeft: 25,
                              paddingRight: 25
        )
        
        progressView.anchor(top: backgroundView.topAnchor,
                            left: backgroundView.leftAnchor,
                            bottom: backgroundView.bottomAnchor,
                            right: backgroundView.rightAnchor,
                            paddingTop: 0,
                            paddingLeft: 0,
                            paddingBottom: 0,
                            paddingRight: 0,
                            height: 24
        )
        
        progressViewHeightConstraint = progressView.heightAnchor.constraint(equalToConstant: 24)
        progressViewHeightConstraint.isActive = true
    }
    
    func animateMonthlyAnalytics(monthData: MonthData) {
        sortedData = monthData.categories.sorted { $0.categoryWisePercentage > $1.categoryWisePercentage }
        if sortedData.count > 10 {
            maintainLargeData()
        }
        sectionColor = Array(repeating: "", count: sectionCount)
        (0..<sortedData.count).forEach { index in
            sectionColor[index] = sortedData[index].categoryColor
        }
        if isLoadingForFirstTime {
            isLoadingForFirstTime = false
            progressView.dataSource = self
        }
        var progressPercentage: [Float] = Array(repeating: 0.0, count: sortedData.count)
        (0..<sortedData.count).forEach { index in
            progressPercentage[index] = Float(sortedData[index].categoryWisePercentage)/100
        }

        DispatchQueue.main.async { [weak self] in
            self?.animateBar(progressPercentage: progressPercentage)
        }
        self.progressViewSection?.setImage(sortedData[0].logoURL)
        setupProgressViewItems()
    }
    
    func setupBarData(section: Int) {
        if (section != 0){
            progressViewSection?.hideSectionItemsObserver.onNext(true)
        }
    }
    
    func setupProgressViewItems() {
        if !isProgressViewShrinked {
            self.progressViewSection?.setTitle("\(Int(sortedData[0].categoryWisePercentage))%")
        }
    }
    
    func animateBar(progressPercentage: [Float]){
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 1,
                       animations: {[unowned self] in
                        self.progressView.resetProgress()
                        (0..<sortedData.count).forEach {[weak self] index in
                            self?.progressView.setProgress(section: index, to: progressPercentage[index])
                        }
                        
                        (0..<categorySections.count).forEach {[weak self] index in
                            self?.categorySections[index].backgroundColor = hexStringToUIColor(hex: self?.sectionColor[index] ?? "")
                        }
                        
                       })
    }
    
    func setupCategoryImage(_ url: String) {
        self.progressViewSection?.setImage(url)
    }
}

extension HomeBalanceToolbarUpdated: MultiProgressViewDataSource {
    public func numberOfSections(in progressBar: MultiProgressView) -> Int {
        return sectionCount
    }
    
    public func progressView(viewForSection section: Int, title: String?) -> ProgressViewSection {
        let bar = StorageProgressSection()
        if section == 0 {
            self.progressViewSection = bar
        }
        categorySections.append(bar)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        bar.addGestureRecognizer(tap)
        bar.configure()
        return bar
    }
}

// MARK: Data Control

public extension HomeBalanceToolbarUpdated {
    
    func setDate(date: NSMutableAttributedString) {
        todaysBalanceTitleLabel.attributedText = date
    }
    
    func setBalance(balance: String) {
        var finalBalance: Balance {
            return Balance(balance: balance, currencyCode: "PKR", currencyDecimals: "2", accountNumber: "")
        }
        let text = finalBalance.formattedBalance(showCurrencyCode: false, shortFormat: true)
        let attributedString = NSMutableAttributedString(string: text)
        guard let decimal = text.components(separatedBy: ".").last else { return }
        attributedString.addAttribute(.font, value: UIFont.regular/*appFont(ofSize: 18, weigth: .regular, theme: .main) */, range: NSRange(location: text.count-decimal.count, length: decimal.count))
        ammount.attributedText = attributedString
    }
    
    func shrinkProgressView(_ shrink: Bool){
        
        if shrink {
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.progressViewHeightConstraint.constant = 12
                self?.progressView.cornerRadius = 12/2
                self?.layoutIfNeeded()
                
            })
        }
        else {
            
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.progressViewHeightConstraint.constant = 25
                self?.progressView.cornerRadius = 25/4
                self?.layoutIfNeeded()
            })
        }
        shrink ? progressViewSection?.hideSectionItemsObserver.onNext(true) : progressViewSection?.hideSectionItemsObserver.onNext(false)
        layoutSubviews()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func maintainLargeData() {
        let arraySlice = sortedData[0..<9]
        sortedData = Array(arraySlice)
        let spendingsArray = sortedData.map {$0.categoryWisePercentage}
        let sum = spendingsArray.reduce(0, +)
        self.sortedData.append(self.createOthersCategory(remainingPercentage: 100.00 - sum))
    }
    
    func createOthersCategory(remainingPercentage: Double) -> Category {
        return Category(title: "Others", txnCount: 00, totalSpending: 00, totalSpendingInPercentage: 0.0, logoURL: "", yapCategoryID: 0, date: "", categoryWisePercentage: remainingPercentage, noOfCategories: 0, categoryColor: "#AF216A")
    }
}

// MARK: Reactive

public extension Reactive where Base: HomeBalanceToolbarUpdated {
    
    var date: Binder<NSMutableAttributedString> {
        return Binder(self.base) { toolbar, date in
            toolbar.setDate(date: date)
        }
    }
    
    var balance: Binder<String> {
        return Binder(self.base) { toolbar, balance in
            toolbar.setBalance(balance: balance)
        }
    }
    
    var month: Binder<String> {
        return Binder(self.base) { toolbar,month in
            toolbar.month = month
        }
    }
    
    var shrink: Binder<Bool> {
        return Binder(self.base) { toolbar,shrink in
            toolbar.shrinkProgressView(shrink)
            toolbar.isProgressViewShrinked = shrink
        }
    }
    
    var monthData: Binder<(MonthData?, Int?)> {
        return Binder(self.base) { toolBar,monthData in
            if let monthlyAnalytics = monthData.0 {
                toolBar.progressView.isHidden = false
                toolBar.animateMonthlyAnalytics(monthData: monthlyAnalytics)
                toolBar.setupBarData(section: monthData.1 ?? 0)
            }
            else {
                toolBar.progressView.isHidden = true
            }
        }
    }
    
    var numberOfSections: Binder<Int?> {
        return Binder(self.base) { toolBar,section in
            if section ?? 0 > 9 {
                toolBar.sectionCount = 10
            }
            else {
                toolBar.sectionCount = section ?? 0
            }
        }
    }
    
    var categoryImage: Binder<String> {
        return Binder(self.base) { toolBar,url in
            toolBar.setupCategoryImage(url)
        }
    }
}
