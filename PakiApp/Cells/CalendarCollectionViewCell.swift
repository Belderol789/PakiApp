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
    
    @IBOutlet weak var userProfilePic: ImageViewX!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    
    @IBOutlet var calendarBtns: [ButtonX]!
    @IBOutlet weak var containerView: ViewX!
    
    @IBOutlet weak var headerView: ViewX!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCalendarView(post: UserPost) {
        let color = UIColor.getColorFor(paki: post.pakiCase)
        calendarBtns.forEach({$0.tintColor = .white})
        containerView.layer.shadowColor = color.cgColor
        headerView.backgroundColor = color
        
        starsLabel.text = "\(post.starCount)"
        commentsLabel.text = "\(post.commentCount)"
        sharesLabel.text = "\(post.shareCount)"
        
        titleLabel.text = post.title
        contentLabel.text = post.content
        dateLabel.text = post.datePosted
        if let photoURL = post.photoURL {
            userProfilePic.sd_setImage(with: photoURL, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, completed: nil)
        } else {
            userProfilePic.image = UIImage(named: post.paki)
        }
    }
}
