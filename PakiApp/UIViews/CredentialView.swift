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
    func didViewEndUserLicenseAgreement()
    func didSelectSignup(data: [String: Any])
}

class CredentialView: UIView, Reusable {
    
    @IBOutlet var credLabels: [UILabel]!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var profileImageView: ImageViewX!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var phoneCodeView: ViewX!
    @IBOutlet weak var usernameView: ViewX!
    @IBOutlet weak var signupBtn: ButtonX!
    @IBOutlet weak var agePicker: UIDatePicker!
    
    weak var delegate: CredentialViewProtocol?
    var userData: [String: Any] = [:]
    var isPhone: Bool = false
    var isThirdParty: Bool = false
    var isLogin: Bool = false
    
    var ageValid: Bool = false
    var hasUsername: Bool = false
    var enableSignup: Bool = false {
        didSet {
            signupBtn.isUserInteractionEnabled = (hasUsername && ageValid)
            let signupColor: UIColor = (hasUsername && ageValid) ? UIColor.defaultPurple : .lightGray
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
    }
    
    func setupPhoneLogin() {
        isLogin = true
        signupBtn.setTitle("Login", for: .normal)
        photoButton.isUserInteractionEnabled = false
        photoButton.isHidden = true
        credLabels.forEach({$0.isHidden = true})
        usernameView.isHidden = true
        profileImageView.image = UIImage(named: "Icon")
    }
    
    func setupThirdParty(data: [String: Any]?) {
        userData = data ?? [:]
        if let username = data?[FirebaseKeys.username.rawValue] as? String {
            usernameField.text = username
            hasUsername = true
        }
        if let photo = data?[FirebaseKeys.profilePhotoURL.rawValue] as? String {
            profileImageView.sd_setImage(with: URL(string: photo), completed: nil)
        }
    }

    @IBAction func birthdayPicker(_ sender: UIDatePicker) {
        let birthday = sender.date
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.day, .month, .year], from: birthday, to: now)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        ageValid = (ageComponents.year! >= 18)
        enableSignup = true
    }
    
    @IBAction func didSelectPhoto(_ sender: UIButton) {
        delegate?.didSelectProfilePhoto()
    }

    @IBAction func didTapSignup(_ sender: ButtonX) {
        self.resignFirstResponder()
        if isLogin && isPhone && phoneField.text != "" {
            delegate?.didSelectSignup(data: [FirebaseKeys.number.rawValue: phoneField.text!])
            return
        }
        
        userData[FirebaseKeys.username.rawValue] = usernameField.text
        userData[FirebaseKeys.dateCreated.rawValue] = "\(Date().timeIntervalSince1970)"
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
        if usernameField.text != "" {
            if isPhone && phoneField.text != "" {
                hasUsername = true
            } else {
                hasUsername = true
            }
        } else {
            hasUsername = false
        }
        enableSignup = true
        return true
    }
}
