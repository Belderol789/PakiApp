//
//  FeedCollectionViewCell.swift
//  Paki
//
//  Created by Kem Belderol on 4/23/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds

protocol FeedPostProtocol: class {
    func proceedToComments(post: UserPost)
    func starWasUpdated(post: UserPost)
}

class FeedCollectionViewCell: UICollectionViewCell, Reusable {
    // IBOutlets
    @IBOutlet weak var feedUsername: UILabel!
    @IBOutlet weak var feedDate: UILabel!
    
    @IBOutlet weak var feedImageView: ImageViewX!
    @IBOutlet weak var feedContent: UILabel!
    @IBOutlet weak var feedTitle: UILabel!
    
    @IBOutlet weak var feedStarBtn: UIButton!
    @IBOutlet weak var feedCommentsBtn: UIButton!
    @IBOutlet weak var feedElipseBtn: UIButton!
    @IBOutlet weak var feedShareBtn: UIButton!
    
    @IBOutlet var feedBtns: [UIButton]!
    @IBOutlet weak var feedStack: UIStackView!
    @IBOutlet weak var feedStackContainer: UIView!
    
    @IBOutlet weak var containerView: ViewX!
    // Constraints
    @IBOutlet weak var feedStackHeightConst: NSLayoutConstraint!
    
    // Variables
    let starImage = "star"
    let commentImage = "bubble.left.and.bubble.right"
    let shareImage = "arrowshape.turn.up.right"
    
    var starCount: Int = 0
    var currentPost: UserPost!
    
    weak var delegate: FeedPostProtocol?
     
    var cellColor: UIColor = .lightGray

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = UIColor.defaultFGColor
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        // Initialization code
    }
    
    func setupFeedCellWith(ad: GADUnifiedNativeAd) {
        
    }
    
    func setupFeedCellWith(post: UserPost) {
        currentPost = post
        if let photoURLString = post.profilePhotoURL, let photoURL = URL(string: photoURLString) {
            feedImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, context: nil)
        } else {
            feedImageView.image = UIImage(named: post.paki)
        }
        cellColor = UIColor.getColorFor(paki: post.pakiCase)
        let containerLayer = containerView.layer
        containerLayer.borderColor = cellColor.cgColor
        containerLayer.borderWidth = 0
        containerLayer.shadowRadius = 1
        containerLayer.shadowOffset = CGSize(width: 0, height: 1)
        containerLayer.shadowOpacity = 1
        containerLayer.shadowColor = cellColor.cgColor
        
        containerView.backgroundColor = UIColor.defaultFGColor
        
        feedImageView.layer.borderColor = cellColor.cgColor
        feedImageView.tintColor = cellColor
        feedImageView.backgroundColor = .clear
        
        feedContent.text = post.content
        feedTitle.text = post.title
        
        feedUsername.text = post.username
        post.datePosted.getTimeDifference { (date) in
            self.feedDate.text = date
        }
        
        feedBtns.forEach({
            $0.tintColor = cellColor
            $0.setTitleColor(.white, for: .normal)
        })
        
        if let userID = DatabaseManager.Instance.mainUser.uid {
            let starBool = post.starList.contains(userID)
            let image = starBool ? "star.fill" : "star"
            starCount = post.starCount
            feedStarBtn.isUserInteractionEnabled = !starBool
            feedStarBtn.setImage(UIImage.init(systemName: image), for: .normal)
            feedStarBtn.setTitle("\(post.starCount)", for: .normal)
        }
    }
    
    @IBAction func didFavourite(_ sender: UIButton) {
        if DatabaseManager.Instance.userIsLoggedIn {
            let updatedCount = currentPost.starCount + 1
            let color = UIColor.getColorFor(paki: currentPost.pakiCase)
            
            feedStarBtn.setTitle("\(updatedCount)", for: .normal)
            feedStarBtn.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
            feedStarBtn.tintColor = color
            
            FirebaseManager.Instance.updatePostsStar(userPost: currentPost)
            FirebaseManager.Instance.updateUserStars(uid: currentPost.uid)
            self.delegate?.starWasUpdated(post: currentPost)
        }
    }
    
    @IBAction func didComment(_ sender: UIButton) {
        self.delegate?.proceedToComments(post: currentPost)
    }
    
    @IBAction func didShare(_ sender: UIButton) {
        
    }
    
    fileprivate func setupButton(button: UIButton, forImage: String, count: Int) {
        let imageName = count > 0 ? forImage + ".fill" : forImage
        button.setImage(UIImage.init(systemName: imageName), for: .normal)
        button.tintColor = count > 0 ? cellColor : .systemGray
    }

}
