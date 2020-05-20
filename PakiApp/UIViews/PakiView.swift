//
//  PakiView.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class PakiView: ViewX, Reusable {
    
    var viewTag: Int = 0

    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(with paki: Paki) {
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.backgroundColor = UIColor.getColorFor(paki: paki)
    }
    
}
