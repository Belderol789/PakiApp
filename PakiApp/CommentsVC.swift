//
//  CommentsVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/23/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

struct Post {
    let username: String
    let dateToday: String
    let title: String
    let content: String
    let profilePhoto: String?
}

class CommentsVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var commentsCollection: UICollectionView!
    
    // Variables
    var currentPaki: Paki!
    var currentPost: Post!
    
    var testContent: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
        let replyVC = storyboard?.instantiateViewController(identifier: "ReplyViewController") as! ReplyViewController
        replyVC.currentPaki = currentPaki
        self.present(replyVC, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionView
extension CommentsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCollectionViewCell.className, for: indexPath) as! FeedCollectionViewCell
        feedCell.feedContent.text = testContent[indexPath.item]
        feedCell.setupCellWith(color: UIColor.systemGreen)
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = testContent[indexPath.item]
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
