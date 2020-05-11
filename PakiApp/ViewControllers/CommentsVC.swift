//
//  CommentsVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/23/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class CommentsVC: GeneralViewController {
    // IBOutlets
    @IBOutlet weak var commentsContainer: ViewX!
    @IBOutlet weak var commentsCollection: UICollectionView!
    @IBOutlet weak var commentsField: UITextField!
    @IBOutlet weak var collectionContainer: ViewX!
    // Constraints
    @IBOutlet weak var commentsHeightConst: NSLayoutConstraint!
    @IBOutlet weak var replyHeightConst: NSLayoutConstraint!
    // Variables
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideTabbar = true
        setupViewUI()
        getAllComments()
        
        // Test
        filteredComments = TestManager.returnCommentPosts()
        allComments = TestManager.returnCommentPosts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func getAllComments() {
        FirebaseManager.Instance.getAllCommentsFrom(post: currentPost, loginHandler: { (error) in
            if let err = error {
                self.showAlertWith(title: "Error Loading Comments", message: err, actions: [], hasDefaultOK: true)
            }
        }) { (post) in
            self.filteredComments.append(post)
            self.allComments.append(post)
            self.commentsCollection.reloadData()
        }
    }

    func setupViewUI() {
        view.backgroundColor = UIColor.defaultBGColor
        commentsContainer.backgroundColor = UIColor.defaultFGColor
        commentsField.backgroundColor = UIColor.defaultBGColor
        collectionContainer.backgroundColor = UIColor.defaultFGColor
        
        commentsCollection.register(CommentCollectionViewCell.nib, forCellWithReuseIdentifier: CommentCollectionViewCell.className)
        commentsCollection.register(CommentsHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentsHeaderView.className)
        commentsCollection.backgroundColor = .clear
        commentsCollection.delegate = self
        commentsCollection.dataSource = self
    }
    
    @IBAction func goToReplyVC(_ sender: UIButton) {
        proceedToReplyPage()
//        if DatabaseManager.Instance.userIsLoggedIn {
//
//        } else {
//            alertUserToLogin()
//        }
    }
}

// MARK: - UICollectionView
extension CommentsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comment = filteredComments[indexPath.item]
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.className, for: indexPath) as! CommentCollectionViewCell
        feedCell.setupWith(userComment: comment)
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = filteredComments[indexPath.item].content
        let title = filteredComments[indexPath.item].title
        let titleHeight = title.returnStringHeight(fontSize: 15, width: collectionView.frame.width).height + 100
        let feedHeight = text.returnStringHeight(fontSize: 13, width: collectionView.frame.width).height + titleHeight
        commentHeight += feedHeight
        return CGSize(width: collectionView.frame.size.width, height: feedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommentsHeaderView.className, for: indexPath) as! CommentsHeaderView
        header.delegate = self
        header.setupCommentsView(post: currentPost)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let text = currentPost.content
        let title = currentPost.title
        let titleHeight = title.returnStringHeight(fontSize: 17, width: collectionView.frame.width).height + 180
        let feedHeight = text.returnStringHeight(fontSize: 15, width: collectionView.frame.width).height + titleHeight
        commentHeight += feedHeight
        return CGSize(width: view.frame.size.width, height: feedHeight)
    }
    
}

// MARK: - CommentsHeaderProtocol

extension CommentsVC: CommentsHeaderProtocol {
    func alertUserToLogin() {
        self.showAlertWith(title: "Login Required", message: "User must be authenticated to use this feature", actions: [], hasDefaultOK: true)
    }
    
    func proceedToReplyPage() {
        let replyVC = storyboard?.instantiateViewController(identifier: "ReplyViewController") as! ReplyVC
        replyVC.currentPost = currentPost
        self.present(replyVC, animated: true, completion: nil)
    }
}

