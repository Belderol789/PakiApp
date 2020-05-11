//
//  CommentCollectionViewCell.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/11/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

struct UserComment {
    let username: String
    let datePosted: String
    let commentText: String
    let paki: Paki
    let profilePhotoURL: String?
}

class CommentCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var commentUsername: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var pakiBar: UIView!
    @IBOutlet weak var profilePhoto: ImageViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        // Initialization code
    }
    
    func setupWith(userComment: UserPost) {
        commentText.text = userComment.content
        commentUsername.text = userComment.username
        userComment.datePosted.getTimeDifference { (date) in
            self.commentDate.text = date
        }
        
        pakiBar.backgroundColor = UIColor.getColorFor(paki: userComment.pakiCase)
        
        let pakiImage = UIImage(named: userComment.paki)
        if let photoString = userComment.profilePhotoURL, let url = URL(string: photoString) {
            profilePhoto.sd_setImage(with: url, placeholderImage: pakiImage, options: .continueInBackground, completed: nil)
        } else {
            profilePhoto.image = pakiImage
        }
    }

}
