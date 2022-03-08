//
//  QRCodeScanFrameView.swift
//  YAPPakistan
//
//  Created by Yasir on 07/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import CoreImage
import UIKit

class QRCodeScanFrameView: UIView {
    
//    private let outerLayer = CAShapeLayer()
    private let innerLayer = CAShapeLayer()
    var croppingRect: CGRect = .zero
    var cardAspectRatio: CGFloat = 1
    
//    private lazy var blurEffectView: UIVisualEffectView = {
//        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        view.backgroundColor = UIColor(Color(hex: "#5E35B1")).withAlphaComponent(0.5)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    private lazy var blurEffectView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "image_qr_code_background", in: .yapPakistan, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var rentangleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var rectangle: CAShapeLayer = {
        var view = CAShapeLayer()
        view.frame = CGRect(x: 0, y: 0, width: 277, height: 292)
       // view.backgroundColor = .white

        view.backgroundColor = UIColor(red: 0.847, green: 0.847, blue: 0.847, alpha: 0).cgColor
        view.cornerRadius = 10
        var stroke = UIView()
        stroke.bounds = view.bounds.insetBy(dx: -3, dy: -3)
        stroke.center = view.frame.center
        view.addSublayer(stroke.layer)
        stroke.layer.cornerRadius = 13
        view.bounds = view.bounds.insetBy(dx: -3, dy: -3)
        stroke.layer.borderWidth = 6
        stroke.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor

        var parent = self
        parent.layer.addSublayer(view)
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurEffectView)
       // blurEffectView.frame = UIScreen.main.bounds
        
        backgroundColor = .clear
        
        addSubview(blurEffectView)
        blurEffectView
            .alignAllEdgesWithSuperview()
        layer.addSublayer(innerLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let maskView = UIView(frame: blurEffectView.bounds)
        maskView.clipsToBounds = true;
        maskView.backgroundColor = .clear
        
        let outerPath = pathForOutterLayer(inRect: rect)
        outerPath.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.path = outerPath.cgPath
        maskView.layer.addSublayer(fillLayer)
        
        blurEffectView.mask = maskView
        
        let originX: CGFloat = 50
        let width = rect.size.width - (2*originX)
        let height = CGFloat(292) //width/cardAspectRatio
        
        croppingRect = CGRect(x: originX, y: 150, width: width, height: height)
        rentangleImage.frame = croppingRect
        
        rentangleImage.image = UIImage.init(named: "crop_rectangle", in: .yapPakistan, compatibleWith: nil)
        addSubview(rentangleImage)
        
        rentangleImage
            .centerHorizontallyInSuperview()
            //.alignEdgesWithSuperview([.left, .right], constant: 44)
        rentangleImage.alignEdgeWithSuperview(.top, constant: 144)//144)
        
             /* innerLayer.path = pathForinnerLayer().cgPath
        innerLayer.fillRule = .evenOdd
        innerLayer.lineWidth = 6 //2
        innerLayer.lineJoin = .round //.miter
        innerLayer.fillColor = UIColor.clear.cgColor
//        innerLayer.lineDashPattern = [NSNumber(value: 50)] //[NSNumber(value: 20), NSNumber(value: 20)] //[NSNumber(value: 10), NSNumber(value: 10)]
        innerLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor */
        
       
    }
    
    private func pathForOutterLayer(inRect rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        
        let originX: CGFloat = 50
        let width = rect.size.width - (2*originX)
        let height = CGFloat(292) //width/cardAspectRatio + 17
        
        croppingRect = CGRect(x: originX, y: 150, width: width, height: height)
        
        let innerPath = UIBezierPath(roundedRect: croppingRect, cornerRadius: 10).reversing()
        path.append(innerPath)
        
        return path
    }
    
    private func pathForinnerLayer() -> UIBezierPath {
        return UIBezierPath(roundedRect: croppingRect, cornerRadius: 10)
    }
    
    func setQrCodeValid(_ valid: Bool) {
        //TODO: add color here
        innerLayer.strokeColor = valid ? UIColor.white.cgColor : UIColor.red.cgColor //UIColor.error.cgColor
    }
    
}
