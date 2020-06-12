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
    func starWasUpdated(post: UserPost)
    func reportPost(post: UserPost)
    func didSharePost(post: UserPost)
    func didTapProfile(post: UserPost)
    func didShowMediaView(images: [String])
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
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var collectionContainer: UIView!
    @IBOutlet weak var mediaHeightConst: NSLayoutConstraint!
    
    weak var delegate: CommentsHeaderProtocol?
    var currentPost: UserPost!
    var commentCount: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    func setupCommentsView(post: UserPost) {
        currentPost = post
        let color = UIColor.getColorFor(paki: post.pakiCase)
        postUsernameLabel.textColor = color
        userProfilePhoto.layer.borderColor = color.cgColor
        userProfilePhoto.sd_setImage(with: post.photoURL, placeholderImage: UIImage(named: post.paki), options: .continueInBackground, completed: nil)
        
        postFavBtn.setTitle("\(post.starCount)", for: .normal)
        
        if let count = commentCount {
            postReplyBtn.setTitle(" \(count)", for: .normal)
        }
        
        containerView.backgroundColor = UIColor.defaultFGColor
        containerView.layer.borderColor = color.cgColor
        containerView.layer.shadowColor = color.cgColor
        
        postTitleLabel.text = post.title
        postContentLabel.text = post.content
        postUsernameLabel.text = post.username
        post.datePosted.getTimeDifference { (date) in
            self.postDateLabel.text = date
        }
        
        postFavBtn.tintColor = .systemGray
        postFavBtn.setImage(UIImage(named: "star-empty"), for: .normal)
        
        postBtns.forEach({
            $0.tintColor = color
            $0.setTitleColor(.white, for: .normal)
        })
        
        if let userID = DatabaseManager.Instance.mainUser.uid {
            let starBool = post.starList.contains(userID)
            let image = starBool ? "star-fill" : "star-empty"
            postFavBtn.isUserInteractionEnabled = !starBool
            postFavBtn.setImage(UIImage(named: image), for: .normal)
        }
        
        postCollectionView.register(ImageCollectionCell.nib, forCellWithReuseIdentifier: ImageCollectionCell.className)
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        postCollectionView.backgroundColor = .clear
        collectionContainer.isHidden = !post.hasMedia
        mediaHeightConst.constant = post.hasMedia ? 170 : 0
    }
    
    func updateComments(count: Int) {
        postReplyBtn.setTitle("\(count)", for: .normal)
    }

    @IBAction func favouriteTapped(_ sender: UIButton) {
        if DatabaseManager.Instance.userIsLoggedIn {
            let updatedCount = currentPost.starCount + 1
            let color = UIColor.getColorFor(paki: currentPost.pakiCase)
            
            postFavBtn.setTitle(" \(updatedCount)", for: .normal)
            postFavBtn.setImage(UIImage(named: "star-fill"), for: .normal)
            postFavBtn.tintColor = color
            
            FirebaseManager.Instance.updatePostsStar(userPost: currentPost)
            FirebaseManager.Instance.updateUserStars(uid: currentPost.userUID)
            self.delegate?.starWasUpdated(post: currentPost)
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
        self.delegate?.didSharePost(post: currentPost)
    }
    
    @IBAction func didTapElipseButton(_ sender: UIButton) {
        self.delegate?.reportPost(post: currentPost)
    }
    
    @IBAction func didTapProfile(_ sender: UIButton) {
        self.delegate?.didTapProfile(post: currentPost)
    }
    
    @IBAction func didViewMedia(_ sender: UIButton) {
        self.delegate?.didShowMediaView(images: Array(currentPost.mediaURLs))
    }
    
}

extension CommentsHeaderView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

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
            let randomzier = CGFloat.random(in: 100...150)
            let itemSize: CGFloat = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 3
            return CGSize(width: itemSize, height: randomzier)
        }
    }
}
