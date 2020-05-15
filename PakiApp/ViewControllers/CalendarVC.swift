//
//  CalendarVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class CalendarVC: GeneralViewController, Reusable {
    
    // IBOutlets
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    // Variables
    var userPosts: [UserPost] = []
    var postTag: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVCUI()
    }
    
    func setupVCUI() {
        view.backgroundColor = UIColor.defaultBGColor
        calendarCollectionView.register(CalendarCollectionViewCell.nib, forCellWithReuseIdentifier: CalendarCollectionViewCell.className)
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.backgroundColor = .clear
        calendarCollectionView.scrollToItem(at: IndexPath(item: postTag, section: 0), at: .right, animated: true)
        
        totalLabel.text = "\(userPosts.count)"
    }
    
    @IBAction func didDismissCalendar(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension CalendarVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.className, for: indexPath) as! CalendarCollectionViewCell
        calendarCell.setupCalendarView(post: userPosts[indexPath.item])
        return calendarCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = userPosts[indexPath.item]
        let titleHeight = post.title.returnStringHeight(fontSize: 20, width: 340).height
        let contentHeight = post.content.returnStringHeight(fontSize: 17, width: 340).height
        let totalHeight = titleHeight + contentHeight + 200
        
        return CGSize(width: collectionView.frame.width, height: totalHeight)
    }

}
