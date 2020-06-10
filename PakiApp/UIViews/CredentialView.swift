//
//  CredentialView.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

protocol CredentialViewProtocol: class {
    func didSelectProfilePhoto()
    func didSelectSignup(data: [String: Any])
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
    @IBOutlet weak var signupBtn: ButtonX!
    
    weak var delegate: CredentialViewProtocol?
    var birthdayValid: Bool = false
    var isPhone: Bool = false
    var birthday: String?
    var enableSignup: Bool = false {
        didSet {
            signupBtn.isUserInteractionEnabled = enableSignup
            let signupColor: UIColor = enableSignup ? UIColor.defaultPurple : .lightGray
            signupBtn.backgroundColor = signupColor
        }
    }
    
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
        
        usernameField.delegate = self
        phoneField.delegate = self
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
        
        let enableYear = year >= 13
        ageLabel.textColor = enableYear ? .white : .lightGray
        
        if enableYear {
            birthday = dateFormatter.string(from: birthdate)
            enableSignup = usernameField.text != ""
        }
    }

    @IBAction func didTapSignup(_ sender: ButtonX) {
        var userData: [String: Any] = [:]
        userData[FirebaseKeys.username.rawValue] = usernameField.text
        userData[FirebaseKeys.birthday.rawValue] = birthday
        if isPhone {
            if phoneField.text == "" {
                return
            }
            userData[FirebaseKeys.number.rawValue] = phoneField.text
        }
        
        if let profilePhoto = profileImageView.image?.compressTo(1) {
            userData[FirebaseKeys.profilePhotoURL.rawValue] = profilePhoto
            delegate?.didSelectSignup(data: userData)
        } else {
            delegate?.didSelectSignup(data: userData)
        }
    }
}

extension CredentialView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if usernameField.text != "" && birthday != nil {
            enableSignup = true
        }
        return true
    }
}
