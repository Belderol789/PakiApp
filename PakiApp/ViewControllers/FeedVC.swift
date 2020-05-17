//
//  FeedVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FeedVC: GeneralViewController {
    
    // IBOutlets
    @IBOutlet weak var feedCollection: UICollectionView!
    @IBOutlet weak var credentialView: UIVisualEffectView!
    @IBOutlet weak var loadingView: LoadingView!
    private let refreshControl = UIRefreshControl()
    // Constraints
    @IBOutlet weak var credentialHeight: NSLayoutConstraint!
    // Variables
    var feedItems: [AnyObject] = []
    var filteredPosts: [UserPost] = []
    var allPosts: [UserPost] = []
    
    // Mobile Ads
    let adUnitID = "ca-app-pub-8278458623868241/8855941562"
    var numAdsToLoad = 5
    var nativeAds = [GADUnifiedNativeAd]()
    var adLoader: GADAdLoader!
    //
    
    let allPakis: [Paki] = [.awesome, .good, .meh, .bad, .terrible]
    var currentPaki: Paki = .all {
        didSet {
            feedCollection.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedCollection.isUserInteractionEnabled = false
        print("start loading ads")
        setupMobileAds()
        loadingView.blurView.effect = nil
        credentialHeight.constant = self.view.frame.height / 4
        setupViewUI()
        resetUserEmoji()
        setupCountDown()
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
        
        loadingView.stopLoading()
        loadingView.setupCircleViews(paki: .all)
        loadingView.startLoading()
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.defaultPurple
        feedCollection.alwaysBounceVertical = true
        feedCollection.refreshControl = refreshControl
        
        feedCollection.register(UnifiedNativeAdCVC.nib, forCellWithReuseIdentifier: UnifiedNativeAdCVC.className)
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
            credentialView.isHidden = false
            tabBarController?.tabBar.isHidden = true
        }
    }
    
    func resetUserEmoji() {
        let today = Date()
        if let savedDate = DatabaseManager.Instance.savedDate {
            
            let hoursPassed = Date().numberTimePassed(passed: savedDate, .hour)
            
            print("Hours Passed \(hoursPassed)")
            if hoursPassed >= 24 {
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
                    self.filteredPosts.append(contentsOf: post)
                }
                self.fillFeedItems()
                self.loadingView.stopLoading()
            }
        } else {
            fillFeedItems()
            loadingView.stopLoading()
        }
    }
    
    fileprivate func getAllPosts(done: EmptyClosure?) {
        
        allPosts.removeAll()
        var pakiCount = 0
        
        for paki in allPakis {
            FirebaseManager.Instance.getPostFor(paki: paki) { (userPost) in
                pakiCount += 1
                if let post = userPost {
                    self.allPosts.append(contentsOf: post)
                    self.allPosts.sort(by: {$0.datePosted > $1.datePosted})
                    self.filteredPosts = self.allPosts
                    print("PakiCount \(pakiCount) AllPaki \(self.allPakis.count)")
                    if pakiCount == self.allPakis.count {
                        print("Load all feeds")
                        self.fillFeedItems()
                        done?()
                    }
                }
                self.feedCollection.isUserInteractionEnabled = true
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
    
    // MARK: - Mobile Ads
    func fillFeedItems() {
        feedItems.removeAll()
        feedItems.append(contentsOf: filteredPosts)
        addNativeAds()
        feedCollection.reloadData()
    }
    
    func setupMobileAds() {

        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        
        // Prepare the ad loader and start loading ads.
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: self,
                               adTypes: [.unifiedNative],
                               options: [options])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    /// Add native ads to the tableViewItems list.
    func addNativeAds() {
        if nativeAds.count <= 0 {
            return
        }
        
        let adInterval = 5
        var index = 4
        
        for nativeAd in nativeAds {
            if index < filteredPosts.count {
                feedItems.insert(nativeAd, at: index)
                index += adInterval
            } else {
                break
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func didSelectCredential(_ sender: ButtonX) {
        let credentialVC = storyboard?.instantiateViewController(identifier: CredentialVC.className) as! CredentialVC
        credentialVC.isLogin = (sender.tag == 1)
        navigationController?.pushViewController(credentialVC, animated: true)
    }
    
}

// MARK: - GADUnifiedNativeAdLoaderDelegate
extension FeedVC: GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAds.append(nativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed to load ads")
        
        getAllPosts(done: {
            let pakiDict: [String] = self.allPosts.map({$0.paki})
            DatabaseManager.Instance.updateUserDefaults(value: pakiDict, key: .allPakis)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllPakis"), object: pakiDict)
        })
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        getAllPosts(done: {
            let pakiDict: [String] = self.allPosts.map({$0.paki})
            DatabaseManager.Instance.updateUserDefaults(value: pakiDict, key: .allPakis)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllPakis"), object: pakiDict)
        })
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
        fillFeedItems()
    }
}

// MARK: - UITableView
extension FeedVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedItem = feedItems[indexPath.item]
        if let feedPost = feedItem as? UserPost {
            let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCollectionViewCell.className, for: indexPath) as! FeedCollectionViewCell
            feedCell.delegate = self
            feedCell.setupFeedCellWith(post: feedPost)
            return feedCell
        } else {
            let nativeAd = feedItem as! GADUnifiedNativeAd
            nativeAd.rootViewController = self
            
            let nativeAdCell = collectionView.dequeueReusableCell(withReuseIdentifier: UnifiedNativeAdCVC.className, for: indexPath) as! UnifiedNativeAdCVC
            nativeAdCell.setupAdView(with: nativeAd)
            return nativeAdCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let feedItem = feedItems[indexPath.item]
        
        if let filteredPost = feedItem as? UserPost {
            let text = filteredPost.content
            let title = filteredPost.title
            let collectionWidth = collectionView.frame.width
            
            let titleHeight = title.returnStringHeight(fontSize: 15, width: collectionWidth).height
            let contentHeight = text.returnStringHeight(fontSize: 15, width: collectionWidth).height
            let tempFeedHeight = titleHeight + contentHeight + 150
            let feedHeight: CGFloat = tempFeedHeight > 500 ? 500 : tempFeedHeight

            return CGSize(width: view.frame.size.width - 16, height: feedHeight)
        } else {
            return CGSize(width: view.frame.size.width, height: 80)
        }
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
extension FeedVC: FeedHeaderProtocol, FeedPostProtocol, ReportViewProtocol {
    
    func didSubmitReportUser(post: UserPost) {
        guard let index = feedItems.firstIndex(where: {($0 as? UserPost) == post}) else { return }
        feedItems.remove(at: index)
        feedCollection.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func didReportUser(post: UserPost) {
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
    
    func didSortPosts(byDate: Bool) {
        if byDate {
            filteredPosts.sort(by: {$0.datePosted > $1.datePosted})
        } else {
            filteredPosts.sort(by: {$0.starCount > $1.starCount})
        }
        fillFeedItems()
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

