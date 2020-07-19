//
//  EulaView.swift
//  PakiApp
//
//  Created by Kem Belderol on 7/11/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class EulaView: UIView, Reusable {

    @IBOutlet weak var eulaSwitch: UISwitch!
    @IBOutlet weak var agreeBtn: ButtonX!
    @IBOutlet weak var eulaText: UITextView!
    
    var activateEula: Bool = false {
        didSet {
            let agreeColor: UIColor = activateEula ? UIColor.defaultPurple : .lightGray
            agreeBtn.backgroundColor = agreeColor
            agreeBtn.isUserInteractionEnabled = activateEula
        }
    }
    
    func setupEulaView() {
        activateEula = false
        if let eula = DatabaseManager.Instance.eulaText {
            eulaText.text = eula
        } else {
            eulaText.text = "Text Unavailable"
        }
    }

    @IBAction func toggleEula(_ sender: UISwitch) {
        activateEula = sender.isOn
    }
    
    @IBAction func agreeTapped(_ sender: ButtonX) {
        DatabaseManager.Instance.updateUserDefaults(value: true, key: .eulaAgree)
        self.removeFromSuperview()
    }
    
    
}
