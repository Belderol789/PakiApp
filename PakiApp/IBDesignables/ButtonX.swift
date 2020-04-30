//
//  ButtonX.swift
//  Tops
//
//  Created by Kem Belderol on 22/03/2018.
//  Copyright © 2018 Kem Belderol. All rights reserved.
//

import UIKit
@IBDesignable

class ButtonX: UIButton {
    
    private var gradient: CAGradientLayer?
    var colors: [Any]?
    
    var baseColor: UIColor = .clear {
        didSet {
            self.backgroundColor = baseColor
            self.layer.shadowColor = baseColor.cgColor
        }
    }
    
    // the gradient start colour
    @IBInspectable var startColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    // the gradient end colour
    @IBInspectable var endColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    // the gradient angle, in degrees anticlockwise from 0 (east/right)
    @IBInspectable var angle: CGFloat = 270
    
    var endPoint: CGPoint = CGPoint.zero
    //The end point of the gradient when drawn in the layer’s coordinate space. Animatable.
    var startPoint: CGPoint = CGPoint.zero
    //The start point of the gradient when drawn in the layer’s coordinate space. Animatable.
    
    override var frame: CGRect {
        didSet {
            updateGradient()
        }
    }

    // initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installGradient()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installGradient()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        installGradient()
        updateGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }

    // Update an existing gradient
    private func updateGradient() {
        if let gradient = self.gradient {
            let startColor = self.startColor ?? UIColor.clear
            let endColor = self.endColor ?? UIColor.clear
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            let (start, end) = gradientPointsForAngle(self.angle)
            gradient.startPoint = start
            gradient.endPoint = end
            gradient.frame = self.bounds
            gradient.cornerRadius = self.cornerRadius
        }
    }
    
    private func createGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        return gradient
    }
    
    private func installGradient() {
        // if there's already a gradient installed on the layer, remove it
        if let gradient = self.gradient {
            gradient.removeFromSuperlayer()
        }
        let gradient = createGradient()
        self.layer.addSublayer(gradient)
        self.gradient = gradient
    }
    
    // create vector pointing in direction of angle
    private func gradientPointsForAngle(_ angle: CGFloat) -> (CGPoint, CGPoint) {
        // get vector start and end points
        let end = pointForAngle(angle)
        let start = oppositePoint(end)
        // convert to gradient space
        let p0 = transformToGradientSpace(start)
        let p1 = transformToGradientSpace(end)
        return (p0, p1)
    }
    
    private func oppositePoint(_ point: CGPoint) -> CGPoint {
           return CGPoint(x: -point.x, y: -point.y)
    }
    
    private func transformToGradientSpace(_ point: CGPoint) -> CGPoint {
        // input point is in signed unit space: (-1,-1) to (1,1)
        // convert to gradient space: (0,0) to (1,1), with flipped Y axis
        return CGPoint(x: (point.x + 1) * 0.5, y: 1.0 - (point.y + 1) * 0.5)
    }
    
    private func pointForAngle(_ angle: CGFloat) -> CGPoint {
        // convert degrees to radians
        let radians = angle * .pi / 180.0
        var x = cos(radians)
        var y = sin(radians)
        // (x,y) is in terms unit circle. Extrapolate to unit square to get full vector length
        if (abs(x) > abs(y)) {
            // extrapolate x to unit length
            x = x > 0 ? 1 : -1
            y = x * tan(radians)
        } else {
            // extrapolate y to unit length
            y = y > 0 ? 1 : -1
            x = y / tan(radians)
        }
        return CGPoint(x: x, y: y)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.minimumScaleFactor = 0.5
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var borderColor: UIColor = .clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var maskToBounds: Bool = true {
        didSet{
            self.layer.masksToBounds = maskToBounds
        }
    }
    
    @IBInspectable public var shadowColor: UIColor = .clear {
        didSet{
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable public var textShadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet{
            self.layer.shadowOffset = textShadowOffset
        }
    }
    
    
    @IBInspectable public var shadowRadius: CGFloat = 0.0 {
        didSet{
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable public var shadowOpacity: Float = 0.0 {
        didSet{
            self.layer.shadowOpacity = shadowOpacity
        }
    }
}
