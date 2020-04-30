//
//  CommentsHeaderView.swift
//  Paki
//
//  Created by Kem Belderol on 4/24/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class CommentsHeaderView: UICollectionReusableView, Reusable {
    
    @IBOutlet weak var userProfilePhoto: ImageViewX!
    
    @IBOutlet weak var postFavBtn: UIButton!
    @IBOutlet weak var postReplyBtn: UIButton!
    @IBOutlet weak var postShareBtn: UIButton!
    @IBOutlet weak var postOptionsBtn: UIButton!
    
    @IBOutlet var postBtns: [UIButton]!
    
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postUsernameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var commentsSegment: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .systemBackground
    }
    
    func setupCommentsView(color: UIColor) {
        userProfilePhoto.layer.borderColor = color.cgColor
        postBtns.forEach({$0.tintColor = color})
    }
    
    @IBAction func segmentControllerDidChange(_ sender: UISegmentedControl) {
         sender.changeUnderlinePosition()
     }
    
}
