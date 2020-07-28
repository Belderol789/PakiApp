//
//  LabelX.swift
//  PakiApp
//
//  Created by Kem Belderol on 1/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

@IBDesignable
class LabelX: UILabel {

    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
          didSet{
              self.layer.cornerRadius = cornerRadius
          }
      }
      
    @IBInspectable public var shadowColour: UIColor = .clear {
          didSet{
              self.layer.shadowColor = shadowColour.cgColor
          }
      }
      
      @IBInspectable public var textShadowOffset: CGSize = CGSize(width: 0, height: 0) {
          didSet{
              self.layer.shadowOffset = textShadowOffset
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
