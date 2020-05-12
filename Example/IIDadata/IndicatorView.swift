//
//  IndicatorView.swift
//  Crab.delivery
//
//  Created by Yachin Ilya on 04/04/2019.
//  Copyright © 2019 Yachin Ilya. All rights reserved.
//

import UIKit

class IndicatorView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    let caLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addIndicatorLayer()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addIndicatorLayer() {
        caLayer.removeAllAnimations()
        
        let w1 = UIBezierPath()
        w1.move(to: CGPoint(x: 0, y: 60))
        w1.addArc(withCenter: CGPoint(x: 0, y: 90), radius: 30, startAngle: .pi*1.5, endAngle: 0, clockwise: true)
        w1.addArc(withCenter: CGPoint(x: 60, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: false)
        w1.addArc(withCenter: CGPoint(x: 120, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: true)
        w1.addArc(withCenter: CGPoint(x: 180, y: 90), radius: 30, startAngle: .pi, endAngle: .pi*0.5, clockwise: false)
        
        let w2 = UIBezierPath()
        w2.move(to: CGPoint(x: 0, y: 90))
        w2.addArc(withCenter: CGPoint(x: 30, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: true)
        w2.addArc(withCenter: CGPoint(x: 90, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: false)
        w2.addArc(withCenter: CGPoint(x: 150, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: true)
        
        let w3 = UIBezierPath()
        w3.move(to: CGPoint(x: 0, y: 120))
        w3.addArc(withCenter: CGPoint(x: 0, y: 90), radius: 30, startAngle: .pi*0.5, endAngle: 0, clockwise: false)
        w3.addArc(withCenter: CGPoint(x: 60, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: true)
        w3.addArc(withCenter: CGPoint(x: 120, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: false)
        w3.addArc(withCenter: CGPoint(x: 180, y: 90), radius: 30, startAngle: .pi, endAngle: .pi*1.5, clockwise: true)
        
        let w4 = UIBezierPath()
        w4.move(to: CGPoint(x: 0, y: 90))
        w4.addArc(withCenter: CGPoint(x: 30, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: false)
        w4.addArc(withCenter: CGPoint(x: 90, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: true)
        w4.addArc(withCenter: CGPoint(x: 150, y: 90), radius: 30, startAngle: .pi, endAngle: 0, clockwise: false)
        
        //        layer.path = w1.cgPath
        caLayer.lineDashPattern = [3, 9]
        caLayer.lineWidth = 3
        caLayer.strokeColor = UIColor.blue.cgColor
        caLayer.fillColor = UIColor.clear.cgColor
        //        layer.lineDashPattern = [1, 12]
        //
        let animationGroup = CAAnimationGroup()
        
        let animation1 = CABasicAnimation(keyPath: "path")
        animation1.fromValue = w1.cgPath
        animation1.toValue = w2.cgPath
        animation1.beginTime = 0
        animation1.duration = 1
        animation1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let animation2 = CABasicAnimation(keyPath: "path")
        animation2.fromValue = w2.cgPath
        animation2.toValue = w3.cgPath
        animation2.beginTime = 1
        animation2.duration = 1
        animation2.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let animation3 = CABasicAnimation(keyPath: "path")
        animation3.fromValue = w3.cgPath
        animation3.toValue = w4.cgPath
        animation3.beginTime = 2
        animation3.duration = 1
        animation3.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let animation4 = CABasicAnimation(keyPath: "path")
        animation4.fromValue = w4.cgPath
        animation4.toValue = w1.cgPath
        animation4.beginTime = 3
        animation4.duration = 1
        animation4.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        animationGroup.animations = [animation1,
                                     animation2,
                                     animation3,
                                     animation4]
        animationGroup.duration = 4
        animationGroup.autoreverses = false
        animationGroup.repeatCount = .greatestFiniteMagnitude
        
        caLayer.add(animationGroup, forKey: "pathAnimation")
        
        self.backgroundColor = {
            if #available(iOS 13.0, *) {
                return UIColor.tertiarySystemFill
            } else {
                return UIColor.white.withAlphaComponent(0.8)
            }
        }()
        self.layer.addSublayer(caLayer)
        
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 15
        self.layer.borderColor = {
            if #available(iOS 13.0, *) {
                return UIColor.systemGray3.withAlphaComponent(0.9).cgColor
            } else {
                return UIColor.lightGray.withAlphaComponent(0.9).cgColor
            }
        }()
        self.layer.masksToBounds = true
    }
    
}
