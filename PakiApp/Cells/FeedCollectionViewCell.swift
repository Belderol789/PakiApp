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
    
    func setupCellWith(post: UserPost) {
        currentPost = post
        if let photoURLString = post.profilePhotoURL, let photoURL = URL(string: photoURLString) {
            feedImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, context: nil)
        }
        cellColor = UIColor.getColorFor(paki: Paki(rawValue: post.paki)!)
        feedImageView.layer.borderColor = cellColor.cgColor
        feedContent.text = post.content
        feedTitle.text = post.title
        
        feedUsername.text = post.username
        feedDate.text = post.datePosted
        
        if let userID = DatabaseManager.Instance.mainUser.uid {
            let starBool = post.starCount.contains(userID)
            let image = starBool ? "star.fill" : "star"
            starCount = post.starCount.count
            feedStarBtn.setImage(UIImage(named: image), for: .normal)
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
