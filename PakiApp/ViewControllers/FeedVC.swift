//
//  FeedVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class FeedVC: GeneralViewController {
    
    // IBOutlets
    @IBOutlet weak var feedCollection: UICollectionView!
    @IBOutlet weak var credentialView: UIVisualEffectView!
    @IBOutlet weak var loadingView: LoadingView!
    private let refreshControl = UIRefreshControl()
    //Constraints
    @IBOutlet weak var credentialHeight: NSLayoutConstraint!
    // Variables
    var filteredPosts: [UserPost] = []
    var allPosts: [UserPost] = []
    
    let allPakis: [Paki] = [.awesome, .good, .meh, .bad, .terrible]
    var currentPaki: Paki = .all {
        didSet {
            feedCollection.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentText = "Hello World"
        loadingView.blurView.effect = nil
        credentialHeight.constant = self.view.frame.height / 4
        setupViewUI()
        resetUserEmoji()
        setupCountDown()
        getAllPosts(done: {
            let pakiDict: [String] = self.allPosts.map({$0.paki})
            DatabaseManager.Instance.updateUserDefaults(value: pakiDict, key: .allPakis)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllPakis"), object: pakiDict)
        })
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
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.defaultPurple
        feedCollection.alwaysBounceVertical = true
        feedCollection.refreshControl = refreshControl
        
        feedCollection.register(FeedCollectionViewCell.nib, forCellWithReuseIdentifier: FeedCollectionViewCell.className)
        feedCollection.register(FeedHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeedHeaderView.className)
        feedCollection.backgroundColor = .clear
        feedCollection.delegate = self
        feedCollection.dataSource = self

        credentialView.layer.cornerRadius = 15
    }
    
    func checkIfUserLoggedIn() {
        if DatabaseManager.Instance.userIsLoggedIn && DatabaseManager.Instance.userObject.first != nil  {
            credentialView.isHidden = true
            tabBarController?.tabBar.isHidden = false
            activateEmojiView(notification: nil)
        } else {
            tabBarController?.tabBar.isHidden = true
        }
    }
    
    func resetUserEmoji() {
        let today = Date()
        if let savedDate = DatabaseManager.Instance.savedDate {
            
            let hoursPassed = Date().numberTimePassed(passed: savedDate, .hour)
            
            print("Hours Passed \(hoursPassed)")
            print("Saved Date \(savedDate) new date \(today.timeIntervalSince1970)")
            if hoursPassed >= 2 {
                DatabaseManager.Instance.updateUserDefaults(value: today.timeIntervalSince1970, key: .savedDate)
                DatabaseManager.Instance.updateUserDefaults(value: false, key: .userHasAnswered)
            }
            
            checkIfUserLoggedIn()
            
        } else {
            DatabaseManager.Instance.updateUserDefaults(value: today.timeIntervalSince1970, key: .savedDate)
            checkIfUserLoggedIn()
        }
    }
    
    @objc
    func activateEmojiView(notification: Notification?) {
        if !DatabaseManager.Instance.userHasAnswered {
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
    
    fileprivate func getPosts(for selectedPaki: Paki) {
        
        loadingView.stopLoading()
        loadingView.setupCircleViews(paki: selectedPaki)
        loadingView.startLoading()
        
        filteredPosts.removeAll()
        filteredPosts = selectedPaki == .all ? allPosts : allPosts.filter({$0.pakiCase == selectedPaki})
        
        if filteredPosts.isEmpty {
            FirebaseManager.Instance.getPostFor(paki: selectedPaki) { (userPost) in
                if let post = userPost {
                    self.filteredPosts.append(post)
                    self.feedCollection.reloadData()
                }
                self.loadingView.stopLoading()
            }
        } else {
            loadingView.stopLoading()
            feedCollection.reloadData()
        }
    }
    
    fileprivate func getAllPosts(done: EmptyClosure?) {
        
        loadingView.stopLoading()
        loadingView.setupCircleViews(paki: .all)
        loadingView.startLoading()
        allPosts.removeAll()
        
        for paki in allPakis {
            FirebaseManager.Instance.getPostFor(paki: paki) { (userPost) in
                if let post = userPost {
                    self.allPosts.append(post)
                    self.allPosts.sort(by: {$0.datePosted > $1.datePosted})
                    self.filteredPosts = self.allPosts
                    self.feedCollection.reloadData()
                }
                done?()
                self.loadingView.stopLoading()
            }
        }
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        getAllPosts {
            self.refreshControl.endRefreshing()
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
    func didFinishAnswer(post: UserPost) {
        
        loadingView.stopLoading()
        credentialView.isHidden = true
        tabBarController?.tabBar.isHidden = false
        allPosts.append(post)
        allPosts.sort(by: {$0.datePosted > $1.datePosted})
        
        let pakiDict: [String] = self.allPosts.map({$0.paki})
        DatabaseManager.Instance.updateUserDefaults(value: pakiDict, key: .allPakis)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllPakis"), object: pakiDict)
        
        filteredPosts = allPosts
        feedCollection.reloadData()
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
        feedCell.setupFeedCellWith(post: feedPost)
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = filteredPosts[indexPath.item].content
        let title = filteredPosts[indexPath.item].title
        let collectionWidth = collectionView.frame.width
        
        let titleHeight = title.returnStringHeight(fontSize: 15, width: collectionWidth).height
        let contentHeight = text.returnStringHeight(fontSize: 15, width: collectionWidth).height
        let tempFeedHeight = titleHeight + contentHeight + 150
        let feedHeight: CGFloat = tempFeedHeight > 500 ? 500 : tempFeedHeight
        
        print("Feed Height \(feedHeight)")
        
        return CGSize(width: view.frame.size.width - 16, height: feedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FeedHeaderView", for: indexPath) as! FeedHeaderView
        header.delegate = self
        header.totalLabel.text = "\(filteredPosts.count) feel \(currentPaki) today"
        print("Reloaded")
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
    
}
// MARK: - FeedHeaderProtocol
extension FeedVC: FeedHeaderProtocol, FeedPostProtocol {
    
    func didSortPosts(byDate: Bool) {
        if byDate {
            filteredPosts.sort(by: {$0.datePosted > $1.datePosted})
        } else {
            filteredPosts.sort(by: {$0.starCount > $1.starCount})
        }
        feedCollection.reloadData()
    }
    
    func starWasUpdated(post: UserPost) {
        let post = self.allPosts.filter({$0 == post}).first
        guard let uid = DatabaseManager.Instance.mainUser.uid else { return }
        post?.starList.append(uid)
    }
    
    func proceedToComments(post: UserPost) {
        let commentsVC = storyboard?.instantiateViewController(identifier: "CommentsVC") as! CommentsVC
        commentsVC.currentPost = post
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func didChoosePaki(_ paki: Paki) {
        currentPaki = paki
        getPosts(for: paki)
    }
}

