//
//  CalendarCollectionViewCell.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var userProfilePic: ImageViewX!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    
    @IBOutlet var calendarBtns: [ButtonX]!
    @IBOutlet weak var containerView: ViewX!
    
    @IBOutlet weak var headerView: ViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func setupCalendarView(paki: Paki) {
        let color = UIColor.getColorFor(paki: paki)
        calendarBtns.forEach({$0.tintColor = .white})

        headerView.backgroundColor = color
    }

}
