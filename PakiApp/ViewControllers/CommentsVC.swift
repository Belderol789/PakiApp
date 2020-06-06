//
//  CommentsVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/23/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol CommentsVCProtocol: class {
    func showTabbarController()
}

class CommentsVC: GeneralViewController {
    // IBOutlets
    @IBOutlet weak var commentsContainer: ViewX!
    @IBOutlet weak var commentsCollection: UICollectionView!
    @IBOutlet weak var commentsField: UITextField!
    @IBOutlet weak var collectionContainer: ViewX!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageDisplayView: ImageDisplayView!
    // Constraints
    @IBOutlet weak var commentsHeightConst: NSLayoutConstraint!
    @IBOutlet weak var replyHeightConst: NSLayoutConstraint!
    // Variables
    weak var commentDelegate: CommentsVCProtocol?
    var commentHeight: CGFloat = 0 {
        didSet {
            print("CommentHeight \(commentHeight)")
            if commentHeight < view.frame.height - 100 {
              commentsHeightConst.constant = commentHeight
            }
        }
    }
    var currentPost: UserPost!
    var filteredComments: [UserPost] = []
    var allComments: [UserPost] = []
    
    weak var delegate: FeedPostProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideTabbar = true
        setupViewUI()
        getAllComments()
        AppStoreManager.requestReviewIfAppropriate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabbar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabbar = false
    }
    
    func getAllComments() {
        FirebaseManager.Instance.getAllCommentsFrom(post: currentPost, loginHandler: { (error) in
            if let err = error {
                self.showAlertWith(title: "Error Loading Comments", message: err, actions: [], hasDefaultOK: true)
            }
        }) { (post) in
            let allIds = self.allComments.map({$0.commentID})
            if let postID = post.commentID {
                if !allIds.contains(postID) {
                    self.allComments.append(post)
                    let text = post.content
                    let title = post.title
                    let titleHeight = title.returnStringHeight(fontSize: 15, width: self.commentsCollection.frame.width).height + 100
                    let feedHeight = text.returnStringHeight(fontSize: 13, width: self.commentsCollection.frame.width).height + titleHeight
                    self.commentHeight += feedHeight
                }
            }
            self.allComments.sort(by: {$0.datePosted < $1.datePosted})
            self.filteredComments = self.allComments
            self.commentsCollection.reloadData()
        }
    }

    func setupViewUI() {
        view.backgroundColor = UIColor.defaultBGColor
        commentsContainer.backgroundColor = UIColor.defaultFGColor
        commentsField.backgroundColor = UIColor.defaultBGColor
        commentsField.placeholder = "Write a comment"
        collectionContainer.backgroundColor = UIColor.defaultFGColor
        
        commentsCollection.register(CommentCollectionViewCell.nib, forCellWithReuseIdentifier: CommentCollectionViewCell.className)
        commentsCollection.register(CommentsHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentsHeaderView.className)
        commentsCollection.backgroundColor = .clear
        commentsCollection.delegate = self
        commentsCollection.dataSource = self
    }
    
    @IBAction func goToReplyVC(_ sender: UIButton) {
        if DatabaseManager.Instance.userIsLoggedIn {
            proceedToReplyPage()
        } else {
            alertUserToLogin()
        }
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        dismiss(animated: true)
        self.commentDelegate?.showTabbarController()
    }
}

// MARK: - UICollectionView
extension CommentsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredComments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comment = filteredComments[indexPath.item]
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.className, for: indexPath) as! CommentCollectionViewCell
        feedCell.delegate = self
        feedCell.commentKey = self.currentPost.commentKey
        feedCell.setupWith(userComment: comment)
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = filteredComments[indexPath.item].content
        let feedHeight = text.returnStringHeight(fontSize: 13, width: collectionView.frame.width - 50).height + 120
        return CGSize(width: collectionView.frame.size.width, height: feedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommentsHeaderView.className, for: indexPath) as! CommentsHeaderView
        header.commentCount = allComments.count
        header.delegate = self
        header.setupCommentsView(post: self.currentPost)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let text = self.currentPost.content
        let title = self.currentPost.title
        let media: CGFloat = self.currentPost.hasMedia ? 180 : 0
        let titleHeight = title.returnStringHeight(fontSize: 17, width: collectionView.frame.width).height + 180 + media
        let feedHeight = text.returnStringHeight(fontSize: 15, width: collectionView.frame.width).height + titleHeight
        if commentHeight == 0 {
           commentHeight += feedHeight
        }
        return CGSize(width: view.frame.size.width, height: feedHeight)
    }
    
}

// MARK: - CommentsHeaderProtocol

extension CommentsVC: CommentsHeaderProtocol, ReportViewProtocol, CommentCellProtocol {
    
    func didShowMediaView(images: [String]) {
        imageDisplayView.setupCollection(images: images)
        imageDisplayView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.imageDisplayView.alpha = 1
        }
    }
    
    func didTapProfile(post: UserPost) {
        let profileView = Bundle.main.loadNibNamed(ProfileView.className, owner: self, options: nil)?.first as! ProfileView
        profileView.frame = view.bounds
        profileView.setupProfile(user: post)
        view.addSubview(profileView)
    }
    
    func didSharePost(post: UserPost) {
        let activityVC = UIActivityViewController(activityItems: ["\(post.username) feeling \(post.paki) \nPosted on \(post.dateString) \n\nTitle: \(post.title) \n\nContent: \(post.content)"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func didReportComment(comment: UserPost) {
        if DatabaseManager.Instance.userIsLoggedIn {
            let reportView = Bundle.main.loadNibNamed(ReportView.className, owner: self, options: nil)?.first as! ReportView
            reportView.frame = view.bounds
            reportView.delegate = self
            reportView.reportedPost = comment
            view.addSubview(reportView)
            reportView.setupXib()
        } else {
            self.showAlertWith(title: "Authorization Required", message: "Kindly login or signup to continue", actions: [], hasDefaultOK: true)
        }
    }
    
    func didSubmitReportUser(post: UserPost) {
        if post.commentID != nil {
            guard let index = filteredComments.firstIndex(of: post) else { return }
            filteredComments.remove(at: index)
            commentsCollection.reloadData()
            
            let text = post.content
            let title = post.title
            let titleHeight = title.returnStringHeight(fontSize: 15, width: self.commentsCollection.frame.width).height + 100
            let feedHeight = text.returnStringHeight(fontSize: 13, width: self.commentsCollection.frame.width).height + titleHeight
            self.commentHeight -= feedHeight
            
        } else {
            FirebaseManager.Instance.reportPost(post: post)
        }
    }
    
    func reportPost(post: UserPost) {
        if DatabaseManager.Instance.userIsLoggedIn {
            let reportView = Bundle.main.loadNibNamed(ReportView.className, owner: self, options: nil)?.first as! ReportView
            reportView.frame = view.bounds
            reportView.delegate = self
            reportView.reportedPost = post
            view.addSubview(reportView)
            reportView.setupXib()
        } else {
            self.showAlertWith(title: "Authorization Required", message: "Kindly login or signup to continue", actions: [], hasDefaultOK: true)
        }
    }
    
    func starWasUpdated(post: UserPost) {
        self.delegate?.starWasUpdated(post: post)
    }
    
    func alertUserToLogin() {
        self.showAlertWith(title: "Login Required", message: "User must be authenticated to use this feature", actions: [], hasDefaultOK: true)
    }
    
    func proceedToReplyPage() {
        let replyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReplyVC") as! ReplyVC
        replyVC.currentPost = currentPost
        self.present(replyVC, animated: true, completion: nil)
    }
}

