//
//  FeedHeaderView.swift
//  Paki
//
//  Created by Kem Belderol on 4/24/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol FeedHeaderProtocol: class {
    func didChoosePaki(_ paki: Paki)
}

class FeedHeaderView: UICollectionReusableView, Reusable {
    
    @IBOutlet weak var pakiCollectionView: UICollectionView!
    @IBOutlet weak var filterController: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    
    weak var delegate: FeedHeaderProtocol?
    var selectedPaki: Paki = .all
    let pakis: [Paki] = [Paki.all, Paki.awesome, Paki.good, Paki.meh, Paki.bad, Paki.terrible]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        
        pakiCollectionView.backgroundColor = .clear
        pakiCollectionView.register(PakiCollectionViewCell.nib, forCellWithReuseIdentifier: PakiCollectionViewCell.className)
        pakiCollectionView.dataSource = self
        pakiCollectionView.delegate = self
    }
    
    @IBAction func segmentControllerDidChange(_ sender: UISegmentedControl) {
    }
    
}

extension FeedHeaderView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pakis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pakiCell = collectionView.dequeueReusableCell(withReuseIdentifier: PakiCollectionViewCell.className, for: indexPath) as! PakiCollectionViewCell
        pakiCell.selectedPaki = selectedPaki
        pakiCell.setupWith(paki: pakis[indexPath.item])
        return pakiCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = indexPath.item == 0 ? 60 : 90
        let cellWidth = pakis[indexPath.item].rawValue.returnStringHeight(fontSize: 17).width + margin
        return CGSize(width: cellWidth, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPaki = pakis[indexPath.item]
        collectionView.reloadData()
    }
    
}
