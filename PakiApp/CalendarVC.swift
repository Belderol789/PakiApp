//
//  CalendarVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController, Reusable {
    
    // IBOutlets
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    
    // Variables
    var testPakis: [Paki] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVCUI()
    }
    
    func setupVCUI() {
        calendarCollectionView.register(CalendarCollectionViewCell.nib, forCellWithReuseIdentifier: CalendarCollectionViewCell.className)
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
    }
    
    @IBAction func didDismissCalendar(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension CalendarVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testPakis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.className, for: indexPath) as! CalendarCollectionViewCell
        calendarCell.setupCalendarView(paki: testPakis[indexPath.item])
        return calendarCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}
