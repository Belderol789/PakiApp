//
//  ImageViewX.swift
//  Tops
//
//  Created by Kem Belderol on 22/03/2018.
//  Copyright © 2018 Kem Belderol. All rights reserved.
//

import UIKit
@IBDesignable

class ImageViewX: UIImageView {

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
