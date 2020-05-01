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
    @IBOutlet weak var commentsCollection: UICollectionView!
    // Variables
    var currentPaki: Paki!
    var currentPost: UserPost!
    
    var filteredComments: [UserPost] = []
    var allComments: [UserPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideTabbar = true
        setupViewUI()
    }

    func setupViewUI() {
        view.backgroundColor = .systemBackground
        commentsCollection.register(FeedCollectionViewCell.nib, forCellWithReuseIdentifier: FeedCollectionViewCell.className)
        commentsCollection.register(CommentsHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentsHeaderView.className)
        commentsCollection.backgroundColor = .clear
        commentsCollection.delegate = self
        commentsCollection.dataSource = self
    }
    
    @IBAction func goToReplyVC(_ sender: UIButton) {
        let replyVC = storyboard?.instantiateViewController(identifier: "ReplyViewController") as! ReplyVC
        replyVC.currentPaki = currentPaki
        self.present(replyVC, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionView
extension CommentsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredComments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedPost = filteredComments[indexPath.item]
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCollectionViewCell.className, for: indexPath) as! FeedCollectionViewCell
        feedCell.feedContent.text = feedPost.content
        feedCell.setupCellWith(post: feedPost)
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = filteredComments[indexPath.item].content
        let feedHeight = text.returnStringHeight(width: view.frame.size.width, fontSize: 15).height + 150
        return CGSize(width: view.frame.size.width, height: feedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommentsHeaderView.className, for: indexPath) as! CommentsHeaderView
        header.setupCommentsView(color: UIColor.getColorFor(paki: currentPaki))
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let text = currentPost.content
        let feedHeight = text.returnStringHeight(width: view.frame.size.width, fontSize: 15).height + 150
        return .init(width: view.frame.width, height: feedHeight)
    }
    
}
