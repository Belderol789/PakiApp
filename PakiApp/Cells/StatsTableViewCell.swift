//
//  StatsTableViewCell.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell, Reusable {
    
    @IBOutlet weak var pakiLabel: UILabel!
    @IBOutlet weak var pakiCountLabel: UILabel!
    @IBOutlet weak var pakiProgress: UIProgressView!
    @IBOutlet weak var pakiImageView: UIImageView!
    
    var totalCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(withPaki: Paki, count: Int) {
        let pakiColor = UIColor.getColorFor(paki: withPaki)
        pakiImageView.image = UIImage(named: withPaki.rawValue)
        
        pakiLabel.text = withPaki.rawValue.capitalized
        pakiCountLabel.text = "\(count)"
        pakiCountLabel.textColor = pakiColor
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        pakiProgress.progressTintColor = pakiColor
        pakiProgress.trackTintColor = UIColor.defaultBGColor
        
        if totalCount > 0 {
            self.pakiProgress.progress = Float(count)/Float(totalCount)
            print("Progress \(self.pakiProgress.progress)")
        }
    }
    
}
