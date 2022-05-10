//
//  ProgressViewSection.swift
//  YAPKit
//
//  Created by Ahmer Hassan on 15/09/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import UIKit
import RxSwift
import YAPCore
import YAPComponents

protocol ProgressViewSectionDelegate: AnyObject {
    func didTapSection(_ section: ProgressViewSection)
}

public class ProgressViewSection: UIView {
    
    public var hideSectionItemsObserver: AnyObserver<Bool> {showSectionItemsSubject.asObserver()}
    private let showSectionItemsSubject = BehaviorSubject<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    public var titleLabel: UILabel {
        return sectionTitleLabel
    }
    
    private var sectionTitleLabel = UILabel()
    
    public var titleEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var titleAlignment: AlignmentType = .center {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var imageView: UIImageView {
        return sectionImageView
    }
    
    var tapGestureRecognizer: UITapGestureRecognizer {
        return tapRecognizer
    }
    
    private lazy var tapRecognizer = TapGestureRecognizer(target: self,
                                                          action: #selector(didTap))
    
    var labelConstraints = [NSLayoutConstraint]() {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
        }
    }
    
    weak var delegate: ProgressViewSectionDelegate?
    
    private var sectionImageView = UIFactory.makeImageView() //UIImageViewFactory.createImageView()
    
    private var layoutProvider: LayoutProvidable = LayoutProvider.shared
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(layoutProvider: LayoutProvidable) {
        self.init(frame: .zero)
        self.layoutProvider = layoutProvider
    }
    
    private func initialize() {
        backgroundColor = .black
        layer.masksToBounds = true
        addSubview(sectionImageView)
        addSubview(sectionTitleLabel)
        addGestureRecognizer(tapGestureRecognizer)
        sectionTitleLabel.textColor = .white
        sectionTitleLabel.font = .small //UIFont.appFont(forTextStyle: .small)
        showSectionItemsSubject.subscribe(onNext: {[unowned self] in showImage($0)
            showTitle($0)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Tap handler
    
    @objc
    private func didTap() {
        delegate?.didTapSection(self)
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        labelConstraints = layoutProvider.anchorToSuperview(sectionTitleLabel,
                                                            withAlignment: titleAlignment,
                                                            insets: titleEdgeInsets)
        
        sectionTitleLabel
            .alignEdgesWithSuperview([.left,.right,.top, .bottom],constants:[23,0,0,0])
        
        
        sectionImageView.frame = layoutProvider.sectionImageViewFrame(self)
        sendSubviewToBack(sectionImageView)
    }
    
    // MARK: - Main Methods
    
    public func setTitle(_ title: String?) {
        sectionTitleLabel.text = title
    }
    
    public func setAttributedTitle(_ title: NSAttributedString?) {
        sectionTitleLabel.attributedText = title
    }
    
    public func setImage(_ url: String) {
        sectionImageView.loadImage(with: url) {[weak self] image, err, url in
            self?.sectionImageView.image = image?.withRenderingMode(.alwaysTemplate)
            self?.sectionImageView.tintColor = .white
        }
    }
    
    public func showImage(_ show: Bool) {
        sectionImageView.isHidden = show
    }
    
    public func showTitle(_ show: Bool) {
        sectionTitleLabel.isHidden = show
    }
}
