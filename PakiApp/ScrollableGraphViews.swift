//
//  ScrollableGraphViews.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import ScrollableGraphView

struct MontPoints {
    let month: String
    
}

class ScrollableGraphViews: UIView, Reusable {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var graphView: ScrollableGraphView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXibs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXibs()
    }
    
    func setupXibs() {
        Bundle.main.loadNibNamed(ScrollableGraphViews.className, owner: self, options: nil)
        contentView.backgroundColor = .blue
        contentView.frame = self.bounds
        self.addSubview(contentView)
        
        graphView.dataSource = self
    }
}

extension ScrollableGraphViews: ScrollableGraphViewDataSource {
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return 100
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return "\(pointIndex)"
    }
    
    func numberOfPoints() -> Int {
        return 12
    }
    
}
