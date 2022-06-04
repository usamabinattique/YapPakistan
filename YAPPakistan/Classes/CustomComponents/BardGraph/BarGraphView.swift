//
//  BarGraphView.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//

import Foundation
import RxSwift
import RxCocoa

import RxDataSources
import YAPComponents
import RxTheme

public class BarGraphView: UIView {

    // MARK: - Views
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(BarGraphCollectionViewCell.self, forCellWithReuseIdentifier: BarGraphCollectionViewCell.defaultIdentifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 0, height: 0)
        collectionView.backgroundColor = .clear
        collectionView.setCollectionViewLayout(layout, animated: true)
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = minimumItemSpace
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(barSelected))
        tap.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tap)
        return collectionView
    }()

    lazy var toolTip: PopoverView = {
        let popover = PopoverView()
        popover.translatesAutoresizingMaskIntoConstraints = false
        return popover
    }()

    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.textColor = UIColor.appColor(ofType: .greyDark)
        label.font = .small //UIFont.appFont(forTextStyle: .small)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text =  "screen_home_display_text_nothing_to_report".localized
        return label
    }()

    lazy var monthLabel: UILabel = UIFactory.makeLabel(font: .small, alignment: .center) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center)

    // MARK: - Properties
    fileprivate lazy var dataSubject: BehaviorSubject<[SectionTransaction]> = {
        let subject = BehaviorSubject<[SectionTransaction]>(value: [])
        return subject
    }()

    fileprivate lazy var currentBalanceSubject: BehaviorSubject<Balance?> = {
        let subject = BehaviorSubject<Balance?>(value: nil)
        return subject
    }()

    fileprivate var minimumItemSpace: CGFloat {
        return 5
    }

    public var barWidth: CGFloat = 8 {
        didSet {
            (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: barWidth, height: 70)
        }
    }

    public var rightPadding: CGFloat = UIScreen.main.bounds.width/2

    var visibleIndexPaths: [IndexPath] {
        return collectionView.indexPathsForVisibleItems
    }

    private var balance: Balance?
    var scrollDisplayLink: CADisplayLink!
    var scrollRate: CGFloat = 0
    var panGestureRecognizer: UIPanGestureRecognizer!
    private var disposeBag = DisposeBag()
    var selectMode = false
    var lastSelectedCell = IndexPath()
    var selectedSectionIndexSubject = PublishSubject<Int>()
    var selectedIndexPathAtLocationSubject = PublishSubject<IndexPath>()
    let selectRecentItemSubject = PublishSubject<[SectionTransaction]>()
    var isSelectedByGraph = false
    var maxTransactionAmount: Double?
    private var themeService: ThemeService<AppTheme>!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(theme:ThemeService<AppTheme>) {
        super.init(frame: .zero)
        self.themeService = theme
        commonInit()
        setupTheme()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
        setupSensitiveViews()
        bind()
        setupGestureView()
        backgroundColor = .clear
        bindMostRecentItem()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [placeholderLabel.rx.textColor, monthLabel.rx.textColor])
           // .bind({ UIColor($0.primary) }, to: [showButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }

    public func bindMostRecentItem() {
        dataSubject
            .filter { $0.count > 0 }
            .do(onNext: { [weak self] _ in self?.alpha = 0 })
            .delay(.milliseconds(10), scheduler: MainScheduler.instance)
            .bind(to: selectRecentItemSubject)
            .disposed(by: disposeBag)

        let sharedObservable = selectRecentItemSubject.share(replay: 1, scope: .whileConnected)
        sharedObservable
            .subscribe(onNext: { [weak self] sectionedTransactions in
                let lastItem = sectionedTransactions.count - 1
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    let lastIndexPath = IndexPath(item: lastItem, section: 0)
                    self.collectionView.selectItem(at: lastIndexPath, animated: true, scrollPosition: .right)
                    self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: lastIndexPath)
                    self.collectionView.contentOffset = CGPoint(x: (self.collectionView.contentOffset.x + self.rightPadding), y: 0)
                    if let lastCell = self.collectionView.cellForItem(at: lastIndexPath) {
                        self.moveToolTip(at: lastIndexPath, lastCell)
                    }
                }
            }).disposed(by: disposeBag)

        sharedObservable
            .delay(.milliseconds(600), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.alpha = 1
            }).disposed(by: disposeBag)
    }

    public override func layoutSubviews() {
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: barWidth, height: 70)
    }

    // MARK: - Setup
    private func setupViews() {
        addSubview(collectionView)
        addSubview(toolTip)
        addSubview(monthLabel)
    }

    private func setupConstraints() {
        collectionView.alignEdgesWithSuperview([.left, .bottom, .right], constants: [0, 27, 0])
            .alignEdgeWithSuperview(.top, .greaterThanOrEqualTo, constant: 0)
        collectionView.height(constant: 70)
        monthLabel.alignEdgesWithSuperview([.left, .bottom, .right])
        monthLabel.centerHorizontallyInSuperview()
        height(constant: 170)
    }
    
    private func setupSensitiveViews() {
        //UIView.markSensitiveViews([toolTip])
    }

    private func bind() {
        dataSubject
            .do(onNext: { [unowned self] transactions in self.clearCollectionViewSelection(); self.maxTransactionAmount = transactions.map { $0.closingBalance }.max() })
            .bind(to: collectionView.rx.items) { [weak self] collectionView, item, transaction in
                guard let `self` = self,
                    let maxAmount = self.maxTransactionAmount else { return UICollectionViewCell() }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BarGraphCollectionViewCell.defaultIdentifier, for: IndexPath(item: item, section: 0)) as! BarGraphCollectionViewCell
                cell.configure(with: transaction.amountPercentage(withRespectTo: maxAmount), theme: self.themeService)
                return cell
        }.disposed(by: disposeBag)

        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            if let cell = self?.collectionView.cellForItem(at: indexPath) {
                self?.moveToolTip(at: indexPath, cell)
            }
        }).disposed(by: disposeBag)

        bindLeftInset()
        bindUserInteraction()
        bindSelectedItemToolTipPosition()
    }

    func bindLeftInset() {
        dataSubject
            .map { $0.count }
            .map { [weak self] transactionsCount -> CGFloat? in
                guard let `self` = self else { return nil }
                return (self.barWidth * CGFloat(transactionsCount)) + (self.minimumItemSpace * CGFloat(transactionsCount - 1))
        }
        .unwrap()
        .map { [weak self] graphWidth -> CGFloat? in
            guard let `self` = self else { return nil }
            return graphWidth > self.collectionView.bounds.width ? nil : self.collectionView.bounds.width - graphWidth }
            .unwrap()
            .subscribe(onNext: { [weak self] leftInset in
                guard let `self` = self else { return }
                (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: self.rightPadding)
            }).disposed(by: disposeBag)

        currentBalanceSubject.subscribe(onNext: { [weak self] balance in
            self?.balance = balance
        }).disposed(by: disposeBag)
    }

    func bindUserInteraction() {
        Observable.merge(collectionView.rx.itemSelected.asObservable(),
                         selectedIndexPathAtLocationSubject)
            .filter { [unowned self] _ in
                if self.isSelectedByGraph {
                    self.isSelectedByGraph = false
                    return false
                }
                return true
        }
        .flatMap { [unowned self] indexPath in self.reversedIndex(indexPath) }.bind(to: selectedSectionIndexSubject).disposed(by: disposeBag)
    }

    private func reversedIndex(_ indexPath: IndexPath) -> Observable<Int> {
        return dataSubject.map { ($0.count - 1) - indexPath.item }
    }

    public func selectedItem(at index: Int) {
        if let transactionsCount = try? dataSubject.value().count {
            let indexPath = IndexPath(item: (transactionsCount - 1) - index, section: 0)
            isSelectedByGraph = true
            selectCell(indexPath, scrollPosition: .centeredHorizontally)
        }
    }

    func bindSelectedItemToolTipPosition() {
        Observable.merge(collectionView.rx.didEndDecelerating.map { _ in () },
                         collectionView.rx.didEndDragging.map { _ in () },
                         collectionView.rx.didEndDisplayingCell.map { _ in () },
                         collectionView.rx.didEndScrollingAnimation.map { _ in () }) .subscribe(onNext: { [weak self] in
                            if let selectedIndexPath = self?.collectionView.indexPathsForSelectedItems?.first,
                                let cell = self?.collectionView.cellForItem(at: selectedIndexPath) {
                                self?.moveToolTip(at: selectedIndexPath, cell)
                            }
                         }).disposed(by: disposeBag)
    }

    func clearCollectionViewSelection() {
        collectionView.indexPathsForSelectedItems?
            .forEach { self.collectionView.deselectItem(at: $0, animated: false) }
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let topSpacing: CGFloat = 70
        let frame = CGRect(x: 0, y: -topSpacing, width: self.frame.size.width, height: self.frame.size.height + topSpacing)
        return frame.contains(point)
    }

    @objc
    private func barSelected() {
        toolTip.isPopoverHidden = false
    }
    
    
    
}

