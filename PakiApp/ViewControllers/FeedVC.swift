//
//  FeedVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FacebookCore

class FeedVC: GeneralViewController {
    
    // IBOutlets
    @IBOutlet weak var feedCollection: UICollectionView!
    @IBOutlet weak var credentialView: UIVisualEffectView!
    @IBOutlet weak var loadingView: LoadingView!
    weak var emojiView: AnswerView?
    var answerButton: UIButton!
    private let refreshControl = UIRefreshControl()
    // Constraints
    @IBOutlet weak var credentialHeight: NSLayoutConstraint!
    // Variables
    var feedItems: [AnyObject] = []
    var filteredPosts: [UserPost] = []
    var allPosts: [UserPost] = []
    
    var activateAnswerBtn: Bool = false {
        didSet {
            answerButton.isUserInteractionEnabled = activateAnswerBtn
            let tintColor = activateAnswerBtn ? UIColor.defaultPurple : .lightGray
            answerButton.tintColor = tintColor
            let image = activateAnswerBtn ? "add" : "cancel"
            answerButton.setImage(UIImage(named: image), for: .normal)
        }
    }
    
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
        FirebaseManager.Instance.getSettingsData()
        
        setupMobileAds()
        setupViewUI()

        if !DatabaseManager.Instance.notFirstTime {
           addTutorialPages()
        }
        
        getAllPosts(done: {
            let pakiDict: [String] = self.allPosts.map({$0.paki})
            DatabaseManager.Instance.updateUserDefaults(value: pakiDict, key: .allPakis)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllPakis"), object: pakiDict)
        })
        
