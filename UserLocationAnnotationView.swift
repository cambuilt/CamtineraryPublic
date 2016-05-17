//
//  UserLocationAnnotationView.swift
//  Camtinerary
//
//  Created by Cameron Conway on 5/11/16.
//  Copyright © 2016 cambuilt. All rights reserved.
//

class UserLocationAnnotationView: MKAnnotationView {
    var ac:UIColor!
    var odl:CALayer!, cdl:CALayer!, chl:CALayer!
    var pag:CAAnimationGroup!
    var willMoveToSuperviewAnimationBlock:((annotationView:UserLocationAnnotationView, superview:UIView) -> Void)?
    let outerColor = UIColor.whiteColor()
    var outerDotLayer:CALayer! {
        get {
            if self.odl == nil {
                self.odl = CALayer()
                self.odl.bounds = self.bounds
                self.odl.contents = self.circleImageWithColor(self.outerColor, height: self.bounds.size.height).CGImage
                self.odl.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
                self.odl.contentsGravity = kCAGravityCenter
                self.odl.contentsScale = UIScreen.mainScreen().scale
                self.odl.shadowColor = UIColor.blackColor().CGColor
                self.odl.shadowOffset = CGSizeMake(0, 2)
                self.odl.shadowRadius = 3
                self.odl.shadowOpacity = 0.3
                self.odl.shouldRasterize = true
                self.odl.rasterizationScale = UIScreen.mainScreen().scale
            }
            
            return self.odl
        }
        set {
            self.odl = newValue
        }
    }
    var colorDotLayer:CALayer! {
        get {
            if self.cdl == nil {
                self.cdl = CALayer()
                let width = self.bounds.size.width - 6
                self.cdl.bounds = CGRect(x: 0, y: 0, width: width, height: width)
                self.cdl.allowsGroupOpacity = true
                self.cdl.backgroundColor = self.annotationColor.CGColor
                self.cdl.cornerRadius = width / 2
                self.cdl.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                    let animationGroup = CAAnimationGroup()
                    animationGroup.duration = 3
                    animationGroup.repeatCount = 1000
                    animationGroup.removedOnCompletion = false
                    animationGroup.autoreverses = true
                    animationGroup.timingFunction = defaultCurve
                    animationGroup.speed = 1
                    animationGroup.fillMode = kCAFillModeBoth
                    let pulseAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
                    pulseAnimation.fromValue = 0.8
                    pulseAnimation.toValue = 1
                    pulseAnimation.duration = 3
                    let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                    opacityAnimation.fromValue = 0.8
                    opacityAnimation.toValue = 1
                    opacityAnimation.duration = 3
                    animationGroup.animations = [pulseAnimation, opacityAnimation]
                    dispatch_async(dispatch_get_main_queue(), {
                        self.cdl.addAnimation(animationGroup, forKey: "pulse")
                    })
                })
            }
            
            return self.cdl
        }
        set {
            self.cdl = newValue
        }
    }
    var colorHaloLayer:CALayer! {
        get {
            if self.chl == nil {
                self.chl = CALayer()
                let width = bounds.size.width * 5.3;
                self.chl.bounds = CGRect(x: 0, y: 0, width: width, height: width)
                self.chl.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
                self.chl.contentsScale = UIScreen.mainScreen().scale
                self.chl.backgroundColor = self.annotationColor.CGColor
                self.chl.cornerRadius = width / 2
                self.chl.opacity = 0;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.chl.addAnimation(self.pulseAnimationGroup, forKey: "pulse")
                    })
                })
            }
            
            return self.chl
        }
        set {
            self.chl = newValue
        }
    }
    var pulseAnimationGroup:CAAnimationGroup! {
        get {
            if self.pag == nil {
                let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                self.pag = CAAnimationGroup()
                self.pag.duration = 3
                self.pag.repeatCount = 1000
                self.pag.removedOnCompletion = false
                self.pag.timingFunction = defaultCurve
                var animations = [CAAnimation]()
                let pulseAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
                pulseAnimation.fromValue = 0.0
                pulseAnimation.toValue = 1.0
                pulseAnimation.duration = 3
                animations.append(pulseAnimation)
                let animation = CAKeyframeAnimation(keyPath: "opacity")
                animation.duration = 3
                animation.values = [0.45, 0.45, 0]
                animation.keyTimes = [0, 0.2, 1]
                animation.removedOnCompletion = false
                animations.append(animation)
                self.pag.animations = animations
            }
            
            return self.pag
        }
        set {
            self.pag = newValue
        }
    }
    var annotationColor:UIColor! {
        get {
            return self.ac
        }
        set {
            if CGColorGetNumberOfComponents(newValue.CGColor) == 2 {
                let white = CGColorGetComponents(newValue.CGColor)[0]
                let alpha = CGColorGetComponents(newValue.CGColor)[1]
                self.ac = UIColor(red: white, green: white, blue: white, alpha: alpha)
            } else {
                self.ac = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        calloutOffset = CGPoint(x: 0, y: 4)
        bounds = frame
        annotationColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1)
        willMoveToSuperviewAnimationBlock = { (annotationView:UserLocationAnnotationView, superview:UIView) -> Void in
            let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            bounceAnimation.values = [0.05, 1.25, 0.8, 1.1, 0.9, 1.0]
            bounceAnimation.duration = 0.3
            bounceAnimation.timingFunctions = [easeInOut, easeInOut, easeInOut, easeInOut, easeInOut, easeInOut]
            annotationView.layer.addAnimation(bounceAnimation, forKey: "popIn")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func rebuildLayers() {
        outerDotLayer.removeFromSuperlayer()
        outerDotLayer = nil
        colorDotLayer.removeFromSuperlayer()
        colorDotLayer = nil
        colorHaloLayer.removeFromSuperlayer()
        colorHaloLayer = nil
        pulseAnimationGroup = nil
        layer.addSublayer(colorHaloLayer)
        layer.addSublayer(outerDotLayer)
        layer.addSublayer(colorDotLayer)
    }
    
    func circleImageWithColor(color:UIColor, height:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(height, height), false, 0)
        let fillPath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: height, height: height))
        color.setFill()
        fillPath.fill()
        let dotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return dotImage;
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            rebuildLayers()
        }
        
        if willMoveToSuperviewAnimationBlock != nil && newSuperview != nil {
            willMoveToSuperviewAnimationBlock!(annotationView: self, superview: newSuperview!)
        }
    }
    
    func popIn() {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        bounceAnimation.values = [0.05, 1.25, 0.8, 1.1, 0.9, 1.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.timingFunctions = [easeInOut, easeInOut, easeInOut, easeInOut, easeInOut, easeInOut]
        layer.addAnimation(bounceAnimation, forKey: "popIn")
    }
}
