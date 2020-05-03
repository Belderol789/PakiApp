//
//  FeedVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SJFluidSegmentedControl

class FeedVC: GeneralViewController {
    
    // IBOutlets
    @IBOutlet weak var feedCollection: UICollectionView!
    @IBOutlet weak var credentialView: UIVisualEffectView!
    @IBOutlet weak var loadingView: LoadingView!
    // Variables
    var filteredPosts: [UserPost] = []
    var allPosts: [UserPost] = []
    var currentPaki: Paki = .awesome {
        didSet {
            feedCollection.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewUI()
        setupCountDown()
        getPosts(for: currentPaki)
        NotificationCenter.default.addObserver(self, selector: #selector(activateEmojiView(notification:)), name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Functions
    fileprivate func setupViewUI() {
        view.backgroundColor = .systemBackground
        feedCollection.register(FeedCollectionViewCell.nib, forCellWithReuseIdentifier: FeedCollectionViewCell.className)
        feedCollection.register(FeedHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeedHeaderView.className)
        feedCollection.backgroundColor = .clear
        feedCollection.delegate = self
        feedCollection.dataSource = self
        //KemTest
        credentialView.isHidden = DatabaseManager.Instance.userIsLoggedIn
        
        hideTabbar = !DatabaseManager.Instance.userIsLoggedIn
        activateEmojiView(notification: nil)
    }
    
    @objc
    func activateEmojiView(notification: Notification?) {
        if DatabaseManager.Instance.userIsLoggedIn && !DatabaseManager.Instance.userHasAnswered {
            credentialView.isHidden = true
            setupEmojiView()
        }
    }
    
    fileprivate func setupEmojiView() {
        hideTabbar = true
        tabBarController?.tabBar.isHidden = true
        let emojiView = Bundle.main.loadNibNamed(AnswerView.className, owner: self, options: nil)?.first as! AnswerView
        emojiView.delegate = self
        emojiView.frame = self.view.bounds
        emojiView.setupEmojiView()
        emojiView.getUpdatedPakiCount()
        view.addSubview(emojiView)
    }
    
    fileprivate func getPosts(for paki: Paki) {
        filteredPosts.removeAll()
        FirebaseManager.Instance.getPostFor(paki: paki) { (userPost) in
            if let post = userPost {
                self.filteredPosts.append(post)
                self.allPosts.append(post)
                self.feedCollection.reloadData()
            }
            self.loadingView.stopLoading()
        }
    }
    
    // MARK: - IBActions
    @IBAction func didSelectCredential(_ sender: ButtonX) {
        let credentialVC = storyboard?.instantiateViewController(identifier: CredentialVC.className) as! CredentialVC
        credentialVC.isLogin = (sender.tag == 1)
        navigationController?.pushViewController(credentialVC, animated: true)
    }
    
}

// MARK: - AnswerView
extension FeedVC: AnswerViewProtocol {
    func didFinishAnswer() {
        DatabaseManager.Instance.updateUserDefaults(value: true, key: .userHasAnswered)
        tabBarController?.tabBar.isHidden = false
        getPosts(for: currentPaki)
    }
}

// MARK: - UITableView
extension FeedVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedPost = filteredPosts[indexPath.item]
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCollectionViewCell.className, for: indexPath) as! FeedCollectionViewCell
        feedCell.delegate = self
        feedCell.setupCellWith(post: feedPost)
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = filteredPosts[indexPath.item].content
        let feedHeight = text.returnStringHeight(width: view.frame.size.width, fontSize: 15).height + 150
        return CGSize(width: view.frame.size.width, height: feedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FeedHeaderView", for: indexPath) as! FeedHeaderView
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
    
}
// MARK: - FeedHeaderProtocol
extension FeedVC: FeedHeaderProtocol, FeedPostProtocol {
    
    func proceedToComments(post: UserPost) {
        let commentsVC = storyboard?.instantiateViewController(identifier: "CommentsVC") as! CommentsVC
        commentsVC.currentPost = post
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func didChoosePaki(_ paki: Paki) {
        
        loadingView.stopLoading()
        loadingView.setupCircleViews(paki: paki)
        loadingView.startLoading()
        currentPaki = paki
        
        filteredPosts = allPosts.filter({$0.paki == paki.rawValue})
        if filteredPosts.isEmpty {
            getPosts(for: paki)
        } else {
            self.loadingView.stopLoading()
           feedCollection.reloadData()
        }
    }
}

