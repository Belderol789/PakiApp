//
//  CalendarCollectionViewCell.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

class CalendarCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var containerView: ViewX!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateView: ViewX!
    @IBOutlet weak var dividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCalendarView(post: UserPost) {
        let color = UIColor.getColorFor(paki: post.pakiCase)
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        dividerView.backgroundColor = color
        containerView.backgroundColor = UIColor.defaultFGColor
        containerView.layer.borderWidth = 0
        dateView.backgroundColor = color
        
        titleLabel.text = post.title
        contentLabel.text = post.content
        post.datePosted.getTimeDifference { (date) in
            self.dateLabel.text = date
            self.dateLabel.adjustsFontSizeToFitWidth = true
        }
    }
}