        setupCountDown()
        checkIfUserLoggedIn(notification: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkIfUserLoggedIn(notification:)), name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout(notification:)), name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
    }

    // MARK: - Functions
    @objc
    func userDidLogout(notification: Notification) {
        hideTabbar = true
        checkIfUserLoggedIn(notification: nil)
    }
    
    fileprivate func setupViewUI() {
        
        credentialHeight.constant = self.view.frame.height / 4
        
        loadingView.blurView.effect = nil
        loadingView.stopLoading()
        loadingView.setupCircleViews(paki: .all)
        loadingView.startLoading()
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        
        feedCollection.alwaysBounceVertical = true
        feedCollection.refreshControl = refreshControl
        feedCollection.register(UnifiedNativeAdCVC.nib, forCellWithReuseIdentifier: UnifiedNativeAdCVC.className)
        feedCollection.register(FeedCollectionViewCell.nib, forCellWithReuseIdentifier: FeedCollectionViewCell.className)
        feedCollection.register(FeedHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeedHeaderView.className)
        feedCollection.backgroundColor = .clear
        feedCollection.delegate = self
        feedCollection.dataSource = self
        
        credentialView.layer.cornerRadius = 15

        let dateLabel = UILabel()
        dateLabel.frame = CGRect(x: 0.0, y: -8.0, width: 100, height: 40)
        dateLabel.text = Date().convertToString(with: "LLLL d")
        dateLabel.textColor = .white
        
        let leftItem = UIBarButtonItem.init(customView: dateLabel)
        navigationItem.leftBarButtonItem = leftItem
        
        answerButton = UIButton()
        answerButton?.frame = CGRect(x: 0.0, y: -8.0, width: 40, height: 40)
        answerButton?.addTarget(self, action: #selector(setupEmojiView), for: .touchUpInside)
        answerButton?.setImage(UIImage(named: "add"), for: .normal)
        answerButton?.tintColor = UIColor.defaultPurple

        let rightItem = UIBarButtonItem.init(customView: answerButton!)
        navigationItem.rightBarButtonItem = rightItem
    }

    fileprivate func addTutorialPages() {
        let tutorialView = UINib(nibName: TutorialView.className, bundle: nil).instantiate(withOwner: self, options: nil).first as! TutorialView
        tutorialView.frame = view.bounds
        tutorialView.setupXib()
        view.addSubview(tutorialView)
    }
    
    @objc
    func checkIfUserLoggedIn(notification: Notification?) {
        if let token = AccessToken.current {
            DatabaseManager.Instance.updateUserDefaults(value: !token.isExpired, key: .userIsLoggedIn)
        }
        
        if DatabaseManager.Instance.userIsLoggedIn && DatabaseManager.Instance.mainUser.uid != nil  {
            if !allPosts.map({$0.userUID}).contains(DatabaseManager.Instance.mainUser.uid!) {
                resetUserEmoji()
            }
            credentialView.isHidden = true
            activateAnswerBtn = true
            hideTabbar = false
        } else {
            activateAnswerBtn = false
            credentialView.isHidden = false
            hideTabbar = true
        }
    }
    
    func resetUserEmoji() {
        let today = DatabaseManager.Instance.savedDate ?? Date()
        let tomorrow = Date().tomorrow
        
        let todayString = today.convertToMediumString()
        let tomorrowString = tomorrow.convertToMediumString()

        if todayString != tomorrowString {
            DatabaseManager.Instance.updateUserDefaults(value: false, key: .userHasAnswered)
            setupEmojiView()
        }
    }

    @objc
    fileprivate func setupEmojiView() {
        hideTabbar = true
        if emojiView == nil {
            emojiView = Bundle.main.loadNibNamed(AnswerView.className, owner: self, options: nil)?.first as? AnswerView
            emojiView?.alpha = 0
            emojiView?.frame = self.view.bounds
            emojiView?.delegate = self
            emojiView?.setupEmojiView()
            emojiView?.getUpdatedPakiCount()
            view.addSubview(emojiView!)
            UIView.animate(withDuration: 0.3) {
                self.emojiView?.alpha = 1
            }
        }
    }
    
    fileprivate func getPosts(for selectedPaki: Paki) {
        
        loadingView.stopLoading()
        loadingView.setupCircleViews(paki: selectedPaki)
        loadingView.startLoading()
        
        filteredPosts.removeAll()
        filteredPosts = selectedPaki == .all ? allPosts : allPosts.filter({$0.pakiCase == selectedPaki})
        
        fillFeedItems()
        loadingView.stopLoading()
    }
    
    fileprivate func getAllPosts(done: EmptyClosure?) {
        
        allPosts.removeAll()
        FirebaseManager.Instance.getAllPostFor { (userPost) in
            if let post = userPost {
                self.allPosts.append(contentsOf: post)
                self.allPosts.sort(by: {$0.datePosted > $1.datePosted})
                self.filteredPosts = self.allPosts
                self.feedItems.removeAll()
                self.feedItems.append(contentsOf: self.filteredPosts)
                self.feedCollection.isUserInteractionEnabled = true
                self.feedCollection.reloadData()
                self.loadingView.stopLoading()
                done?()
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
        
        let adInterval = 4
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
        let credentialVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CredentialVC") as! CredentialVC
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
        addNativeAds()
        feedCollection.reloadData()
    }
}

// MARK: - AnswerView
extension FeedVC: AnswerViewProtocol {
    
    func didCancelAnswer() {
        hideTabbar = false
        emojiView = nil
    }
    
    func presentImageController(_ controller: UIImagePickerController) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func didFinishAnswer(post: UserPost) {
        
        loadingView.stopLoading()
        credentialView.isHidden = true
        hideTabbar = false
        if let userUID = DatabaseManager.Instance.mainUser.uid {
            allPosts.removeAll(where: {$0.userUID == userUID})
        }
        if !post.postPrivate {
           allPosts.append(post)
        }
        
        allPosts.sort(by: {$0.datePosted > $1.datePosted})
        
        let pakiDict: [String] = self.allPosts.map({$0.paki})
        
        DatabaseManager.Instance.updateUserDefaults(value: pakiDict, key: .allPakis)
        DatabaseManager.Instance.updateUserDefaults(value: Date().tomorrow, key: .savedDate)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllPakis"), object: pakiDict)

        let blockedList = DatabaseManager.Instance.mainUser.blockedList
        
        filteredPosts = allPosts.filter({!blockedList.contains($0.userUID)})
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
            let mediaHeight: CGFloat = filteredPost.hasMedia ? 140 : 0
            let text = filteredPost.content
            let collectionWidth = collectionView.frame.width - 32
            
            let contentHeight = text.returnStringHeight(fontSize: 15, width: collectionWidth).height + 180
            let tempFeedHeight = contentHeight > 200 ? contentHeight : 200
            let feedHeight: CGFloat = tempFeedHeight > 500 ? 500 + mediaHeight : tempFeedHeight + mediaHeight
            print("PostHeight \(feedHeight)")
            return CGSize(width: view.frame.size.width - 16, height: feedHeight)
        } else {
            return CGSize(width: view.frame.size.width, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let filteredPost = feedItems[indexPath.item] as? UserPost {
            proceedToComments(post: filteredPost)
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
extension FeedVC: FeedHeaderProtocol, FeedPostProtocol, ReportViewProtocol, CommentsVCProtocol {
    
    func showTabbarController() {
        print("Showing tabbar")
        self.hideTabbar = false
    }
    
    func didViewProfile(uid: UserPost) {
        let profileView = Bundle.main.loadNibNamed(ProfileView.className, owner: self, options: nil)?.first as! ProfileView
        profileView.frame = view.bounds
        profileView.setupProfile(user: uid)
        view.addSubview(profileView)
    }
    
    func didSharePost(post: UserPost) {
        let activityVC = UIActivityViewController(activityItems: ["\(post.username) feeling \(post.paki) \nPosted on \(post.dateString) \n\nTitle: \(post.title) \n\nContent: \(post.content)"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func didSubmitReportUser(post: UserPost) {
        guard let index = feedItems.firstIndex(where: {($0 as? UserPost) == post}) else { return }
        feedItems.remove(at: index)
        filteredPosts.remove(at: index)
        feedCollection.reloadData()
        FirebaseManager.Instance.reportPost(post: post)
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
        let post = self.filteredPosts.filter({$0 == post}).first
        guard let uid = DatabaseManager.Instance.mainUser.uid else { return }
        post?.starList.append(uid)
        fillFeedItems()
    }
    
    func proceedToComments(post: UserPost) {
        let commentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        commentsVC.commentDelegate = self
        commentsVC.delegate = self
        commentsVC.currentPost = post
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func didChoosePaki(_ paki: Paki) {
        currentPaki = paki
        getPosts(for: paki)
    }
}

