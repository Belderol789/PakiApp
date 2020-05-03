//
//  CredentialVC.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import Photos
import CountryPickerView

class CredentialVC: GeneralViewController, Reusable, CredentialViewProtocol {
    // IBOutlets
    @IBOutlet weak var credentialView: CredentialView!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    
    @IBOutlet var credentialFields: [UITextField]!
    @IBOutlet weak var loadingView: LoadingView!
    
    // Variables
    var authButton: UIBarButtonItem!
    var isLogin: Bool = false
    var phoneNumber: String?
    var countryCode: String?
    var verificationID: String?
    
    var enableAuthButton: Bool = false {
        didSet {
            navigationController?.navigationItem.rightBarButtonItem?.isEnabled = enableAuthButton
            authButton.tintColor = enableAuthButton ? .label : .systemGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
        hideTabbar = true
        self.title = "Welcome"
        
        let authTitle = isLogin ? "Login" : "Continue"
        authButton = UIBarButtonItem(title: authTitle, style: .done, target: self, action: #selector(authenticateUser))
        authButton.tintColor = .systemGray
        self.navigationItem.rightBarButtonItem  = authButton
        credentialView.delegate = self
        credentialView.usernameField.delegate = self
        credentialFields.forEach({$0.delegate = self})
        
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        cpv.delegate = self
        cpv.textColor = .systemGray2
        cpv.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
        
        self.countryCode = cpv.selectedCountry.phoneCode
        countryField.leftView = cpv
        countryField.leftViewMode = .always
    }
    
    @objc
    func authenticateUser() {
        if let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty {
            if !isLogin {
                credentialView.phoneCodeView.isHidden = true
                setupCredentialView()
                if let username = credentialView.usernameField.text, !username.isEmpty, let birthday = credentialView.birthday {
                    
                    loadingView.isHidden = false
                    loadingView.startLoading()
                    
                    let userImageData = credentialView.profileImageView.image?.compressTo(1)
                    enableAuthButton = false
                    FirebaseManager.Instance.signupUser(email: email, password: password, username: username, birth: birthday, photo: userImageData) { (message) in
                        self.userHasAuthenticated(message)
                    }
                }
            } else {
                
                loadingView.isHidden = false
                loadingView.startLoading()
                enableAuthButton = false
                FirebaseManager.Instance.loginUser(email: email, password: password) { (message) in
                    self.userHasAuthenticated(message)
                }
            }
        } else if let phone = phoneField.text, let countryCode = self.countryCode, !phone.isEmpty {
            phoneNumber = "\(countryCode)\(phone)"
            print("Phone number \(phoneNumber!)")
            enableAuthButton = false
            FirebaseManager.Instance.authenticateUser(phone: phoneNumber!, verifyWithID: { (verificationID) in
                print("Phone User Authenticated")
                self.setupCredentialView()
                if self.isLogin {
                    self.credentialView.setupPhoneLogin()
                }
                self.phoneField.text = nil
                self.verificationID = verificationID
            }) { (message) in
                self.showAlertWith(title: "Error verifying number", message: message!, actions: [], hasDefaultOK: true)
            }
        } else if let verfID = verificationID, let verfCode = credentialView.phoneField.text, !verfCode.isEmpty {
            
            loadingView.isHidden = false
            loadingView.startLoading()
            enableAuthButton = false
            if isLogin {
                FirebaseManager.Instance.loginPhoneUser(verfID: verfID, verfCode: verfCode) { (message) in
                    self.userHasAuthenticated(message)
                }
            } else if let username = credentialView.usernameField.text, !username.isEmpty, let birthday = credentialView.birthday {
                let userImageData = credentialView.profileImageView.image?.compressTo(1)
                FirebaseManager.Instance.signUpPhoneUser(verfID: verfID, verfCode: verfCode, username: username, birth: birthday, photo: userImageData) { (message) in
                    self.userHasAuthenticated(message)
                }
            }
        }
    }
    
    func setupCredentialView() {
        enableAuthButton = false
        authButton.title = "Finish"
        credentialView.isHidden = false
    }
    
    func userHasAuthenticated(_ message: String?) {
        loadingView.stopLoading()
        enableAuthButton = true
        if message != nil {
            authButton.title = isLogin ? "Login" : "Continue"
            self.showAlertWith(title: "Authentication Error", message: message!, actions: [], hasDefaultOK: true)
            credentialView.isHidden = true
        } else {
            print("Sucessfully loaded in user")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
            navigationController?.popViewController(animated: true)
            // go to main
        }
    }
    
    func enableSignup(birthday: Bool) {
        enableAuthButton = birthday
    }
    
    func didSelectProfilePhoto() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            presentPhotoLibrary()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                DispatchQueue.main.async {
                    if newStatus ==  PHAuthorizationStatus.authorized {
                        self.presentPhotoLibrary()
                    }else{
                        print("User denied")
                    }
                }})
        default:
            break
        }
    }
    
    fileprivate func presentPhotoLibrary() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
    
}

// MARK: - CountryPickerViewDelegate
extension CredentialVC: CountryPickerViewDelegate {

    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.countryCode = country.phoneCode
        self.phoneField.becomeFirstResponder()
    }
    
}

// MARK: - UIImagePickerController
extension CredentialVC: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        credentialView.profileImageView.image = image
    }
}

// MARK: - UITextField
extension CredentialVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case emailField, passwordField:
            if let email = emailField.text, let password = passwordField.text {
                enableAuthButton = (email != "" && password != "")
            }
        case phoneField:
            if let number = phoneField.text {
                enableAuthButton = number != ""
            }
        case credentialView.usernameField:
            if let username = credentialView.usernameField.text {
                enableAuthButton = (username != "" && credentialView.birthdayValid)
            }
        default:
            break
        }
        return true
    }
    
}
