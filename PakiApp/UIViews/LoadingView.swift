//
//  LoadingView.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/28/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import CircleLoading

class LoadingView: UIView, Reusable {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var circleLoading: CircleLoading!
    @IBOutlet weak var bigCircleLoading: CircleLoading!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXibs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXibs()
    }
    
    fileprivate func setupXibs() {
        Bundle.main.loadNibNamed(LoadingView.className, owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
        circleLoading.colors(color1: UIColor.getColorFor(paki: .good), color2: UIColor.getColorFor(paki: .meh), color3: UIColor.getColorFor(paki: .terrible))
        bigCircleLoading.colors(color1: UIColor.getColorFor(paki: .awesome), color2: UIColor.getColorFor(paki: .meh), color3: UIColor.getColorFor(paki: .bad))
    }
    
    func setupCircleViews(paki: Paki) {
        self.isHidden = false
        let color = UIColor.getColorFor(paki: paki)
        circleLoading.colors(color1: .label, color2: .systemGray, color3: .tertiarySystemGroupedBackground)
        bigCircleLoading.colors(color1: color, color2: color, color3: color)
    }
    
    func startLoading() {
        circleLoading.start()
        bigCircleLoading.start()
    }
    
    func stopLoading() {
        circleLoading.stop()
        bigCircleLoading.stop()
        self.isHidden = true
    }
    
}
