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
    func didReportUser(post: UserPost)
    func didSharePost(post: UserPost)
    func didViewProfile(uid: UserPost)
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
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    @IBOutlet weak var containerView: ViewX!
    // Constraints
    @IBOutlet weak var feedStackHeightConst: NSLayoutConstraint!
    @IBOutlet weak var mediaHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var nsfwBlurView: UIVisualEffectView!
    
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
    }

    func setupFeedCellWith(post: UserPost) {
        currentPost = post
        if let photoURLString = post.profilePhotoURL, let photoURL = URL(string: photoURLString) {
            feedImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, context: nil)
        } else {
            feedImageView.image = UIImage(named: post.paki)
        }
        
        nsfwBlurView.isHidden = !post.nsfw
        
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
        
        if let uid = DatabaseManager.Instance.mainUser.uid {
            feedElipseBtn.isHidden = uid == post.userUID
        }
        
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
            let image = starBool ? "star-fill" : "star-empty"
            starCount = post.starCount
            feedStarBtn.isUserInteractionEnabled = !starBool
            
            feedStarBtn.setImage(UIImage(named: image), for: .normal)
        }
        feedStarBtn.setTitle("   \(post.starCount)", for: .normal)

        mediaCollectionView.register(ImageCollectionCell.nib, forCellWithReuseIdentifier: ImageCollectionCell.className)
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.backgroundColor = .clear
        mediaHeightConst.constant = post.hasMedia ? 170 : 0
        
        mediaCollectionView.reloadData()
    }
    
    @IBAction func didRemoveNSFWView(_ sender: UIButton) {
        if DatabaseManager.Instance.mainUser.uid != nil {
            self.nsfwBlurView.isHidden = true
        }
    }
    
    
    @IBAction func didFavourite(_ sender: UIButton) {
        if DatabaseManager.Instance.userIsLoggedIn {
            let updatedCount = currentPost.starCount + 1
            let color = UIColor.getColorFor(paki: currentPost.pakiCase)
            
            feedStarBtn.setTitle("\(updatedCount)", for: .normal)
            feedStarBtn.setImage(UIImage(named: "star-fill"), for: .normal)
            feedStarBtn.tintColor = color
            
            FirebaseManager.Instance.updatePostsStar(userPost: currentPost)
            FirebaseManager.Instance.updateUserStars(uid: currentPost.userUID)
            self.delegate?.starWasUpdated(post: currentPost)
        }
    }
    
    @IBAction func didComment(_ sender: UIButton) {
        self.delegate?.proceedToComments(post: currentPost)
    }
    
    @IBAction func didShare(_ sender: UIButton) {
        self.delegate?.didSharePost(post: currentPost)
    }
    
    @IBAction func didTapElipse(_ sender: UIButton) {
        self.delegate?.didReportUser(post: currentPost)
    }
    
    @IBAction func didTapProfile(_ sender: UIButton) {
        self.delegate?.didViewProfile(uid: currentPost)
    }
    
    
    fileprivate func setupButton(button: UIButton, forImage: String, count: Int) {
        let imageName = count > 0 ? forImage + "-fill" : forImage
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = count > 0 ? cellColor : .systemGray
    }

}

extension FeedCollectionViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPost.mediaURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionCell", for: indexPath as IndexPath) as! ImageCollectionCell
        let mediaURLs = currentPost.mediaURLs
        cell.imageView.sd_setImage(with: URL(string: mediaURLs[indexPath.item]), completed: nil)
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.backgroundColor = UIColor.defaultFGColor
        cell.imageView.layer.cornerRadius = 15
        cell.imageView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentPost.mediaURLs.count == 1 {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        } else {
            let collectionHeight = collectionView.frame.height
            let randomzier = CGFloat.random(in: (collectionHeight - 20)...collectionHeight)
            let itemSize: CGFloat = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
            return CGSize(width: itemSize, height: randomzier)
        }
    }
}
