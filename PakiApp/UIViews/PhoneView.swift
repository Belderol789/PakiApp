//
//  PhoneView.swift
//  PakiApp
//
//  Created by Kem Belderol on 7/26/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol PhoneViewProtocol: class {
    func submitCode(code: String)
}

class PhoneView: UIView, Reusable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var codeField: UITextField!
    
    weak var delegate: PhoneViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXib()
    }
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(PhoneView.className, owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
    }
    
    @IBAction func didTapSubmit(_ sender: UIButton) {
        if codeField.text != "" {
            delegate?.submitCode(code: codeField.text!)
        }
    }
    
}
