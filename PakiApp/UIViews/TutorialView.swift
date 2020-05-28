//
//  TutorialView.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class TutorialView: UIView, Reusable {

    @IBOutlet weak var tutorialCollectionView: UICollectionView!
    @IBOutlet weak var tutorialPageControl: UIPageControl!
    @IBOutlet weak var tutorialNext: ButtonX!
    @IBOutlet weak var tutorialSkip: ButtonX!
    
    var tutorialImages: [UIImage] = []
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setupXib() {
        for i in 0..<3 {
            tutorialImages.append(UIImage(named: "tutorial-\(i)")!)
        }
        tutorialPageControl.numberOfPages = tutorialImages.count
        tutorialCollectionView.backgroundColor = .clear
        tutorialCollectionView.layer.cornerRadius = 20
        tutorialCollectionView.register(ImageCollectionCell.nib, forCellWithReuseIdentifier: ImageCollectionCell.className)
        tutorialCollectionView.delegate = self
        tutorialCollectionView.dataSource = self
    }
    
    @IBAction func didTapNext(_ sender: ButtonX) {
        tutorialCollectionView.scrollToNextItem(width: tutorialCollectionView.frame.width)
        
    }
    
    
    @IBAction func didTapSkip(_ sender: ButtonX) {
        self.removeFromSuperview()
    }
    
    
}

extension TutorialView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tutorialImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.className, for: indexPath) as! ImageCollectionCell
        imageCell.imageView.image = tutorialImages[indexPath.item]
        return imageCell
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
    }
    
}
