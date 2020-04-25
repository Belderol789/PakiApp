//
//  FeedCollectionViewCell.swift
//  Paki
//
//  Created by Kem Belderol on 4/23/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var feedImageView: ImageViewX!
    @IBOutlet weak var feedContent: UILabel!
    @IBOutlet weak var feedTitle: UILabel!
    
    @IBOutlet weak var feedStarBtn: UIButton!
    @IBOutlet weak var feedCommentsBtn: UIButton!
    @IBOutlet weak var feedElipseBtn: UIButton!
    @IBOutlet weak var feedShareBtn: UIButton!
    
    @IBOutlet var feedBtns: [UIButton]!
    @IBOutlet weak var feedStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .tertiarySystemGroupedBackground
        // Initialization code
    }
    
    func setupCellWith(color: UIColor) {
        feedImageView.layer.borderColor = color.cgColor
        feedBtns.forEach({$0.tintColor = color})
    }

}
