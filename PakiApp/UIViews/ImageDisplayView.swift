//
//  ImageDisplayView.swift
//  PakiApp
//
//  Created by Kem Belderol on 6/1/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

class ImageDisplayView: UIView, Reusable {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mediaImages: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXibs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXibs()
    }
    
    fileprivate func setupXibs() {
        Bundle.main.loadNibNamed(ImageDisplayView.className, owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
        
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 20
        collectionView.layer.masksToBounds = true
        collectionView.register(ImageCollectionCell.nib, forCellWithReuseIdentifier: ImageCollectionCell.className)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupCollection(images: [String]) {
        mediaImages = images
        collectionView.reloadData()
    }
    
    @IBAction func removeView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = true
        }
    }
}

extension ImageDisplayView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.className, for: indexPath) as! ImageCollectionCell
        cell.imageView.sd_setImage(with: URL(string: mediaImages[indexPath.item]), completed: nil)
        cell.imageView.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}
