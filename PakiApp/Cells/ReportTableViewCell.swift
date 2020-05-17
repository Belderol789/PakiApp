//
//  ReportTableViewCell.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/17/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell, Reusable {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: ViewX!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var containerView: ViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.containerView.backgroundColor = UIColor.defaultFGColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(report: Report) {
        iconView.layer.cornerRadius = iconView.frame.height / 2
        iconView.backgroundColor = UIColor.getColorFor(paki: report.color)
        reportLabel.text = report.report
        reportLabel.adjustsFontSizeToFitWidth = true
        iconImageView.image = UIImage(named: report.imageName)
    }
    
}
