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
import MessageUI
import FacebookLogin
import FacebookCore
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class CredentialVC: GeneralViewController, Reusable, CredentialViewProtocol, MFMailComposeViewControllerDelegate {
    // IBOutlets
    @IBOutlet weak var credentialView: CredentialView!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    
    @IBOutlet var credentialViews: [ViewX]!
    @IBOutlet var credentialFields: [UITextField]!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var facebookBtnContainer: UIView!
    @IBOutlet weak var appleContainerView: UIView!
    
    // Variables
    fileprivate var currentNonce: String?
    var authButton: UIBarButtonItem!
    var isLogin: Bool = false
    var phoneNumber: String?
    var countryCode: String?
    var verificationID: String?
    
    var enableAuthButton: Bool = false {
        didSet {
            navigationController?.navigationItem.rightBarButtonItem?.isEnabled = enableAuthButton
            authButton.tintColor = enableAuthButton ? .white : .systemGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAlternativeAuth()
    }
    
    fileprivate func setupAlternativeAuth() {
        
        let loginButton = FBLoginButton()
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.permissions = ["public_profile", "email"]
        loginButton.delegate = self
        facebookBtnContainer.addSubview(loginButton)
        facebookBtnContainer.layer.cornerRadius = 15
        facebookBtnContainer.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            loginButton.centerYAnchor.constraint(equalTo: facebookBtnContainer.centerYAnchor),
            loginButton.leadingAnchor.constraint(equalTo: facebookBtnContainer.leadingAnchor, constant: 0),
            loginButton.trailingAnchor.constraint(equalTo: facebookBtnContainer.trailingAnchor, constant: 0),
            loginButton.topAnchor.constraint(equalTo: facebookBtnContainer.topAnchor, constant: 0),
            loginButton.bottomAnchor.constraint(equalTo: facebookBtnContainer.bottomAnchor, constant: 0)
        ])
        
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(didTapAppleButton), for: .touchDown)
        appleContainerView.addSubview(appleButton)
        appleContainerView.layer.cornerRadius = 15
        appleContainerView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            appleButton.centerYAnchor.constraint(equalTo: appleContainerView.centerYAnchor),
            appleButton.leadingAnchor.constraint(equalTo: appleContainerView.leadingAnchor, constant: 0),
            appleButton.trailingAnchor.constraint(equalTo: appleContainerView.trailingAnchor, constant: 0),
            appleButton.topAnchor.constraint(equalTo: appleContainerView.topAnchor, constant: 0),
            appleButton.bottomAnchor.constraint(equalTo: appleContainerView.bottomAnchor, constant: 0)
        ])
    }
    
    @objc
    func didTapAppleButton() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    fileprivate func setupUI() {
        
        overrideUserInterfaceStyle = .dark
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)
        tabBarController?.tabBar.isHidden = true
        view.backgroundColor = UIColor.defaultBGColor
        credentialView.backgroundColor = UIColor.defaultBGColor
        self.title = "Welcome"
        
        let authTitle = isLogin ? "Login" : "Continue"
        authButton = UIBarButtonItem(title: authTitle, style: .done, target: self, action: #selector(authenticateUser))
        authButton.tintColor = .systemGray
        self.navigationItem.rightBarButtonItem  = authButton
        credentialView.delegate = self
        credentialView.usernameField.delegate = self
        credentialFields.forEach({
            $0.delegate = self
            $0.tintColor = .white
            $0.textColor = .white
        })
        credentialViews.forEach({
            $0.backgroundColor = UIColor.defaultFGColor
        })
        
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        cpv.delegate = self
        cpv.textColor = .systemGray2
        cpv.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
        
        self.countryCode = cpv.selectedCountry.phoneCode
        countryField.leftView = cpv
        countryField.leftViewMode = .always
    }
    
    @objc
    func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
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
            credentialView.usernameField.text = nil
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
    
    func sendEmail() {
        let email = "krats.apps@gmail.com"
        let emailURLString = "mailto:\(email)"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody("", isHTML: true)
            present(mail, animated: true)
        } else if let emailURL = URL(string: emailURLString), UIApplication.shared.canOpenURL(emailURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(emailURL)
            } else {
                UIApplication.shared.openURL(emailURL)
            }
        } else {
            print("Device unable to send emails")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // MARK: -IBActions
    @IBAction func tapRemainAnonymous(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapTermsConditions(_ sender: UIButton) {
        if let termsConditions = DatabaseManager.Instance.termsConditions {
            self.openURL(string: termsConditions)
        }
    }
    
    @IBAction func tapPrivacyPolicy(_ sender: UIButton) {
        if let privacyPolicy = DatabaseManager.Instance.privacyPolicy {
            self.openURL(string: privacyPolicy)
        }
    }
    
    @IBAction func tapContactUs(_ sender: UIButton) {
        sendEmail()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            authenticateUser()
        }
        return true
    }
    
}

// MARK: - Facebook Login
extension CredentialVC: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let tokenString = AccessToken.current?.tokenString, result != nil else {
            self.showAlertWith(title: "Login Error", message: "There was an error with your login attempt", actions: [], hasDefaultOK: true)
            return
        }
        
        loadingView.isHidden = false
        loadingView.startLoading()
        
        
        FirebaseManager.Instance.loginWithFacebookUser(token: tokenString) { (message) in
            if let message = message {
                self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
            } else {
                FacebookCore.Profile.loadCurrentProfile { (profile, error) in
                    
                    var userInfo: [String: Any] = [:]
                    guard let userUID = profile?.userID, let userName = profile?.name else { return }
                    
                    let dateCreated = Date().timeIntervalSince1970
                    
                    userInfo[FirebaseKeys.dateCreated.rawValue] = "\(dateCreated)"
                    userInfo[FirebaseKeys.uid.rawValue] = userUID
                    userInfo[FirebaseKeys.username.rawValue] = userName
                    
                    if let userImage = profile?.imageURL(forMode: .normal, size: CGSize(width: 250, height: 200)) {
                        userInfo[FirebaseKeys.profilePhotoURL.rawValue] = userImage.absoluteString
                    }
                    
                    print("FBUser info \(userInfo)")
                    FirebaseManager.Instance.updateFirebase(data: userInfo, identifier: .users, mainID: userUID) { (message) in
                        self.userHasAuthenticated(message)
                    }
                }
            }
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        FirebaseManager.Instance.logoutUser {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
        }
    }
}

// MARK: - Apple Signin
extension CredentialVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
            
            var userData: [String: Any] = [:]
            userData[FirebaseKeys.uid.rawValue] = appleIDCredential.user
            userData[FirebaseKeys.username.rawValue] = appleIDCredential.fullName?.givenName ?? "Anonymous"
            userData[FirebaseKeys.email.rawValue] = appleIDCredential.email
            
            let dateCreated = Date().timeIntervalSince1970
            userData[FirebaseKeys.dateCreated.rawValue] = "\(dateCreated)"
            
            print("AppleUserData \(userData)")
            
            loadingView.startLoading()
            loadingView.isHidden = false
            
          // Initialize a Firebase credential.
            FirebaseManager.Instance.loginWithApplUser(idTokenString: idTokenString, nonce: nonce) { (message) in
                if let message = message {
                    self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                } else {
                    FirebaseManager.Instance.updateFirebase(data: userData, identifier: .users, mainID: appleIDCredential.user) { (message) in
                        self.userHasAuthenticated(message)
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlertWith(title: "Error", message: error.localizedDescription, actions: [], hasDefaultOK: true)
        loadingView.stopLoading()
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
}
