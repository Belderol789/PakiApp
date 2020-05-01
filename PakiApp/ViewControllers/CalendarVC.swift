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
    
    // Variables
    var userPosts: [UserPost] = []
    var postTag: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupVCUI() {
        calendarCollectionView.register(CalendarCollectionViewCell.nib, forCellWithReuseIdentifier: CalendarCollectionViewCell.className)
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.scrollToItem(at: IndexPath(item: postTag, section: 0), at: .right, animated: true)
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
        return collectionView.frame.size
    }
    
}
