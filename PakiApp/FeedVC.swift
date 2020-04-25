//
//  FeedVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SJFluidSegmentedControl

enum Paki: String {
    case all
    case none
    case awesome
    case good
    case meh
    case bad
    case terrible
}

class FeedVC: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var feedCollection: UICollectionView!

    // Variables
    let testContent: [String] = ["Hello World", "This is a short content description", "This is a far longer content description. Users can write up to maximum of 500 characters, but premium users will have unlimited characters and can write as much as they want.", "Hello World", "This is a short content description", "This is a far longer content description. Users can write up to maximum of 500 characters, but premium users will have unlimited characters and can write as much as they want.", "Hello World", "This is a short content description", "This is a far longer content description. Users can write up to maximum of 500 characters, but premium users will have unlimited characters and can write as much as they want.", "Hello World", "This is a short content description", "This is a far longer content description. Users can write up to maximum of 500 characters, but premium users will have unlimited characters and can write as much as they want."]
    var currentPaki: Paki = .awesome {
        didSet {
            feedCollection.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Functions
    fileprivate func setupViewUI() {
        view.backgroundColor = .systemBackground
        feedCollection.register(FeedCollectionViewCell.nib, forCellWithReuseIdentifier: FeedCollectionViewCell.className)
        feedCollection.register(FeedHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeedHeaderView.className)
        feedCollection.backgroundColor = .clear
        feedCollection.delegate = self
        feedCollection.dataSource = self
    }
    
    // MARK: - IBActions

}

// MARK: - UITableView
extension FeedVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCollectionViewCell.className, for: indexPath) as! FeedCollectionViewCell
        feedCell.feedContent.text = testContent[indexPath.item]
        feedCell.setupCellWith(color: UIColor.getColorFor(paki: currentPaki))
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = testContent[indexPath.item]
        let feedHeight = text.returnStringHeight(width: view.frame.size.width, fontSize: 15).height + 150
        return CGSize(width: view.frame.size.width, height: feedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FeedHeaderView", for: indexPath) as! FeedHeaderView
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let commentsVC = storyboard?.instantiateViewController(identifier: "CommentsVC") as! CommentsVC
        commentsVC.currentPaki = currentPaki
        commentsVC.testContent = testContent
        commentsVC.currentPost = Post(username: "Hello World",
                                      dateToday: "16 hours ago",
                                      title: "This is a far longer content description. Users can write up to maximum of 500 characters, but premium users will have unlimited characters and can write as much as they want.",
                                      content: "This is a far longer content description. Users can write up to maximum of 500 characters, but premium users will have unlimited characters and can write as much as they want.",
                                      profilePhoto: nil)
        navigationController?.pushViewController(commentsVC, animated: true)
    }
}

extension FeedVC: FeedHeaderProtocol {
    
    func didChoosePaki(_ paki: Paki) {
        currentPaki = paki
    }
    
}

