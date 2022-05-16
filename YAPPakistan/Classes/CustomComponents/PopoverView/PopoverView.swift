//
//  PopoverView.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//

import Foundation
import CoreGraphics
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents

public class PopoverView: UIView {
    
    private lazy var dateLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    
    private lazy var amountLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .micro, alignment: .center)
    
    private lazy var close: UIButton = UIButtonFactory.createButton()
    
    private lazy var closeImage = UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: UIImage.sharedImage(named: "icon_close")?.asTemplate, tintColor: .blue)//.primaryDark)
    
    public var pointerSize: CGSize = CGSize(width: 20, height: 12)
    
    private var pointerX: CGFloat = .zero
    
    public var origin: CGPoint = .zero {
        didSet {
            isHidden = isPopoverHidden ? true : origin == .zero || ((dateLabel.text?.count ?? 0) == 0 && (amountLabel.text?.count ?? 0) == 0)
            guard origin != .zero else { return }
            updateFrame()
        }
    }
    
    public var dateText: String? {
        didSet {
            dateLabel.text = dateText
        }
    }
    
    public var amountText: String? {
        didSet {
            amountLabel.text = amountText
        }
    }
    
    var leading: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    
    public var isPopoverHidden: Bool = false {
        didSet {
            isHidden = isPopoverHidden
        }
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commontInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commontInit()
    }
    
    private func commontInit() {
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        clipsToBounds = false
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 10
        isUserInteractionEnabled = true
        setupViews()
        setupConstraints()
        updateFrame()
        setNeedsDisplay()
    }
    
    @objc
    private func closeAction(_ sender: UIButton) {
        isPopoverHidden = true
    }
}

// MARK: Drawing

extension PopoverView {
    public  override func draw(_ rect: CGRect) {
        
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        if pointerX == 0 {
            pointerX = bounds.width/2
        }
        ctx.beginPath()
        
        var popupFrame = frame
        popupFrame.origin.x = 0
        popupFrame.origin.y = 0
        popupFrame.size.height -= pointerSize.height
        
        ctx.move(to: CGPoint(x: pointerX - pointerSize.width/2, y: bounds.height - pointerSize.height))
        ctx.addLine(to: CGPoint(x: pointerX, y: bounds.height))
        ctx.addLine(to: CGPoint(x: pointerX + pointerSize.width/2, y: bounds.height - pointerSize.height))
        
        let corners: UIRectCorner = pointerX - pointerSize.width/2 < 2 ? [.topRight, .topLeft, .bottomRight] : pointerX + pointerSize.width > rect.width - 2 ? [.topRight, .topLeft, .bottomLeft] : [.topRight, .topLeft, .bottomLeft, .bottomRight]
        ctx.addPath(UIBezierPath(roundedRect: popupFrame, byRoundingCorners: corners, cornerRadii: CGSize(width: 8, height: 8)).cgPath)

        ctx.closePath()
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillPath()
    }
    
}

// MARK: Frame setup

private extension PopoverView {
    func updateFrame() {
        guard let superview = self.superview else { return }
        
        if leading == nil {
            leading = leadingAnchor.constraint(equalTo: superview.leadingAnchor)
            leading?.isActive = true
        }
        
        if bottom == nil {
            bottom = superview.topAnchor.constraint(equalTo: bottomAnchor)
            bottom?.isActive = true
        }
        
        var frame = self.frame
        
        let dateSize = dateLabel.textSize
        let amountSize = amountLabel.textSize
        
        frame.size.width = dateSize.width > amountSize.width ? dateSize.width + 50 : amountSize.width + 20
        frame.size.height = 50 + pointerSize.height
        
        pointerX = frame.width/2
        
        var x = origin.x - frame.width/2
        if x < 0 {
            x = 0
        }
        if x > origin.x - pointerSize.width/2 {
            x = origin.x - pointerSize.width/2
        }
        
        if x + frame.width > superview.bounds.width {
            x = superview.bounds.width - frame.width
        }
        if x + frame.width < origin.x + pointerSize.width/2 {
            x = (origin.x + pointerSize.width/2) - frame.width
        }
        
        pointerX = origin.x - x
        
        frame.origin.x = x
        
        leading?.constant = frame.origin.x
        bottom?.constant = -origin.y
        
        setNeedsDisplay()
        UIView.animate(withDuration: 0.25) {
            superview.layoutIfNeeded()
        }
    }
}

// MAKR: View setup

private extension PopoverView {
    func setupViews() {
        addSubview(dateLabel)
        addSubview(amountLabel)
        addSubview(close)
        close.addSubview(closeImage)
        close.backgroundColor = .clear
        close.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
    }
    
    func setupConstraints() {
        dateLabel
            .alignEdgesWithSuperview([.left, .right, .top], constants: [25, 25, 5])
            .height(constant: 20)
        
        amountLabel
            .toBottomOf(dateLabel)
            .alignEdgesWithSuperview([.left, .right], constant: 10)
            .alignEdgeWithSuperview(.bottom, constant: 10 + pointerSize.height)
            .height(constant: 20)
        
        close
            .alignEdgesWithSuperview([.top, .right], constants: [-10, -10])
            .width(constant: 44)
            .height(constant: 44)
        
        closeImage
            .centerInSuperView()
            .width(constant: 15)
            .height(constant: 15)
        
    }
}

// MARK: Reactive

public extension Reactive where Base: PopoverView {
    var dateText: Binder<String?> {
        return Binder(self.base) { popoverView, dateText -> Void in
            popoverView.dateText = dateText
        }
    }
    
    var amountText: Binder<String?> {
        return Binder(self.base) { popoverView, amountText -> Void in
            popoverView.amountText = amountText
        }
    }
    
    var origin: Binder<CGPoint> {
        return Binder(self.base) { popoverView, origin -> Void in
            popoverView.origin = origin
        }
    }
    
    var isPopoverHidden: Binder<Bool> {
        return Binder(self.base) { popoverView, hidden -> Void in
            popoverView.isPopoverHidden = hidden
        }
    }
}

