//
//  FilterView.swift
//  PakiApp
//
//  Created by Kem Belderol on 6/13/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol FilterViewProtocol: class {
    func didApplyFilters(data: [String: Any])
}

class FilterView: UIView, Reusable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var continueBtn: UIButton!
    
    weak var delegate: FilterViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXibs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXibs()
    }
    
    fileprivate func setupXibs() {
        Bundle.main.loadNibNamed(FilterView.className, owner: self, options: nil)
        contentView.frame = self.bounds
        containerView.backgroundColor = UIColor.defaultBGColor
        self.addSubview(contentView)
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        delegate?.didApplyFilters(data: [FirebaseKeys.postPrivate.rawValue: privateSwitch.isOn,
                                         FirebaseKeys.nsfw.rawValue: nsfwSwitch.isOn])
        self.isHidden = true
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.isHidden = true
    }
    
    
}
