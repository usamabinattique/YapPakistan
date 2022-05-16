//
//  PieChart.swift
//  YAPKit
//
//  Created by Muhammad Hassan on 22/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public typealias PieChartComponent = (number: Double, color: UIColor)

@IBDesignable
open class PieChart: UIControl {
    
    // MARK: - IBInspectable
    @IBInspectable
    public var offsetY: CGFloat = 40.0
    
    @IBInspectable
    var startAngle: CGFloat = 0
    
    @IBInspectable
    public var arcWidth: CGFloat = 30.0 {
        didSet {
            selectedArcWidth = arcWidth + 8
        }
    }
    
    public var selectionEnabled: Bool = true {
        didSet {
            selectedIndex = selectionEnabled ? 0 : -1
        }
    }
    
    public var selectedArcWidth: CGFloat = 38.0
    
    private typealias Angle = (start: CGFloat, end: CGFloat)
    
    // MARK: - Private Properties
    private var rect: CGRect?
    private var paths = [UIBezierPath]()
    private var angles = [Angle]()
    
    public var selectedIndex = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var components: [PieChartComponent] = [] {
        didSet {
            if let _ = rect {
                setNeedsDisplay()
            }
        }
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.rect = rect
        drawChart(inRect: rect, components: components)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let touchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTouch(_:)))
        addGestureRecognizer(touchGestureRecognizer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTouch(_ gestureRecognizer: UITapGestureRecognizer) {
        guard selectionEnabled else { return }
        
        let location = gestureRecognizer.location(in: self)
        let distance = sqrt(pow(location.x - bounds.width/2, 2) + pow(location.y - bounds.height/2, 2))
        let externalRadius = bounds.width/2 - (selectedArcWidth - arcWidth)
        let internalRadius = externalRadius - arcWidth
        
        guard distance <= externalRadius && distance >= internalRadius else { return }
        
        var angle = atan2(location.y - bounds.width/2, location.x - bounds.height/2)
        angle = angle < 0 ? angle + CGFloat(2*Double.pi) : angle
        angle = angle < CGFloat( 3 * (Double.pi) / 2) ? angle + CGFloat(2 * Double.pi): angle
        
        let selectedPath = angles.enumerated().filter { angle >= $0.1.start && angle <= $0.1.end }.map { $0.0 }.first

        guard let index = selectedPath else { return }
        
        self.selectedIndex = index
        sendActions(for: .valueChanged)
    }
    
    func drawChart(inRect rect: CGRect, components: [PieChartComponent] ) {

        guard components.count > 0 else { return }
        
        let chartCenter = CGPoint(x: rect.midX, y: rect.midY)
        
        var i = 0
        paths.removeAll()
        angles.removeAll()
        startAngle = CGFloat( 3 * (Double.pi) / 2)
        
        for component in components {
            let percentage = component.number * 100
            let degree = percentage * 360.0 / 100.0
            let radian = degree * Double.pi / 180.0
            let endAngle = CGFloat(radian)
            
            let piePath = UIBezierPath()
            let radius = i == selectedIndex ? ((frame.width / 2.0) - arcWidth/2 - (selectedArcWidth - arcWidth)/2) : (frame.width / 2.0) - arcWidth/2 - (selectedArcWidth - arcWidth)
            
            piePath.addArc(withCenter: chartCenter,
                           radius: radius,
                           startAngle: startAngle,
                           endAngle: endAngle + startAngle,
                           clockwise: true)
            angles.append(Angle(start: startAngle, end: endAngle + startAngle))
            startAngle = endAngle + startAngle
            
            component.color.setStroke()
            piePath.lineWidth = i == selectedIndex ? selectedArcWidth : arcWidth
            piePath.stroke()
            paths.append(piePath)
            
            i += 1
        }
    }
}
