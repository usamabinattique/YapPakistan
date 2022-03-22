//
//  BeneficiaryStatusView.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//


import UIKit
import RxCocoa
import RxSwift
import YAPCore
import YAPComponents
import RxTheme

enum AddBeneficiaryStage {
    case bankName
    case bankNameComplete
    case bankAccountDetail
    case bankAccountDetailComplete
    case confirmBeneficiary
    case confirmBeneficiaryComplete
}

final class BeneficiaryStatusView: UIView {

    // User Interface
    var icons: [UIImage?] {
        get { iconViews.map({ $0.image }) }
        set {
            for index in 0..<newValue.count { iconViews[index].image = newValue[index] }
           // updateProgress()
        }
    }
    var strings: [String?] {
        get { statusLabels.map({ $0.text }) }
        set {
            for index in 0..<newValue.count { statusLabels[index].text = newValue[index] }
           // updateProgress()
        }
    }
    var theme: (light: UIColor, dark: UIColor) = (UIColor(Color(hex: "#5E35B1")), .blue) { didSet {
      //  updateProgress()
    } }
    var progress: Int = 0 { didSet {
       // updateProgress()
    } }

    // private properties
    private let iconViews = [UIFactory.makeImageView(contentMode: .scaleAspectFit),
                             UIFactory.makeImageView(contentMode: .scaleAspectFit),
                             UIFactory.makeImageView(contentMode: .scaleAspectFit)]
    private let iconContainers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]
    private let statusLines = [UIFactory.makeView().setCornerRadius(3),
                               UIFactory.makeView().setCornerRadius(3)]
    private let statusLabels = [UIFactory.makeLabel(font: .small, alignment: .center),
                                UIFactory.makeLabel(font: .small, alignment: .center),
                                UIFactory.makeLabel(font: .small, alignment: .center)]

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainers.forEach {
            $0.layer.cornerRadius = $0.frame.size.height / 2
        }
        
        iconViews.forEach {
            let img = UIImage.init(named: "icon_check", in: .yapPakistan)?.asTemplate
            $0.image = img
            $0.tintColor = .white
        }
    }

    private func makeUI() {
        initialSetup()
        setupViews()
        setupConstraints()
    }

    private func initialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }

    private func setupViews() {
        addSubviews(iconContainers)
       // addSubviews(statusLabels)
        addSubviews(statusLines)
        for index in 0..<iconContainers.count {
            iconContainers[index].addSub(view: iconViews[index])
        }
        
        for index in 0..<iconViews.count {
            let img = UIImage.init(named: "icon_check", in: .yapPakistan)?.asTemplate
            iconViews[index].image = img
            iconViews[index].tintColor = .white
        }
        
        for index in 0..<iconContainers.count {
            statusLabels[index].textColor = .white
            iconContainers[index].addSub(view: statusLabels[index])
        }
        
        for index in 0..<statusLines.count {
            statusLines[index].backgroundColor = UIColor(Color(hex: "#272262")).withAlphaComponent(0.30)
        }
    }

    private func setupConstraints() {
        iconContainers[0]
            .alignEdgesWithSuperview([.top, .left], constant: 10)
            .height(constant: 32)
//            .width(constant: 32)
            .aspectRatio()

        statusLines[0]
            .toRightOf(iconContainers[0], constant: 10)
            .centerVerticallyWith(iconContainers[0])
            .height(constant: 1)
            .width(constant: 26)

        iconContainers[1]
            .toRightOf(statusLines[0], constant: 10)
            .alignEdgeWithSuperview(.top, constant: 10)
            .height(constant: 32)
            .aspectRatio()
//            .width(constant: 32)

        statusLines[1]
            .toRightOf(iconContainers[1], constant: 10)
            .centerVerticallyWith(iconContainers[1])
            .height(constant: 1)
            .width(constant: 26)

        iconContainers[2]
            .toRightOf(statusLines[1], constant: 10)
            .alignEdgesWithSuperview([.top, .right], constant: 10)
            .height(constant: 32)
            .aspectRatio()
//            .width(constant: 32)

        for index in 0..<iconViews.count {
            iconViews[index]//.alignEdgesWithSuperview([.top, .bottom, .right, .left], constant: 6)
                .centerVerticallyInSuperview()
                .centerHorizontallyInSuperview()
        }

        for index in 0..<statusLabels.count {
            statusLabels[index]
                .centerVerticallyInSuperview()
                .centerHorizontallyInSuperview()
                //.alignEdgesWithSuperview([.top, .bottom, .right, .left], constant: 6)
        }

        iconContainers[0]
            .widthEqualTo(view: iconContainers[1])
            .widthEqualTo(view: iconContainers[2])
        statusLines[0]
            .widthEqualTo(view: statusLines[1])
    }
    
    func updateProgress(for stage: AddBeneficiaryStage) {
        let primary = UIColor(Color(hex: "#5E35B1"))
        let primaryDark = UIColor(Color(hex: "#272262"))
        switch stage {
        case .bankName:
            updateProgoress(isCountHidden: false, backgroundColour: primary, index: 0)
            updateProgoress(isCountHidden: false, backgroundColour: primaryDark, index: 1)
            updateProgoress(isCountHidden: false, backgroundColour: primaryDark, index: 2)
        case .bankNameComplete:
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 0)
            updateProgoress(isCountHidden: false, backgroundColour: primary, index: 1)
            updateProgoress(isCountHidden: false, backgroundColour: primaryDark, index: 2)
        case .bankAccountDetail:
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 0)
            updateProgoress(isCountHidden: false, backgroundColour: primary, index: 1)
            updateProgoress(isCountHidden: false, backgroundColour: primaryDark, index: 2)
        case .bankAccountDetailComplete:
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 0)
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 1)
            updateProgoress(isCountHidden: false, backgroundColour: primaryDark, index: 2)
        case .confirmBeneficiary:
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 0)
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 1)
            updateProgoress(isCountHidden: false, backgroundColour: primary, index: 2)
        case .confirmBeneficiaryComplete:
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 0)
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 1)
            updateProgoress(isCountHidden: true, backgroundColour: primary, index: 2)
        }
    }
    
    private func updateProgoress(isCountHidden: Bool, backgroundColour: UIColor, index: Int) {
        guard index <= 2 else { return }
        statusLabels[index].isHidden = isCountHidden
        iconViews[index].isHidden = !isCountHidden
        iconContainers[index].backgroundColor = backgroundColour
    }
}

extension UIFactory {
    static func makeBeneficiaryStatusView() -> BeneficiaryStatusView {
        let view = BeneficiaryStatusView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
