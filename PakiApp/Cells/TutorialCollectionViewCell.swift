//
//  TutorialCollectionViewCell.swift
//  PakiApp
//
//  Created by Kem Belderol on 7/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

struct Tutorial {
    let title: String
    let text: String
    let image: UIImage
}

class TutorialCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tutorialTitle: UILabel!
    @IBOutlet weak var tutorialText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setupTutorialCell(tutorial: Tutorial) {
        tutorialTitle.text = tutorial.title
        tutorialText.text = tutorial.text
        tutorialImage.image = tutorial.image
    }

}
