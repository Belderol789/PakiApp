//
//  TutorialCollectionViewCell.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var imageView: ImageViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

    }

}
