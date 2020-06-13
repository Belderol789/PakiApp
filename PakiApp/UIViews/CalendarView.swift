//
//  CalendarView.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/10/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import FSCalendar

protocol CalendarViewProtocol: class {
    func showMemoriesView(post: UserPost)
}

class CalendarView: UIView, Reusable {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var gridViewContainer: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var yearView: ViewX!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarViewWidthConst: NSLayoutConstraint!
    @IBOutlet weak var contentViewWidthConst: NSLayoutConstraint!
    
    var userPosts: [UserPost] = []
    var postPakiDict: [String: Paki] = [:]
    var postDict: [String: UserPost] = [:]
    var postDates: [String] = []
    var pakiViews: [String: PakiView] = [:]
    var selectedPaki: PakiView?
    var gridTimer: Timer?
    
    weak var delegate: CalendarViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXib()
    }
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(CalendarView.className, owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
        segmentedControl.addUnderlineForSelectedSegment()
        calendar.layer.cornerRadius = 15
        
    }
    
    @IBAction func didChangeTimeFrame(_ sender: UISegmentedControl) {
        sender.changeUnderlinePosition()
        let width = self.frame.width
        if sender.selectedSegmentIndex == 0 {
            scrollView.scrollToPreviousItem(width: width)
        } else {
            calendar.reloadData()
            scrollView.scrollToNextItem(width: width)
        }
    }
    
    
    func setupUserPosts() {
        userPosts.forEach({postPakiDict[$0.dateString] = $0.pakiCase})
        postDates = userPosts.map({$0.dateString})
        
        print("PostDates \(postDates)")
        
        calendar.delegate = self
        calendar.dataSource = self
    }

    func addGridViews() {
        let year = Calendar.current.component(.year, from: Date())
        yearLabel.text = "\(year)"
        
        let rowLimit: CGFloat = 15
        let width = self.contentView.frame.width / rowLimit
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for post in userPosts {
            if x == rowLimit {
                x = 0
                y += 1
            }
            
            let pakiView = PakiView()
            
            pakiView.setupView(with: post)
            pakiView.frame = CGRect(x: x * width, y: y * width, width: width, height: width)
            pakiView.layer.borderColor = UIColor.white.cgColor
            pakiView.layer.borderWidth = 0.5
            pakiView.isUserInteractionEnabled = true
            pakiView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
            gridViewContainer.addSubview(pakiView)
            
            let key = "\(Int(x))\(Int(y))"
            pakiViews[key] = pakiView
            postDict[key] = post
            
            x += 1
        }
        
        gridViewContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:))))
    }
    
    @objc
    func handleTap(gesture: UITapGestureRecognizer) {
        if let post = (gesture.view as? PakiView)?.currentPost {
           delegate?.showMemoriesView(post: post)
        }
    }
    
    @objc
    func handlePan(gesture: UIPanGestureRecognizer) {
        let width = self.frame.width / 20
        let location = gesture.location(in: gridViewContainer)
        
        let x = Int(location.x / width)
        let y = Int(location.y / width)
        
        let key = "\(x)\(y)"
        if let pakiView = pakiViews[key], pakiView.backgroundColor != .clear {
            
            print("PakiView Exists")
            
            self.gridTimer?.invalidate()
            self.gridTimer = nil
            
            if selectedPaki != pakiView {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.selectedPaki?.layer.transform = CATransform3DIdentity
                    self.selectedPaki?.layer.borderColor = UIColor.clear.cgColor
                }, completion: nil)
            }
            
            selectedPaki = pakiView
            gridViewContainer.bringSubviewToFront(pakiView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                pakiView.layer.transform = CATransform3DMakeScale(3, 3, 3)
                pakiView.layer.borderColor = UIColor.white.cgColor
            })
            
            if gesture.state == .ended {
                print("PakiView gesture ended")
                UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    pakiView.layer.transform = CATransform3DIdentity
                    pakiView.layer.borderColor = UIColor.clear.cgColor
                }, completion: { (_) in
                    self.gridTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                        timer.invalidate()
                        self.gridTimer?.invalidate()
                        guard let post = self.postDict[key] else { return }
                        self.delegate?.showMemoriesView(post: post)
                    })
                })
            }
        }
    }
}

extension CalendarView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = date.convertToMediumString()
        if postDates.contains(dateString) {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let dateString = date.convertToMediumString()
        if let paki = postPakiDict[dateString] {
            return UIColor.getColorFor(paki: paki)
        } else {
            return .clear
        }
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return .white
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return .white
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        return .white
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString = date.convertToMediumString()
        guard let userPost = userPosts.filter({$0.dateString == dateString}).first else { return }
        print("Tapped Post \(userPost)")
    }
    
}
