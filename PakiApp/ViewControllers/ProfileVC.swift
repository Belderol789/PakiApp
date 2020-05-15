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
    
    // Constraints
    // Variables
    var userPosts: [UserPost] = []
    var currentUser: User!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        isProfile = true
        coverPhoto.backgroundColor = UIColor.defaultPurple
        usernameLabel.adjustsFontSizeToFitWidth = true
        
        setupCountDown()
        setupUserData()

        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile(notification:)), name: NSNotification.Name(rawValue: "UpdateProfile"), object: nil)
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
    
    @objc
    func updateProfile(notification: Notification) {
        if let notificationObject = notification.object as? [String: Any] {
            if let photo = notificationObject[FirebaseKeys.photo.rawValue] as? UIImage {
                userPhotoImageView.image = photo
            }
            if let username = notificationObject[FirebaseKeys.username.rawValue] as? String {
                usernameLabel.text = username
            }
        }
    }
    
    func setupUserData() {
        let mainUser = DatabaseManager.Instance.mainUser
        currentUser = mainUser
        
        usernameLabel.text = mainUser.username
        
        if let photoString = mainUser.profilePhotoURL {
            let photoURL = URL(string: photoString)
            userPhotoImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "mascot"), options: .continueInBackground, completed: nil)
        } else {
            userPhotoImageView.image = UIImage(named: "mascot")
        }
        
        let timePassed = Double(mainUser.dateCreated) ?? 0
        let daysPassed = Date().numberTimePassed(passed: timePassed, .day)
        daysLabel.text = "\(daysPassed)"
        
        userPosts = mainUser.userPosts.sorted(by: {$0.datePosted > $1.datePosted})

        if userPosts.count <= 1 {
            FirebaseManager.Instance.getUserPosts { (userPosts) in
                DatabaseManager.Instance.saveUserPosts(userPosts)
                self.userPosts = userPosts.sorted(by: {$0.datePosted > $1.datePosted})
                self.setupCalendarView()
                self.setupUserStats()
            }
        } else {
            setupCalendarView()
            setupUserStats()
        }
    }
    
    func setupUserStats() {
        postsLabel.text = "\(userPosts.count)"
        starsLabel.text = "\(currentUser.starCount)"
        pakiView.backgroundColor = UIColor.getColorFor(paki: currentUser.pakiCase)
        pakiText.text = currentUser.currentPaki?.capitalized
    }
    
    func setupCalendarView() {
        calendarView.userPosts = userPosts
        calendarView.setupUserPosts()
        calendarView.addGridViews()
    }
}
