//
//  TutorialCollectionViewCell.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol ImageCollectionCellProtocol: class {
    func didRemoveImage(_ image: UIImage?)
}

class ImageCollectionCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: ImageViewX!
    weak var delegate: ImageCollectionCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

    }

    @IBAction func didTapRemoveImage(_ sender: UIButton) {
        delegate?.didRemoveImage(imageView.image)
    }
    
}
