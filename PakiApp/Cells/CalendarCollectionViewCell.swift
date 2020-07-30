//
//  CalendarCollectionViewCell.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

class CalendarCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var containerView: ViewX!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateView: ViewX!
    @IBOutlet weak var dividerView: UIView!
    
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var contentCollection: UICollectionView!
    @IBOutlet weak var contentHeightConst: NSLayoutConstraint!
    
    var currentPost: UserPost!
    var isPrivate: Bool = false {
        didSet {
            privacyLabel.text = isPrivate ? "Private" : "Public"
            privacySwitch.isOn = !isPrivate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCalendarView(post: UserPost) {
        
        currentPost = post
        print("Post Privay \(post.postPrivate) \(post.title)")
        isPrivate = post.postPrivate
        privacySwitch.isOn = !isPrivate
        
        let color = UIColor.getColorFor(paki: post.pakiCase)
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        dividerView.backgroundColor = color
        containerView.backgroundColor = UIColor.defaultFGColor
        containerView.layer.borderWidth = 0
        dateView.backgroundColor = color
        
        titleLabel.text = post.title
        contentLabel.text = post.content
        let date = Date(timeIntervalSince1970: post.datePosted)
        dateLabel.text = date.convertToString(with: "LLLL dd, yyyy")
        
        contentCollection.register(ImageCollectionCell.nib, forCellWithReuseIdentifier: ImageCollectionCell.className)
        contentCollection.delegate = self
        contentCollection.dataSource = self
        contentCollection.backgroundColor = .clear
        contentHeightConst.constant = post.hasMedia ? 170 : 0
        
        contentCollection.reloadData()
    }
    
    @IBAction func didSwitchPrivacy(_ sender: UISwitch) {
        isPrivate = !sender.isOn
        FirebaseManager.Instance.updatePost(userPost: currentPost, value: !sender.isOn, key: .postPrivate)
    }
}

extension CalendarCollectionViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPost.mediaURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionCell", for: indexPath as IndexPath) as! ImageCollectionCell
        let mediaURLs = currentPost.mediaURLs
        cell.imageView.sd_setImage(with: URL(string: mediaURLs[indexPath.item]), completed: nil)
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.backgroundColor = UIColor.defaultFGColor
        cell.imageView.layer.cornerRadius = 15
        cell.imageView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentPost.mediaURLs.count == 1 {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        } else {
            let collectionHeight = collectionView.frame.height
            let randomzier = CGFloat.random(in: (collectionHeight - 20)...collectionHeight)
            let itemSize: CGFloat = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
            return CGSize(width: itemSize, height: randomzier)
        }
    }
}
