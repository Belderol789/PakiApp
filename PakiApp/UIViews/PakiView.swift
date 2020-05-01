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
        self.layer.borderColor = UIColor.systemBackground.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.getColorFor(paki: paki)
    }
    
}
