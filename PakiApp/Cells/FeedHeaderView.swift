//
//  FeedHeaderView.swift
//  Paki
//
//  Created by Kem Belderol on 4/24/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SJFluidSegmentedControl

protocol FeedHeaderProtocol: class {
    func didChoosePaki(_ paki: Paki)
}

class FeedHeaderView: UICollectionReusableView, Reusable {
    
    @IBOutlet weak var feelingSlider: SJFluidSegmentedControl!
    @IBOutlet weak var filterController: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    
    weak var delegate: FeedHeaderProtocol?
    let pakis: [Paki] = [Paki.awesome, Paki.good, Paki.meh, Paki.bad, Paki.terrible]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .systemBackground
        feelingSlider.delegate = self
        feelingSlider.dataSource = self
        feelingSlider.isUserInteractionEnabled = true
        filterController.addUnderlineForSelectedSegment()
    }
    
    @IBAction func segmentControllerDidChange(_ sender: UISegmentedControl) {
        sender.changeUnderlinePosition()
    }
    
}

// MARK: - SJFluidSegmentedControl
extension FeedHeaderView: SJFluidSegmentedControlDelegate, SJFluidSegmentedControlDataSource {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 5
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        
        let segmentTitles = pakis.map({$0.rawValue})
        return segmentTitles[index].capitalized
        
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        let colors = UIColor.getColorFor(paki: pakis[index])
        return [colors]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          didChangeFromSegmentAtIndex fromIndex: Int,
                          toSegmentAtIndex toIndex:Int) {
        //delegate call
        delegate?.didChoosePaki(pakis[toIndex])
    }
}
