//
//  Badge.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

/// A way to quickly add a notification badge icon to any view.
public class Badge: NSObject {
    //MARK: - Views
    var countLabel: UILabel {
        didSet {
            checkZero()
        }
    }
    
    lazy var redCircle: UIView = {
        let view = UIView()
        return view
    }()
    
    //MARK: - Properties
    /// Value of current count on badge.
    var count: Int = 0 {
        didSet {
          //  countLabel.text = "\(count)"
            checkZero()
            resizeToFitDigits()
        }
    }
    
    private var initialCenter = CGPoint.zero
    private var initialFrame = CGRect.zero
    private var curOrderMagnitude: Int = 0
    /// Maximum count can be set on badge.
    private var maxCount: Int = 99
    
    //MARK: - Init
    public init(view: UIView) {
        countLabel = UILabel(frame: CGRect.zero)
        super.init()
        self.setView(view, andCount: 0)
    }
}

//MARK: - Private Methods
private extension Badge {
    
    /// Set a view to badgehub.
    /// - Parameters:
    func setView(_ view: UIView, andCount startCount: Int) {
        curOrderMagnitude = 0
        
        redCircle = UIView()
        redCircle.isUserInteractionEnabled = false
        redCircle.backgroundColor = UIColor.red
        redCircle.layer.borderColor = UIColor.white.cgColor
        redCircle.layer.borderWidth = 2
        
        countLabel.frame = redCircle.frame
        countLabel.isUserInteractionEnabled = false
        count = startCount
        countLabel.textAlignment = .center
        countLabel.textColor = UIColor.white
        countLabel.backgroundColor = UIColor.clear
    
        view.addSubview(redCircle)
        view.addSubview(countLabel)
        view.bringSubviewToFront(redCircle)
        view.bringSubviewToFront(countLabel)
        
        setCircleAtFrame(view)
        checkZero()
    }
    
    /// Resize the badge to fit the current digits.
    /// This method is called everytime count value is changed.
    func resizeToFitDigits() {
        guard count > 0 else { return }
        var orderOfMagnitude: Int = Int(log10(Double(count)))
        orderOfMagnitude = (orderOfMagnitude >= 2) ? orderOfMagnitude : 1
        var frame: CGRect = initialFrame
        frame.size.width = CGFloat(initialFrame.size.width * (1 + 0.3 * CGFloat(orderOfMagnitude - 1)))
        frame.origin.x = initialFrame.origin.x - (frame.size.width - initialFrame.size.width) / 2

        redCircle.frame = frame
        initialCenter = CGPoint(x: frame.origin.x + frame.size.width / 2,
                                y: frame.origin.y + frame.size.height / 2)
        countLabel.frame = redCircle.frame
        curOrderMagnitude = orderOfMagnitude
    }
    
    /// Set the frame of the notification circle relative to the view.
    func setCircleAtFrame(_ view: UIView) {
        let centerPoint = getCirclePoints(centerPoint: CGPoint(x: view.bounds.size.width/2 , y: view.bounds.size.height/2) , radius: view.bounds.width/2, n: 12)
        redCircle.center = centerPoint
        redCircle.bounds.size.height = 25
        redCircle.bounds.size.width = 25
        
        let frame = redCircle.frame
        initialCenter = CGPoint(x: frame.origin.x + frame.size.width / 2,
                                y: frame.origin.y + frame.size.height / 2)
        initialFrame = frame
        countLabel.frame = redCircle.frame
        redCircle.layer.cornerRadius = frame.size.height / 2
        countLabel.font = UIFont.systemFont(ofSize: frame.size.width / 2)
    }
    
    func getCirclePoints(centerPoint point: CGPoint, radius: CGFloat, n: Int)->CGPoint {
        let result: [CGPoint] = stride(from: 0.0, to: 360.0, by: Double(360 / n)).map {
            let bearing = CGFloat($0) * .pi / 180
            let x = point.x + radius * cos(bearing)
            let y = point.y + radius * sin(bearing)
            return CGPoint(x: x, y: y)
        }
        return result[n - 1]
    }

    /// Method to hide badge in case of current `count <= 0` and
    /// show badge in case of current `cout > 0`.
    /// Use this method explicitaly when your badge is not hiding/showing as expected.
    func checkZero() {
        if count <= 0 {
            redCircle.isHidden = true
            countLabel.isHidden = true
        } else {
            redCircle.isHidden = false
            countLabel.isHidden = false
        }
    }
}

//MARK: - Public Methods
public extension Badge {
    /// Hide badge from your view.
    func hide() {
        redCircle.isHidden = true
        countLabel.isHidden = true
    }
    
    /// Show hidden badge on your view.
    func show() {
        redCircle.isHidden = false
        countLabel.isHidden = false
    }
    
    /// Set the count yourself.
    /// - Parameter newCount: New count to be set to badge.
    func setCount(_ newCount: Int) {
        self.count = newCount
        let labelText = count > maxCount ? "\(maxCount)+" : "\(count)"
        countLabel.text = labelText
        checkZero()
    }
}
