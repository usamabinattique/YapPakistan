//
//  TransactionDetailsMapCell.swift
//  YAP
//
//  Created by Zain on 21/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import GoogleMaps
import RxTheme

class TransactionDetailsMapCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var mapImageView: UIImageView = UIImageViewFactory.createImageView(mode: .scaleAspectFill)
    
    lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = false
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return mapView
    }()

    // MARK: Properties
    
    private var viewModel: TransactionDetailsMapCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        setupViews()
        setupConstraint()
    }
    
    // MARK: Configurations
    
//    override func configure(with viewModel: Any) {
//        guard let `viewModel` = viewModel as? TransactionDetailsMapCellViewModelType else { return }
//        self.viewModel = viewModel
//        bindViews()
//    }
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TransactionDetailsMapCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
//        setupTheme()
//        setupResources()
    }
}

// MARK: View setup

private extension TransactionDetailsMapCell {
    func setupViews() {
        contentView.addSubview(mapImageView)
        contentView.addSubview(mapView)
    }
    
    func setupConstraint() {
        mapImageView
            .height(constant: 150)
            .alignAllEdgesWithSuperview()
        mapView
            .height(constant: 350)
            .alignAllEdgesWithSuperview()
        
    }
    
    func setupSensitiveViews() {
//        UIView.markSensitiveViews([self.contentView])
    }
}

// MARK: Binding

private extension TransactionDetailsMapCell {
    func bindViews() {
        viewModel.outputs.categoryImage.bind(to: mapImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.showImage.bind(to: mapImageView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.showMap.bind(to: mapView.rx.isHidden).disposed(by: disposeBag)
        bindMapMarker()

    }
    
    func bindMapMarker() {
        viewModel.outputs.mapMarker.subscribe(onNext: { [weak self] marker in
            guard let position = marker?.position else {return}
            let target = CLLocationCoordinate2D(latitude:position.latitude , longitude: position.longitude)
            self?.mapView.camera = GMSCameraPosition.camera(withTarget: target, zoom: 15)
            marker?.map = self?.mapView
        }).disposed(by: disposeBag)
    }
}
