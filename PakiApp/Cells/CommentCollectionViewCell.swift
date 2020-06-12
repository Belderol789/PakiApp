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

protocol CommentCellProtocol: class {
    func didReportComment(comment: UserPost)
    func didTapProfile(post: UserPost)
}

class CommentCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var commentStarLabel: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var commentUsername: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var pakiBar: UIView!
    @IBOutlet weak var profilePhoto: ImageViewX!
    @IBOutlet weak var starButton: UIButton!
    
    weak var delegate: CommentCellProtocol?
    var comment: UserPost!
    var commentKey: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        // Initialization code
    }
    
    func setupWith(userComment: UserPost) {
        comment = userComment
        commentText.text = userComment.content
        commentText.adjustsFontSizeToFitWidth = true
        commentUsername.text = userComment.username
        userComment.datePosted.getTimeDifference { (date) in
            self.commentDate.text = date
        }
        
        let color = UIColor.getColorFor(paki: userComment.pakiCase)
        pakiBar.backgroundColor = color
        profilePhoto.layer.borderColor = color.cgColor
        profilePhoto.layer.borderWidth = 1
        
        commentStarLabel.text = "\(userComment.starCount)"
        if let userId = DatabaseManager.Instance.mainUser.uid {
            let starImage: String = userComment.starList.contains(userId) ? "star-fill" : "star-empty"
            starButton.setImage(UIImage(named: starImage), for: .normal)
            starButton.tintColor = color
        }
        
        let pakiImage = UIImage(named: userComment.paki)
        if let photoString = userComment.profilePhotoURL, let url = URL(string: photoString) {
            profilePhoto.sd_setImage(with: url, placeholderImage: pakiImage, options: .continueInBackground, completed: nil)
        } else {
            profilePhoto.image = pakiImage
        }
    }
    
    @IBAction func didUpvoteComment(_ sender: UIButton) {
        if DatabaseManager.Instance.userIsLoggedIn {
            let currentCount = comment.starList.count + 1
            commentStarLabel.text = "\(currentCount)"
            
            sender.setImage(UIImage(named: "star-fill"), for: .normal)
            FirebaseManager.Instance.updateCommentStar(post: comment, commentKey: commentKey)
            FirebaseManager.Instance.updateUserStars(uid: comment.userUID)
        }
    }
    
    @IBAction func didTapReportButton(_ sender: UIButton) {
        self.delegate?.didReportComment(comment: comment)
    }
    
    @IBAction func didTapProfile(_ sender: UIButton) {
        self.delegate?.didTapProfile(post: comment)
    }
    
}
