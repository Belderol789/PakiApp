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
    
    // Constraints
    // Variables
    var userPosts: [UserPost] = []
    

    var chartData: [String: Int] = [:]
 
    override func viewDidLoad() {
        super.viewDidLoad()

        isProfile = true
        coverPhoto.backgroundColor = UIColor.defaultPurple
        usernameLabel.adjustsFontSizeToFitWidth = true
        
        setupCountDown()
        setupUserData()
        
        let userPosts = TestManager.returnCalendarUserPosts()
        self.userPosts = userPosts
        
        calendarView.addGridViews(userPosts: userPosts)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile(notification:)), name: NSNotification.Name(rawValue: "UpdateProfile"), object: nil)
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        let width = view.frame.width
        if sender.selectedSegmentIndex == 0 {
            scrollView.scrollToPreviousItem(width: width)
        } else {
            graphsView.addAllMonthPakiCircles(posts: userPosts)
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
        //usernameLabel.text = mainUser.username
        if let photoString = mainUser.profilePhotoURL {
            let photoURL = URL(string: photoString)
            userPhotoImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "mascot"), options: .continueInBackground, completed: nil)
        } else {
            userPhotoImageView.image = UIImage(named: "mascot")
        }
        let timePassed = Double(mainUser.dateCreated) ?? 0
        let daysPassed = Date().numberTimePassed(passed: timePassed, .day)
        daysLabel.text = "\(daysPassed)"
        
        FirebaseManager.Instance.getUserPosts { (userPosts) in
            DatabaseManager.Instance.updateRealm(key: FirebaseKeys.postTag.rawValue, value: (userPosts.count - 1))
            DatabaseManager.Instance.saveUserPosts(userPosts)
            self.setupCalendarView(posts: userPosts)
        }
        pakiView.backgroundColor = UIColor.getColorFor(paki: .awesome)
    }
    
    func setupCalendarView(posts: [UserPost]) {
        userPosts = posts.sorted(by: {$0.postTag < $1.postTag})
        
        postsLabel.text = "\(userPosts.count)"
        let totalStars = userPosts.map({ $0.starCount }).reduce(0, +)
        starsLabel.text = "\(totalStars)"
    }
}
