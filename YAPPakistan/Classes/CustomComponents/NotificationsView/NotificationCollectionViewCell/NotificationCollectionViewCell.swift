//
//  NotificationCollectionViewCellViewModelType.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import YAPComponents
import RxTheme

class NotificationCollectionViewCell: RxUICollectionViewCell {
    
    private lazy var cornerRadiusView: UIView = {
        let view = UIView()
     //   view.backgroundColor = UIColor.appColor(ofType: .paleLilac)
        view.clipsToBounds = true
        view.layer.cornerRadius = 12.0
        view.layer.masksToBounds = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.sharedImage(named: "icon_close_dark_purple")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var animationImageView: UIImageView = UIFactory.makeImageView() //UIImageViewFactory.createImageView()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var notificationTitle: UILabel = UIFactory.makeLabel(font: .micro) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .micro)
    
    private lazy var notificationDescription: UILabel = UIFactory.makeLabel(font: .micro, numberOfLines: 0, adjustFontSize: true) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, numberOfLines: 0, adjustFontSize: true)
    private lazy var notificationTapButton: UIButton = UIButtonFactory.createButton(title: "Tap to open", backgroundColor: .clear) //UIButtonFactory.createButton(title: "Tap to open", backgroundColor: .clear, textColor: .primary)
    
    private var viewModel: NotificationCollectionViewCellViewModelType!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Configuration
    override func configure(with viewModel: Any, theme : ThemeService<AppTheme>) {
        guard let viewModel = viewModel as? NotificationCollectionViewCellViewModelType else { return }
        self.viewModel = viewModel
        bind(viewModel: viewModel)
        alpha = 1
    }
    
    // MARK: Layouting
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        animationImageView.layer.cornerRadius = animationImageView.bounds.width/2
        cornerRadiusView.layer.cornerRadius = 12.0
        cornerRadiusView.layer.masksToBounds = false
    }
    
    // MARK: Delete
    func deleteCell() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.cornerRadiusView.frame.origin.y = self?.contentView.bounds.height ?? 0
            self?.alpha = 0.0
        }) { [weak self] _ in
            guard let `self` = self else { return }
            self.cornerRadiusView.removeFromSuperview()
            self.contentView.addSubview(self.cornerRadiusView)
            self.setupConstraints()
        }
    }
    
}

// MARK: SetupViews
private extension NotificationCollectionViewCell {
    func setupViews() {
        contentView.backgroundColor = .clear
        cornerRadiusView.addSubview(animationImageView)
        cornerRadiusView.addSubview(stackView)
        cornerRadiusView.addSubview(cancelButton)
        
        notificationTapButton.titleLabel?.font = UIFont.micro
        stackView.addArrangedSubview(notificationTitle)
        stackView.addArrangedSubview(notificationDescription)
        stackView.addArrangedSubview(notificationTapButton)
        contentView.addSubview(cornerRadiusView)
    }
    
    func setupConstraints() {
        
        cornerRadiusView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [0, 7.5, 12, 12])
        
        cancelButton
            .alignEdgesWithSuperview([.top, .right],constant: 7)
            .width(constant: 20)
            .height(constant: 20)
        
        animationImageView
            .alignEdgeWithSuperview(.left, constant: 15)
            .alignEdgeWithSuperview(.top, .greaterThanOrEqualTo, constant: 25)
            .centerVerticallyInSuperview()
            .width(constant: 60)
            .height(constant: 60)
        
        stackView
            .toRightOf(animationImageView, constant: 15)
            .toBottomOf(cancelButton)
            .alignEdgeWithSuperview(.right, constant: 15)
            .alignEdgeWithSuperview(.bottom, constant: 15)
        
        notificationTapButton.height(constant: 20)
    }
    
    func bind(viewModel: NotificationCollectionViewCellViewModelType) {
        viewModel.outputs.notificationIcon.subscribe(onNext: {[weak self]  in
            self?.animationImageView.image = UIImage.sharedImage(named: $0 ?? "")
        }).disposed(by: disposeBag)
        viewModel.outputs.notificationTitle.bind(to: notificationTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.notifocationDescription.bind(to: notificationDescription.rx.text).disposed(by: disposeBag)
        
        cancelButton.rx.tap.map { [unowned self] in self.indexPath }.bind(to: viewModel.inputs.deleteNotificationObserver).disposed(by: disposeBag)
        notificationTapButton.rx.tap.map { [unowned self] in self.indexPath }.bind(to: viewModel.inputs.actionButtonTappedObserver).disposed(by: disposeBag)
        
        viewModel.outputs.deletable.map { !$0 }.bind(to: cancelButton.rx.isHidden ).disposed(by: disposeBag)
        viewModel.outputs.notificationTitle.map { $0 == nil }.bind(to: notificationTitle.rx.isHidden ).disposed(by: disposeBag)
    }
}
