//
//  PakiCollectionViewCell.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/9/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class PakiCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var pakiIcon: UIImageView!
    @IBOutlet weak var pakiLabel: UILabel!
    @IBOutlet weak var containerView: ViewX!
    @IBOutlet weak var labelLeadingConst: NSLayoutConstraint!
    
    var selectedPaki: Paki = .all
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupWith(paki: Paki) {
        let pakiColor = UIColor.getColorFor(paki: paki)
        labelLeadingConst.constant = paki == .all ? 8 : 42

        containerView.backgroundColor = UIColor.defaultFGColor
        containerView.layer.borderColor = (selectedPaki == paki) ? pakiColor.cgColor : UIColor.defaultBGColor.cgColor
        
        pakiIcon.image = UIImage(named: paki.rawValue)
        pakiLabel.text = paki.rawValue.capitalized
        pakiLabel.textColor = pakiColor
    }

}
