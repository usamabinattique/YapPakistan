//
//  StorePackageTableViewCell.swift
//  YAPPakistan
//
//  Created by Umair  on 23/04/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxCocoa
import SDWebImage
import RxTheme
import UIKit

class StorePackageTableViewCell: RxUITableViewCell {
    
    private lazy var parentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var bottomInnerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cornerRadiusView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var marginView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var packageCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "image_store_young", in: .yapPakistan)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var packageLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "logo_image", in: .yapPakistan)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var headingLabel: UILabel = UIFactory.makeLabel(font: .large)
    
    private lazy var packageDescriptionLabel: UILabel = UIFactory.makeLabel(font: .micro, numberOfLines: 0)
    
    private lazy var commingSoonLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    
    private var viewModel: StorePackageTableViewCellViewModelType!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View cycle
    
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        render()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    
    // MARK: Properties
    var themeService: ThemeService<AppTheme>!
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? StorePackageTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        setupTheme()
        setupBindings()
    }
    
}

extension StorePackageTableViewCell: ViewDesignable {
    
    func setupSubViews(){
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        commingSoonLabel.text = "screen_store_package_cell_coming_soon_text".localized
        
        parentStackView.addArrangedSubview(packageCoverImageView)
        parentStackView.addArrangedSubview(bottomStackView)
        bottomStackView.addArrangedSubview(marginView)
        bottomStackView.addArrangedSubview(packageLogo)
        
        bottomInnerStackView.addArrangedSubview(headingLabel)
        bottomInnerStackView.addArrangedSubview(packageDescriptionLabel)
        bottomStackView.addArrangedSubview(bottomInnerStackView)
        
        cornerRadiusView.addSubview(parentStackView)
        cornerRadiusView.addSubview(commingSoonLabel)
        
        contentView.addSubview(cornerRadiusView)
    }
    
    func setupConstraints(){
        
        packageCoverImageView
            .height(constant: 200)
            .width(with: .width, ofView: parentStackView)
        
        commingSoonLabel
            .height(constant: 20)
            .width(constant: 100)
            .alignEdgesWithSuperview([.left, .top], constants: [10, 10])
        
        bottomStackView
            .height(constant: 98)
            .width(with: .width, ofView: packageCoverImageView)
        
        marginView.width(constant: 0)
        
        packageLogo
            .height(constant: 54)
            .width(constant: 54)
        
        parentStackView
            .alignEdges([.left, .right, .top, .bottom], withView: cornerRadiusView)
        
        cornerRadiusView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constants: [20, 20, 15, 15])
    }
    
    func setupBindings(){
        viewModel.outputs.coverImage.unwrap().map { UIImage(named: $0, in: .yapPakistan, compatibleWith: nil) }.bind(to: packageCoverImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.packageLogo.unwrap().map { UIImage(named: $0, in: .yapPakistan, compatibleWith: nil) }.bind(to: packageLogo.rx.image).disposed(by: disposeBag)
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.packageDescription.bind(to: packageDescriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.commingSoonLabelIsHeaden.unwrap().bind(to: commingSoonLabel.rx.isHidden).disposed(by: disposeBag)
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: packageDescriptionLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: commingSoonLabel.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: commingSoonLabel.rx.textColor)
            .disposed(by: disposeBag)
    }
    
    func render() {
        commingSoonLabel.layer.cornerRadius = 10.0
        commingSoonLabel.clipsToBounds = true
        
        packageLogo.layer.cornerRadius = 12.0
        packageLogo.clipsToBounds = true
        
        cornerRadiusView.layer.cornerRadius = 12.0
        cornerRadiusView.clipsToBounds = true
        cornerRadiusView.layer.masksToBounds = false
        
        cornerRadiusView.layer.shadowColor = UIColor(hexString: "C9C8D8")?.cgColor
        cornerRadiusView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cornerRadiusView.layer.shadowRadius = 10
        cornerRadiusView.layer.shadowOpacity = 0.5
        
        packageCoverImageView.roundCorners([.topLeft, .topRight], radius: 12)
        packageCoverImageView.clipsToBounds = true
    }
}

//extension UIImageView {
//    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
//        let maskPath = UIBezierPath(roundedRect: bounds,
//                                    byRoundingCorners: corners,
//                                    cornerRadii: CGSize(width: radius, height: radius))
//        let shape = CAShapeLayer()
//        shape.path = maskPath.cgPath
//        layer.mask = shape
//    }
//}

