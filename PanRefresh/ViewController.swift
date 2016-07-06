//
//  ViewController.swift
//  PanRefresh
//
//  Created by ZachZhang on 16/7/6.
//  Copyright © 2016年 ZachZhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let minimumHeight : CGFloat = 64.0
    private let maximumHeight : CGFloat = 200.0
    private let shapeLayer = CAShapeLayer()
    
    private var displayLink : CADisplayLink!
    
//    control points
    private let l3ControlPointView = UIView()
    private let l2ControlPointView = UIView()
    private let l1ControlPointView = UIView()
    private let cControlPointView  = UIView()
    private let r1ControlPointView = UIView()
    private let r2ControlPointView = UIView()
    private let r3ControlPointView = UIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        shapeLayer.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: minimumHeight)
        shapeLayer.fillColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0).CGColor
        shapeLayer.actions = ["position" : NSNull(), "path" : NSNull(), "bounds" : NSNull()]
        view.layer.addSublayer(shapeLayer)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureDidMove)))
        
        // setup control points
        
        l3ControlPointView.frame = CGRect(x: 0, y: 0, width: 3.0, height: 3.0)
        l2ControlPointView.frame = CGRect(x: 0, y: 0, width: 3.0, height: 3.0)
        l1ControlPointView.frame = CGRect(x: 0, y: 0, width: 3.0, height: 3.0)
        cControlPointView.frame  = CGRect(x: 0, y: 0, width: 3.0, height: 3.0)
        r3ControlPointView.frame = CGRect(x: 0, y: 0, width: 3.0, height: 3.0)
        r2ControlPointView.frame = CGRect(x: 0, y: 0, width: 3.0, height: 3.0)
        r1ControlPointView.frame = CGRect(x: 0, y: 0, width: 3.0, height: 3.0)

        
        view.addSubview(l3ControlPointView)
        view.addSubview(l2ControlPointView)
        view.addSubview(l1ControlPointView)
        view.addSubview(cControlPointView)
        view.addSubview(r3ControlPointView)
        view.addSubview(r2ControlPointView)
        view.addSubview(r1ControlPointView)
        
        layoutControlPoints(baseHeight: minimumHeight, waveHeight: 0, locationX: view.bounds.size.width/2.0)
        updateLayer()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateLayer))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink.paused = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func panGestureDidMove(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Ended || gesture.state == .Failed || gesture.state == .Cancelled {
            let centerY = minimumHeight
            
            animating = true
            
            UIView.animateWithDuration(0.9, delay: 0, usingSpringWithDamping: 0.57, initialSpringVelocity: 0, options: [], animations: {
                self.l3ControlPointView.center.y = centerY
                self.l2ControlPointView.center.y = centerY
                self.l1ControlPointView.center.y = centerY
                self.cControlPointView.center.y  = centerY
                self.r3ControlPointView.center.y = centerY
                self.r2ControlPointView.center.y = centerY
                self.r1ControlPointView.center.y = centerY
            }) {
                (finished) in
                self.animating = false
            }
        } else {
            var additionalHeight = max(gesture.translationInView(view).y, 0)
            if additionalHeight > maximumHeight {
                additionalHeight = maximumHeight
            }
            let waveHeight = min(maximumHeight, additionalHeight*0.6)
            let baseHeight = minimumHeight + additionalHeight - waveHeight
        
            let locationX = gesture.locationInView(view).x
            
            layoutControlPoints(baseHeight: baseHeight, waveHeight: waveHeight, locationX: locationX)
            updateLayer()
            
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func currentPath() -> CGPath {
        let width = view.bounds.width
        
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPoint(x: 0.0, y: 0.0))
        bezierPath.addLineToPoint(CGPoint(x: 0.0, y: l3ControlPointView.dg_center(animating).y))
        bezierPath.addQuadCurveToPoint(l1ControlPointView.dg_center(animating), controlPoint: l2ControlPointView.dg_center(animating))
        bezierPath.addQuadCurveToPoint(r1ControlPointView.dg_center(animating), controlPoint: cControlPointView.dg_center(animating))
        bezierPath.addQuadCurveToPoint(r3ControlPointView.dg_center(animating), controlPoint: r2ControlPointView.dg_center(animating))
        bezierPath.addLineToPoint(CGPoint(x: width, y: 0.0))
        
        bezierPath.closePath()
        
        return bezierPath.CGPath
    }
    
    func updateLayer() {
        self.shapeLayer.path = currentPath()
    }
    
    private func layoutControlPoints(baseHeight baseHeight: CGFloat, waveHeight: CGFloat, locationX: CGFloat) {
        let width = view.bounds.width
        
        let minLeftX = min((locationX - width / 2.0) * 0.28, 0.0)
        let maxRightX = max(width + (locationX - width / 2.0) * 0.28, width)
        
        let leftPartWidth = locationX - minLeftX
        let rightPartWidth = maxRightX - locationX
        
        l3ControlPointView.center = CGPoint(x: minLeftX, y: baseHeight)
        l2ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.44, y: baseHeight)
        l1ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
        cControlPointView.center = CGPoint(x: locationX , y: baseHeight + waveHeight * 1.36)
        r1ControlPointView.center = CGPoint(x: maxRightX - rightPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
        r2ControlPointView.center = CGPoint(x: maxRightX - (rightPartWidth * 0.44), y: baseHeight)
        r3ControlPointView.center = CGPoint(x: maxRightX, y: baseHeight)
    }
    
    private var animating : Bool = false {
        didSet {
            self.displayLink.paused = !animating
            view.userInteractionEnabled = !animating
        }
    }
    
    private lazy var identityTransform: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat(1.0 / -500.0)
        transform = CATransform3DRotate(transform, CGFloat(M_PI) * CGFloat(-90.0) / 180.0, 0.0, 0.0, 1.0)
        return transform
    }()
}

