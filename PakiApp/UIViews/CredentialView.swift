//
//  CredentialView.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol CredentialViewProtocol: class {
    func enableSignup(birthday: Bool)
    func didSelectProfilePhoto()
}

class CredentialView: UIView, Reusable {
    
    @IBOutlet var credLabels: [UILabel]!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var profileImageView: ImageViewX!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var birthPicker: UIDatePicker!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var phoneCodeView: ViewX!
    @IBOutlet weak var usernameView: ViewX!
    
    weak var delegate: CredentialViewProtocol?
    var birthdayValid: Bool = false
    var birthday: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXibs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXibs()
    }
    
    fileprivate func setupXibs() {
        Bundle.main.loadNibNamed(CredentialView.className, owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.backgroundColor = UIColor.defaultBGColor
        self.addSubview(contentView)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.backgroundColor = UIColor.defaultFGColor
        
        usernameView.backgroundColor = UIColor.defaultFGColor
        phoneCodeView.backgroundColor = UIColor.defaultFGColor
        usernameField.textColor = .white
        usernameField.tintColor = .white
        phoneField.textColor = .white
        phoneField.tintColor = .white
        
        birthPicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func setupPhoneLogin() {
        photoButton.isUserInteractionEnabled = false
        photoButton.isHidden = true
        credLabels.forEach({$0.isHidden = true})
        usernameView.isHidden = true
        profileImageView.image = UIImage(named: "Icon")
        birthPicker.isHidden = true
    }
    
    @IBAction func didSelectPhoto(_ sender: UIButton) {
        delegate?.didSelectProfilePhoto()
    }
    
    @IBAction func didSelectBirthday(_ sender: UIDatePicker) {
        let birthdate = sender.date
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.day, .month, .year], from: birthdate, to: now)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let year = ageComponents.year else { return }
        
        ageLabel.text = "\(year)"
        birthday = dateFormatter.string(from: birthdate)
        birthdayValid = year >= 16
        
        if let username = usernameField.text {
            let enableSignup = birthdayValid && !username.isEmpty
            delegate?.enableSignup(birthday: enableSignup)
        }
    }
    
    
}
