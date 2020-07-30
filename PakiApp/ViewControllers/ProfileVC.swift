//
//  ProfileVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileVC: GeneralViewController {
    // IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var graphsView: GraphsView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: ImageViewX!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var pakiView: ViewX!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var pakiText: UILabel!
    
    @IBOutlet weak var settingsButton: ButtonX!
    
    @IBOutlet weak var contentViewWidthConst: NSLayoutConstraint!
    @IBOutlet weak var calendarWidthConst: NSLayoutConstraint!

    // Variables
    var userPosts: [UserPost] = []
    var currentUser: User!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        contentViewWidthConst.constant = view.frame.width * 2
        calendarWidthConst.constant = view.frame.width

        isProfile = true
        coverPhoto.backgroundColor = UIColor.defaultPurple
        usernameLabel.adjustsFontSizeToFitWidth = true
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        setupCountDown()
        
        currentUser = DatabaseManager.Instance.mainUser
        
        self.setupUserData()

        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile(notification:)), name: NSNotification.Name(rawValue: "UpdateProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userHasLoggedIn(notification:)), name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
    }
    
    @IBAction func didCreateLocalPost(_ sender: UIButton) {
        guard let emojiView = Bundle.main.loadNibNamed(AnswerView.className, owner: self, options: nil)?.first as? AnswerView else { return }
        emojiView.alpha = 0
        emojiView.frame = self.view.bounds
        emojiView.togglePrivacy = false
        emojiView.privacySwitch.isUserInteractionEnabled = DatabaseManager.Instance.mainUser.uid != nil
        emojiView.delegate = self
        emojiView.setupEmojiView()
        emojiView.getUpdatedPakiCount()
        view.addSubview(emojiView)
        UIView.animate(withDuration: 0.3) {
            emojiView.alpha = 1
        }
    }
    
    
    @IBAction func didGoToSettings(_ sender: ButtonX) {
        let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        settingsVC.delegate = self
        self.present(settingsVC, animated: true, completion: nil)
    }

    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        let width = view.frame.width
        if sender.selectedSegmentIndex == 0 {
            scrollView.scrollToPreviousItem(width: width)
        } else {
            graphsView.addAllYear(posts: userPosts)
            scrollView.scrollToNextItem(width: width)
        }
    }
    
    func checkIfUserLoggedIn() -> Bool {
        return DatabaseManager.Instance.userIsLoggedIn && DatabaseManager.Instance.mainUser.uid != nil
    }
    
    @objc
    func userHasLoggedIn(notification: Notification) {
        currentUser = DatabaseManager.Instance.mainUser
        self.setupUserData()
    }
    
    @objc
    func updateProfile(notification: Notification) {
        if let notificationObject = notification.object as? [String: Any] {
            if let photo = notificationObject[FirebaseKeys.photo.rawValue] as? UIImage {
                userPhotoImageView.image = photo
            }
            if let username = notificationObject[FirebaseKeys.username.rawValue] as? String {
                usernameLabel.text = username
            }
            if let cover = notificationObject[FirebaseKeys.coverPhoto.rawValue] as? UIImage {
                coverPhoto.image = cover
            }
        }
    }
    
    func setupUserData() {
        
        usernameLabel.text = currentUser.username
        
        if let photoString = currentUser.profilePhotoURL {
            let photoURL = URL(string: photoString)
            userPhotoImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "Mascot"), options: .continueInBackground, completed: nil)
        } else {
            userPhotoImageView.image = UIImage(named: "Mascot")
        }
        
        if let coverPhotoString = currentUser.coverPhotoURL {
            let coverURL = URL(string: coverPhotoString)
            coverPhoto.sd_setImage(with: coverURL, completed: nil)
        }
        
        let timePassed = Double(currentUser.dateCreated) ?? 0
        let daysPassed = Date().numberTimePassed(passed: timePassed, .day)
        daysLabel.text = "\(daysPassed)"
        
        userPosts = currentUser.userPosts.sorted(by: {$0.datePosted > $1.datePosted})
        
        guard let userID = currentUser.uid else { return }

        FirebaseManager.Instance.getUserPosts(userID: userID) { (userPosts) in
            DatabaseManager.Instance.saveUserPosts(userPosts)
            self.userPosts = userPosts.sorted(by: {$0.datePosted > $1.datePosted})
            self.setupUserStats()
            DispatchQueue.main.async {
                self.setupCalendarView()
            }
        }
        
        if !checkIfUserLoggedIn() {
            settingsButton.isUserInteractionEnabled = false
            settingsButton.tintColor = .lightGray
        }
        
    }
    
    func setupUserStats() {
        postsLabel.text = "\(userPosts.count)"
        
        if let currentPaki = currentUser.currentPaki {
            pakiView.backgroundColor = UIColor.getColorFor(paki: currentUser.pakiCase)
            pakiText.text = currentPaki.capitalized
        } else if let paki = userPosts.last {
            pakiView.backgroundColor = UIColor.getColorFor(paki: paki.pakiCase)
            pakiText.text = paki.paki.capitalized
        }
        
        
        FirebaseManager.Instance.getUserStars { (starList) in
            self.starsLabel.text = "\(starList.count)"
        }
    }
    
    func setupCalendarView() {
        calendarView.calendarViewWidthConst.constant = view.frame.width
        calendarView.contentViewWidthConst.constant = view.frame.width * 2
        calendarView.scrollView.contentSize.width = view.frame.width * 2
        calendarView.userPosts = userPosts
        calendarView.delegate = self
        calendarView.setupUserPosts()
        calendarView.addGridViews()
    }
}

extension ProfileVC: CalendarViewProtocol, SettingsVCProtocol {
    
    func showMemoriesView(postKey: String) {
        let calendarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        calendarVC.userPosts = userPosts
        calendarVC.postKey = postKey
        self.present(calendarVC, animated: true)
    }
    
    func userDidLogoutDelete() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
        self.tabBarController?.selectedIndex = 1
    }
}

extension ProfileVC: AnswerViewProtocol {
    
    func didCancelAnswer() {
        
    }
    
    func didFinishAnswer(post: UserPost) {
        userPosts.append(post)
        setupUserStats()
        setupCalendarView()
    }
    
    func presentImageController(_ controller: UIImagePickerController) {
        
    }
    
}
