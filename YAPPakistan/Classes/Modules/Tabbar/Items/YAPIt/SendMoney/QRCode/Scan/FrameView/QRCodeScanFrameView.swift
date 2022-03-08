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
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurEffectView)
        blurEffectView.frame = UIScreen.main.bounds
        
        backgroundColor = .clear
        
        addSubview(blurEffectView)
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
        let width = innerLayer.frame.size.width
        print("width is in scanframe \(width)")
        
        let height = innerLayer.frame.size.height
        print("heigh is in scanframe \(height)")
        
        innerLayer.path = pathForinnerLayer().cgPath
        innerLayer.fillRule = .evenOdd
        innerLayer.lineWidth = 6 //2
        innerLayer.lineJoin = .round //.miter
        innerLayer.fillColor = UIColor.clear.cgColor
        innerLayer.lineDashPattern = [NSNumber(value: 50), NSNumber(value: 50)] //[NSNumber(value: 20), NSNumber(value: 20)] //[NSNumber(value: 10), NSNumber(value: 10)]
        innerLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }
    
    private func pathForOutterLayer(inRect rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        
        let originX: CGFloat = 50
        let width = rect.size.width - (2*originX)
        let height = width/cardAspectRatio
        
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