extension BarGraphView {
    func setupGestureView() {
        collectionView.isScrollEnabled = false
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(toSelectCells:)))
        collectionView.addGestureRecognizer(panGestureRecognizer)
    }

    func didChangeGestureRecognizer() {
        let location = panGestureRecognizer.location(in: collectionView)

        var rect = self.collectionView.bounds
        rect.size.width -= self.collectionView.contentInset.left

        let scrollZoneWidth = rect.size.width / 6
        let leftScrollBeginning = collectionView.contentOffset.x + collectionView.contentInset.left + scrollZoneWidth
        let rightScrollBeginning = collectionView.contentOffset.x + collectionView.contentInset.left + rect.size.width - scrollZoneWidth

        if location.x >= rightScrollBeginning {
            scrollRate = (location.x - rightScrollBeginning) / scrollZoneWidth
        } else if location.x <= leftScrollBeginning {
            scrollRate = (location.x - leftScrollBeginning) / scrollZoneWidth
        } else {
            scrollRate = 0
        }
    }

    @objc func scrollCollectionView(timer: Timer) {
        let currentOffset = self.collectionView.contentOffset
        var newOffset = CGPoint(x: currentOffset.x + scrollRate * 10, y: currentOffset.y)

        if newOffset.x < -collectionView.contentInset.left {
            newOffset.x = -collectionView.contentInset.left
        } else if collectionView.contentSize.width + collectionView.contentInset.right < collectionView.frame.size.width {
            newOffset = currentOffset
        } else if newOffset.x > (collectionView.contentSize.width + collectionView.contentInset.right) - collectionView.frame.size.width {
            newOffset.x = (collectionView.contentSize.width + collectionView.contentInset.right) - collectionView.frame.size.width
        }
        collectionView.contentOffset = newOffset

        if let indexPathAtLocation = collectionView.indexPathForItem(at: panGestureRecognizer.location(in: collectionView)) {
            selectCell(indexPathAtLocation)
        }
    }

    fileprivate func moveToolTip(at indexPath: IndexPath, _ cell: UICollectionViewCell) {
        if let selectedTransaction = try? dataSubject.value()[indexPath.item] {
            toolTip.rx.dateText.onNext(selectedTransaction.formattedDate)
            toolTip.rx.amountText.onNext(selectedTransaction.formattedClosingBalance)
            monthLabel.text = selectedTransaction.formattedMonthDate
            let newX = cell.frame.origin.x - collectionView.contentOffset.x
            if let maxAmount = maxTransactionAmount {
                //toolTip.origin = CGPoint(x: newX + 4, y: CGFloat(70 * (1 - selectedTransaction.amountPercentage(withRespectTo: maxAmount))))
                let y = CGFloat(70 * (1 - selectedTransaction.amountPercentage(withRespectTo: maxAmount))) + 70
                toolTip.origin = CGPoint(x: newX + 4, y: y)
            }
        }
    }

    func selectCell(_ indexPath: IndexPath, scrollPosition: UICollectionView.ScrollPosition = .top) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: scrollPosition)
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) {
            moveToolTip(at: indexPath, cell)
        }
    }

    @objc func didPan(toSelectCells panGesture: UIPanGestureRecognizer) {
        let location: CGPoint = panGesture.location(in: collectionView)
        if let indexPath: IndexPath = collectionView.indexPathForItem(at: location) {
            self.selectedIndexPathAtLocationSubject.onNext(indexPath)
            self.selectCell(indexPath)
        }

        switch panGestureRecognizer.state {
        case .began:
            scrollDisplayLink = CADisplayLink(target: self, selector: #selector(scrollCollectionView(timer:)))
            scrollDisplayLink.add(to: RunLoop.main, forMode: .default)
            break
        case .changed:
            didChangeGestureRecognizer()
        case .ended:
            scrollDisplayLink.invalidate()
            scrollDisplayLink = nil
            scrollRate = 0
        default:
            break
        }
    }

    private func addDefaultTransaction(to sectionTransactions: [SectionTransaction]) -> [SectionTransaction] {
        let emptySectionTransaction = SectionTransaction(day: Date(), transactions: [])
        guard let lastTransaction = sectionTransactions.last,
            lastTransaction.date.startOfDay != Date().startOfDay,
            lastTransaction.isNoTransactionToday else { return sectionTransactions + [emptySectionTransaction] }
        return sectionTransactions
    }
}

// MARK: - BarGraphView + Rx
extension Reactive where Base: BarGraphView {
    var transactionsObserver: AnyObserver<[SectionTransaction]> {
        return base.dataSubject.asObserver()
    }

    var currentBalanceObserver: AnyObserver<Balance?> {
        return base.currentBalanceSubject.asObserver()
    }

    var itemSelected: ControlEvent<IndexPath> {
        return base.collectionView.rx.itemSelected
    }

    var selectedSectionIndex: Observable<Int> {
        return base.selectedSectionIndexSubject
    }

    var panGesture: ControlEvent<UIPanGestureRecognizer> {
        return base.panGestureRecognizer.rx.event
    }

    var didEndDecelerating: ControlEvent<Void> {
        return base.collectionView.rx.didEndDecelerating
    }

    var didEndScrollingAnimation: ControlEvent<Void> {
        return base.collectionView.rx.didEndScrollingAnimation
    }

    var selectRecentItemObserver: AnyObserver<[SectionTransaction]> {
        return base.selectRecentItemSubject.asObserver()
    }
}
