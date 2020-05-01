//
//  ProfileVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import BubbleTransition
import Charts
import SDWebImage

class ProfileVC: GeneralViewController {
    // IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gridViewContainer: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var statsTableView: UITableView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: ImageViewX!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
    // Constraints
    // Variables
    var userPosts: [UserPost] = []
    var pakis: [Paki] = [.awesome, .good, .meh, .bad, .terrible]
    
    var pakiViews: [String: PakiView] = [:]
    var selectedPaki: PakiView?
    var startingPoint: CGPoint = CGPoint.zero
    var gridTimer: Timer?
    
    var chartData: [String: Int] = [:]
    var numberOfPakiEntries = [PieChartDataEntry]()
    
    let transition = BubbleTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isProfile = true
        setupCountDown()
        setupUserData()
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        let width = view.frame.width
        if sender.selectedSegmentIndex == 0 {
            scrollView.scrollToPreviousItem(width: width)
        } else {
            scrollView.scrollToNextItem(width: width)
        }
    }
    
    func setupUserData() {
        let mainUser = DatabaseManager.Instance.mainUser
        usernameLabel.text = mainUser.username
        if let photoString = mainUser.profilePhotoURL {
            let photoURL = URL(string: photoString)
            userPhotoImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "mascot"), options: .continueInBackground, completed: nil)
        }
        
        let mainUserPosts = mainUser.userPosts.sorted(by: {$0.postTag < $1.postTag})
        if mainUserPosts.count < 2 {
            FirebaseManager.Instance.getUserPosts { (userPosts) in
                DatabaseManager.Instance.updateRealm(key: FirebaseKeys.postTag.rawValue, value: (userPosts.count - 1))
                DatabaseManager.Instance.saveUserPosts(userPosts)
                self.setupCalendarView(posts: userPosts)
            }
        } else {
            setupCalendarView(posts: mainUserPosts)
        }
        
    }
    
    func setupCalendarView(posts: [UserPost]) {
        userPosts = posts.sorted(by: {$0.postTag < $1.postTag})
        totalLabel.text = "\(userPosts.count)/365"
        addChartViews()
        addGridViews()
    }
    
    func addChartViews() {
        let awesomeEntry = setupDateEntry(paki: .awesome)
        let goodEntry = setupDateEntry(paki: .good)
        let mehEntry = setupDateEntry(paki: .meh)
        let badEntry = setupDateEntry(paki: .bad)
        let terribleEntry = setupDateEntry(paki: .terrible)
        let noneEntry = setupDateEntry(paki: .none)
        
        numberOfPakiEntries = [awesomeEntry, goodEntry, mehEntry, badEntry, terribleEntry, noneEntry]
        
        let chartDataSet = PieChartDataSet(entries: numberOfPakiEntries)
        
        let pakiColors = [UIColor.getColorFor(paki: .awesome),
                          UIColor.getColorFor(paki: .good),
                          UIColor.getColorFor(paki: .meh),
                          UIColor.getColorFor(paki: .bad),
                          UIColor.getColorFor(paki: .terrible),
                          UIColor.tertiarySystemGroupedBackground]
        chartDataSet.colors = pakiColors
        chartDataSet.valueTextColor = .label
        chartDataSet.label = "Pakis"
        let chartData = PieChartData(dataSet: chartDataSet)

        pieChart.data = chartData
        pieChart.holeColor = .systemBackground
        pieChart.legend.textColor = .label
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .percent
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        statsTableView.backgroundColor = .clear
        statsTableView.register(StatsTableViewCell.nib, forCellReuseIdentifier: StatsTableViewCell.className)
        statsTableView.delegate = self
        statsTableView.dataSource = self
    }
    
    fileprivate func setupDateEntry(paki: Paki) -> PieChartDataEntry {
        let dataEntry = PieChartDataEntry(value: 0)
        
        let value = userPosts.filter({$0.paki == paki.rawValue}).count
        dataEntry.value = Double(value)/Double(userPosts.count)

        return dataEntry
    }
    
    func addGridViews() {
        let width = view.frame.width / 10
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        //Kem Fix
        for post in userPosts {
            if x == 10 {
                x = 0
                y += 1
            }
            
            let pakiView = PakiView()
            let paki = Paki(rawValue: post.paki)!
            
            pakiView.viewTag = post.postTag
            pakiView.setupView(with: paki)
            pakiView.frame = CGRect(x: x * width, y: y * width, width: width, height: width)
            gridViewContainer.addSubview(pakiView)
            
            let key = "\(Int(x))\(Int(y))"
            pakiViews[key] = pakiView
            
            x += 1
        }
        
        gridViewContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:))))
        gridViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
    }
    
    @objc
    func handleTap(gesture: UITapGestureRecognizer) {
        let width = view.frame.width / 10
        let location = gesture.location(in: gridViewContainer)
        
        let x = Int(location.x / width)
        let y = Int(location.y / width)
        let key = "\(x)\(y)"
        
        if let pakiView = pakiViews[key], pakiView.backgroundColor != .clear {
            self.selectedPaki = pakiView
            presentCalendarVC()
        }
    }
    
    @objc
    func handlePan(gesture: UIPanGestureRecognizer) {
        let width = view.frame.width / 10
        let location = gesture.location(in: gridViewContainer)
        
        let x = Int(location.x / width)
        let y = Int(location.y / width)
        
        let key = "\(x)\(y)"
        if let pakiView = pakiViews[key], pakiView.backgroundColor != .clear {
            
            self.gridTimer?.invalidate()
            self.gridTimer = nil
            
            if selectedPaki != pakiView {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.selectedPaki?.layer.transform = CATransform3DIdentity
                    self.selectedPaki?.layer.borderColor = UIColor.systemBackground.cgColor
                }, completion: nil)
            }
            
            selectedPaki = pakiView
            gridViewContainer.bringSubviewToFront(pakiView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                pakiView.layer.transform = CATransform3DMakeScale(3, 3, 3)
                pakiView.layer.borderColor = UIColor.label.cgColor
            }, completion: { (_) in
                
            })
            
            if gesture.state == .ended {
                UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    pakiView.layer.transform = CATransform3DIdentity
                    pakiView.layer.borderColor = UIColor.systemBackground.cgColor
                }, completion: { (_) in
                    self.gridTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                        timer.invalidate()
                        self.gridTimer?.invalidate()
                        self.presentCalendarVC()
                    })
                })
            }
            
        }
    }
    
    fileprivate func presentCalendarVC() {
        guard let selectedPaki = selectedPaki else { return }
        let calendarVC = self.storyboard?.instantiateViewController(identifier: CalendarVC.className) as! CalendarVC
        calendarVC.postTag = selectedPaki.viewTag
        calendarVC.userPosts = userPosts
        calendarVC.transitioningDelegate = self
        calendarVC.modalPresentationStyle = .custom
        self.present(calendarVC, animated: true) {
            calendarVC.setupVCUI()
        }
    }
    
    func pakiViewCenterPoint() -> CGPoint? {
        let frameRelativeToVC = gridViewContainer.convert(selectedPaki!.frame.origin, from: self.view)
        print("Frame \(frameRelativeToVC)")
        return frameRelativeToVC
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension ProfileVC: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = self.pakiViewCenterPoint() ?? startingPoint
        transition.bubbleColor = .systemBackground
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = startingPoint
        transition.bubbleColor = .systemBackground
        return transition
    }
}

// MARK: - UITableView
extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pakis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentPaki = pakis[indexPath.row]
        let pakiCount = userPosts.filter({$0.paki == currentPaki.rawValue}).count
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.className) as! StatsTableViewCell
        cell.totalCount = userPosts.count
        cell.setupCell(withPaki: currentPaki, count: pakiCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = tableView.frame.height / 5
        return rowHeight
    }
    
    
}
