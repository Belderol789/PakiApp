//
//  CommentsHeaderView.swift
//  Paki
//
//  Created by Kem Belderol on 4/24/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

protocol CommentsHeaderProtocol: class {
    func alertUserToLogin()
    func proceedToReplyPage()
}

class CommentsHeaderView: UICollectionReusableView, Reusable {
    
    @IBOutlet weak var userProfilePhoto: ImageViewX!
    @IBOutlet weak var containerView: ViewX!
    
    @IBOutlet weak var postFavBtn: UIButton!
    @IBOutlet weak var postReplyBtn: UIButton!
    @IBOutlet weak var postShareBtn: UIButton!
    @IBOutlet weak var postOptionsBtn: UIButton!
    
    @IBOutlet var postBtns: [UIButton]!
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postUsernameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!

    weak var delegate: CommentsHeaderProtocol?
    var currentPost: UserPost!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    func setupCommentsView(post: UserPost) {
        currentPost = post
        let color = UIColor.getColorFor(paki: post.pakiCase)
        
        userProfilePhoto.layer.borderColor = color.cgColor
        userProfilePhoto.sd_setImage(with: post.photoURL, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, completed: nil)
        
        postFavBtn.setTitle("\(post.starCount)", for: .normal)
        
        containerView.backgroundColor = UIColor.defaultFGColor
        containerView.layer.borderColor = color.cgColor
        
        postTitleLabel.text = post.title
        postContentLabel.text = post.content
        postUsernameLabel.text = post.username
        post.datePosted.getTimeDifference { (date) in
            self.postDateLabel.text = date
        }
        
        postFavBtn.tintColor = .systemGray
        postFavBtn.setImage(UIImage.init(systemName: "star"), for: .normal)
        
        if let userID = DatabaseManager.Instance.mainUser.uid {
            let starBool = post.starList.contains(userID)
            let image = starBool ? "star.fill" : "star"
            postFavBtn.isUserInteractionEnabled = !starBool
            postFavBtn.setImage(UIImage.init(systemName: image), for: .normal)
            postFavBtn.tintColor = starBool ? color : .systemGray
        }
    }
    
    func updateComments(count: Int) {
        postReplyBtn.setTitle("\(count)", for: .normal)
    }

    @IBAction func favouriteTapped(_ sender: UIButton) {
        if DatabaseManager.Instance.userIsLoggedIn {
            let updatedCount = currentPost.starCount + 1
            let color = UIColor.getColorFor(paki: currentPost.pakiCase)
            
            postFavBtn.setTitle("\(updatedCount)", for: .normal)
            postFavBtn.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
            postFavBtn.tintColor = color
            
            FirebaseManager.Instance.updatePostsStar(userPost: currentPost)
        } else {
            self.delegate?.alertUserToLogin()
        }
    }
    
    @IBAction func replyTapped(_ sender: UIButton) {
        if DatabaseManager.Instance.userIsLoggedIn {
            self.delegate?.proceedToReplyPage()
        } else {
            self.delegate?.alertUserToLogin()
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
    }
}
