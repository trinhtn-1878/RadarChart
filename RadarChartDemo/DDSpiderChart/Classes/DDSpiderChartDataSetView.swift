//
//  DDSpiderChartDataSetView.swift
//  DDSpiderChart
//
//  Created by dadalar on 05/01/2017.
//  Copyright (c) 2017 dadalar. All rights reserved.
//

import UIKit

final class DDSpiderChartDataSetView: UIView {
    
    var radius: CGFloat {
        didSet {
            setNeedsDisplay()
        }
    }
    var values: [Float] {
        didSet {
            setNeedsDisplay()
        }
    }
    let color: UIColor
    var pointArray = [CGPoint]()
    var shape = CAShapeLayer()
    var const = CGFloat()
    var point = CGPoint()
    var deltaX = CGFloat()
    
    init(radius: CGFloat, values: [Float], color: UIColor) {
        self.radius = radius
        self.values = values
        self.color = color
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        
//        let path = UIBezierPath()
        self.layer.addSublayer(shape)
        pointArray = []
        for (index, value) in values.enumerated() {
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(gestureAction(reconized:)))
            gesture.delaysTouchesBegan = false
            let angle = CGFloat(-Float.pi / 2) - CGFloat(index) * CGFloat(2 * Float.pi) / CGFloat(values.count)
            print("angle: %f", angle)
            let x = center.x + radius * CGFloat(value) * cos(angle)
            let y = center.y + radius * CGFloat(value) * sin(angle)
            let ctrlpoint = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            ctrlpoint.backgroundColor = .black
            ctrlpoint.center = CGPoint(x: x, y: y)
            ctrlpoint.addGestureRecognizer(gesture)
            ctrlpoint.isUserInteractionEnabled = true
            self.isUserInteractionEnabled = true
            self.addSubview(ctrlpoint)
            ctrlpoint.tag = index
        }
    }
    
    @objc func gestureAction(reconized: UIPanGestureRecognizer) {
        
        if (reconized.state == .began) {
            point = reconized.location(in: self)
            deltaX = point.x - center.x
            let deltaY = center.y - point.y
            const = abs(deltaX/deltaY)
        }
        let newpoint = reconized.location(in: self)
        print("center:%@", center)
        print("newPoint:%@", newpoint)
       
        
        let deltaY = (point.y - newpoint.y)
        
        let degree = 360 - (CGFloat)((360/values.count)*reconized.view!.tag)
        let radian = degree * (CGFloat.pi / 180)
        let newDeltaX = newpoint.x - (deltaY*tan(radian) + point.x)
        let radiusY = cos(radian)*radius
        
        var limit = false
       
        if (abs(center.y - newpoint.y) > abs(radiusY)) {
            limit = true
        }
        
        if (radian > CGFloat.pi/2 && CGFloat.pi*3/2 > radian) {
            if (newpoint.y < center.y) {
                limit = true
            }
        } else {
            if (newpoint.y > center.y) {
                limit = true
            }
        }
        
        if (!limit) {
            reconized.view?.center = CGPoint(x: newpoint.x - newDeltaX, y: newpoint.y)
            drawPath()
        }
        
        if (reconized.state == .ended) {
            let angle = CGFloat(-Float.pi / 2) - CGFloat(reconized.view!.tag) * CGFloat(2 * Float.pi) / CGFloat(values.count)
            print("angle: %f", angle)
            print("radian: %f", radian)
//            let x = center.x + radius * CGFloat(value) * cos(angle)
            let value = (((reconized.view?.center.y)! - center.y)/radius)/sin(angle)
            print("value:", value)
        }
    }
    
    func drawPath() {
        pointArray.removeAll()
        let path = UIBezierPath()
        for view in self.subviews {
            if (view is UIButton) {
                pointArray.append(view.center)
            }
        }
        path.move(to: pointArray[0] )
        for i in 1...pointArray.count - 1 {
             path.addLine(to: pointArray[i])
        }
        
        path.close()
        shape.path = path.cgPath
        shape.fillColor = UIColor.gray.cgColor.copy(alpha: 0.5)
    }
    
}
