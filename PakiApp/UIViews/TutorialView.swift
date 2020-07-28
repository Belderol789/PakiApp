//
//  TutorialView.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol TutorialViewProtocol: class {
    func didCloseTutorialView()
}

class TutorialView: UIView, Reusable {

    @IBOutlet weak var tutorialCollectionView: UICollectionView!
    @IBOutlet weak var tutorialPageControl: UIPageControl!
    @IBOutlet weak var tutorialNext: ButtonX!
    @IBOutlet weak var tutorialSkip: ButtonX!
    
    var tutorial: [Tutorial] = []
    var currentPage: Int = 0
    
    weak var delegate: TutorialViewProtocol?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupXib() {
        tutorial = [Tutorial(title: "Track your days", text: "Keep track of your growth with your personal mood calendar", image: UIImage(named: "tutorial-0")!),
                    Tutorial(title: "Share your feelings", text: "Anonymously share your feelings and experiences for the day", image: UIImage(named: "tutorial-1")!),
                    Tutorial(title: "Join the community", text: "Join a group of journalers just like you!", image: UIImage(named: "tutorial-2")!),
                    Tutorial(title: "Share", text: "Give or receive encouragement from others", image: UIImage(named: "tutorial-3")!),
                    Tutorial(title: "Welcome to Paki", text: "We hope you enjoy your stay :)", image: UIImage(named: "Mascot")!)]
        
        tutorialPageControl.numberOfPages = tutorial.count
        tutorialCollectionView.backgroundColor = .clear
        tutorialCollectionView.layer.cornerRadius = 15
        tutorialCollectionView.layer.masksToBounds = true
        tutorialCollectionView.register(TutorialCollectionViewCell.nib, forCellWithReuseIdentifier: TutorialCollectionViewCell.className)
        tutorialCollectionView.delegate = self
        tutorialCollectionView.dataSource = self
    }
    
    @IBAction func didTapNext(_ sender: ButtonX) {
        tutorialCollectionView.scrollToNextItem(width: tutorialCollectionView.frame.width)
        currentPage += 1
        if currentPage == tutorial.count {
            delegate?.didCloseTutorialView()
            DatabaseManager.Instance.updateUserDefaults(value: true, key: .notFirstTime)
            self.removeFromSuperview()
        }
    }
    
    
    @IBAction func didTapSkip(_ sender: ButtonX) {
        delegate?.didCloseTutorialView()
        DatabaseManager.Instance.updateUserDefaults(value: true, key: .notFirstTime)
        self.removeFromSuperview()
    }
    
}

extension TutorialView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tutorial.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tutorialCell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCollectionViewCell.className, for: indexPath) as! TutorialCollectionViewCell
        tutorialCell.setupTutorialCell(tutorial: tutorial[indexPath.item])
        return tutorialCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tutorialPageControl.currentPage = indexPath.item
        currentPage = indexPath.item
    }
    
}
