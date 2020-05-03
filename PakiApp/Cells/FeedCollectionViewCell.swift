//
//  FeedCollectionViewCell.swift
//  Paki
//
//  Created by Kem Belderol on 4/23/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

protocol FeedPostProtocol: class {
    func proceedToComments(post: UserPost)
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
        contentView.backgroundColor = .tertiarySystemGroupedBackground
        // Initialization code
    }
    
    func setupCommentCell(with post: UserPost) {
        feedStackHeightConst.constant = 0
        feedStack.isHidden = true
        feedTitle.text = ""
        
        let commentColor = UIColor.getColorFor(paki: post.pakiCase)
        
        feedContent.text = post.content
        feedUsername.text = post.username
        post.datePosted.getTimeDifference { (date) in
            self.feedDate.text = date
        }
        
        feedElipseBtn.tintColor = commentColor
        feedImageView.layer.borderColor = commentColor.cgColor
        
        if let photoURLString = post.profilePhotoURL {
            let url = URL(string: photoURLString)
            feedImageView.sd_setImage(with: url, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, completed: nil)
        }
    }
    
    func setupFeedCellWith(post: UserPost) {
        currentPost = post
        if let photoURLString = post.profilePhotoURL, let photoURL = URL(string: photoURLString) {
            feedImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, context: nil)
        }
        cellColor = UIColor.getColorFor(paki: post.pakiCase)
        feedImageView.layer.borderColor = cellColor.cgColor
        feedContent.text = post.content
        feedTitle.text = post.title
        
        feedUsername.text = post.username
        post.datePosted.getTimeDifference { (date) in
            self.feedDate.text = date
        }
        
        if let userID = DatabaseManager.Instance.mainUser.uid {
            let starBool = post.starList.contains(userID)
            let image = starBool ? "star.fill" : "star"
            starCount = post.starCount
            feedStarBtn.isUserInteractionEnabled = !starBool
            feedStarBtn.setImage(UIImage.init(systemName: image), for: .normal)
            feedStarBtn.tintColor = starBool ? cellColor : .systemGray
        }
    }
    
    @IBAction func didFavourite(_ sender: UIButton) {
        feedStarBtn.setImage(UIImage(named: "star.fill"), for: .normal)
        feedStarBtn.tintColor = cellColor
        starCount += 1
        sender.setTitle("\(starCount)", for: .normal)
        FirebaseManager.Instance.updatePostsStar(userPost: currentPost)
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
