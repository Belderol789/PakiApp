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
import TransitionButton

class CredentialVC: GeneralViewController, Reusable, MFMailComposeViewControllerDelegate, CredentialViewProtocol {

    // IBOutlets
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    
    @IBOutlet var credentialViews: [ViewX]!
    @IBOutlet var credentialFields: [UITextField]!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var facebookBtnContainer: UIView!
    @IBOutlet weak var appleContainerView: UIView!
    
    @IBOutlet weak var credentialView: CredentialView!
    @IBOutlet weak var eulaView: UIView!
    @IBOutlet weak var eulaSwitch: UISwitch!
    @IBOutlet weak var eulaTextView: UITextView!
    @IBOutlet weak var eulaButton: TransitionButton!
    
    
    @IBOutlet weak var signupButton: TransitionButton!
    // Variables
    var enableAuthButton: Bool = false {
        didSet {
            signupButton.isUserInteractionEnabled = enableAuthButton
            signupButton.backgroundColor = enableAuthButton ? UIColor.defaultPurple : .lightGray
        }
    }
    var enableEULA: Bool = false {
        didSet {
            eulaButton.isUserInteractionEnabled = enableEULA
            eulaButton.backgroundColor = enableEULA ? UIColor.defaultPurple : .lightGray
        }
    }
    fileprivate var currentNonce: String?
    var isLogin: Bool = false
    var countryCode: String?
    var verificationID: String?
    var userData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableAuthButton = false
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
        
        if #available(iOS 13.0, *) {
            let appleButton = ASAuthorizationAppleIDButton(type: .default, style: .white)
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
    }
    
    @available(iOS 13.0, *)
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
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)
        tabBarController?.tabBar.isHidden = true
        view.backgroundColor = UIColor.defaultBGColor
        self.title = "Welcome"
        let btnTitle: String = isLogin ? "Login" : "Signup"
        signupButton.setTitle(btnTitle, for: .normal)
        
        credentialFields.forEach({
            $0.delegate = self
            $0.tintColor = .white
            $0.textColor = .white
        })
        credentialViews.forEach({
            $0.backgroundColor = UIColor.defaultFGColor
        })
        credentialView.delegate = self
        
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        cpv.delegate = self
        cpv.textColor = .systemGray
        cpv.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
        
        self.countryCode = cpv.selectedCountry.phoneCode
        countryField.leftView = cpv
        countryField.leftViewMode = .always
        
        if let eulaText = DatabaseManager.Instance.eulaText {
            eulaTextView.text = eulaText
        }
    }
    
    @objc
    func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func didViewEndUserLicenseAgreement() {
        if let eula = DatabaseManager.Instance.eula {
            self.openURL(string: eula)
        }
    }
    
    @IBAction func userDidAuthenticate(_ sender: TransitionButton) {
        authenticateUser()
    }
    
    @objc
    func authenticateUser() {
        if let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty {
            signupButton.startAnimation()
            
            if !isLogin {
                FirebaseManager.Instance.signupUser(email: email, password: password) { (message) in
                    self.signupButton.stopAnimation()
                    if let error = message {
                        self.showAlertWith(title: "Error Signing up", message: error, actions: [], hasDefaultOK: true)
                    } else {
                        self.setupCredentialView(isPhone: false, withData: nil)
                    }
                }
            } else {
                FirebaseManager.Instance.loginUser(email: email, password: password) { (message) in
                    self.userHasAuthenticated(message)
                }
            }
        } else if let phone = phoneField.text, let countryCode = self.countryCode, !phone.isEmpty {
            
            let phoneNumber = "\(countryCode)\(phone)"
            signupButton.startAnimation()
            FirebaseManager.Instance.authenticatePhoneUser(phone: phoneNumber, verifyWithID: { (verificationID) in
                // Require phone code here
                self.signupButton.stopAnimation()
                self.phoneField.text = nil
                self.verificationID = verificationID
                self.setupCredentialView(isPhone: true, withData: nil)
                
                print("Verification code \(verificationID)")
                
            }) { (message) in
                self.signupButton.stopAnimation()
                self.showAlertWith(title: "Error verifying number", message: message!, actions: [], hasDefaultOK: true)
            }
        }
    }
    
    func didSelectSignup(data: [String : Any]) {
        userData = data
        eulaView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.eulaView.alpha = 1
        }
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
    
    func setupCredentialView(isPhone: Bool, withData: [String: Any]?) {
        credentialView.isHidden = false
        credentialView.isPhone = isPhone
        if isLogin {
            credentialView.setupPhoneLogin()
        }
        credentialView.phoneCodeView.isHidden = !isPhone
        credentialView.setupThirdParty(data: withData)
        UIView.animate(withDuration: 0.3) {
            self.credentialView.alpha = 1
        }
    }
    
    func userHasAuthenticated(_ message: String?) {
        loadingView.stopLoading()
        signupButton.stopAnimation()
        if message != nil {
            self.showAlertWith(title: "Authentication Error", message: message!, actions: [], hasDefaultOK: true)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
            navigationController?.popViewController(animated: true)
        }
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
    
    @IBAction func didSwitchEula(_ sender: UISwitch) {
        enableEULA = sender.isOn
    }
    
    @IBAction func didAgreeToEula(_ sender: TransitionButton) {
        loadingView.isHidden = false
        loadingView.startLoading()
        if let tokenID = userData[FirebaseKeys.tokenString.rawValue] as? String, let isApple = userData["isApple"] as? Bool {
              if isApple {
                  FirebaseManager.Instance.loginWithApplUser(idTokenString: tokenID, nonce: currentNonce!, userData: userData) { (message) in
                      self.userHasAuthenticated(message)
                  }
              } else {
                  FirebaseManager.Instance.loginWithFacebookUser(token: tokenID, userData: userData) { (message) in
                      self.userHasAuthenticated(message)
                  }
              }
          } else if let phoneCode = userData[FirebaseKeys.number.rawValue] as? String {
              FirebaseManager.Instance.proceedPhoneUser(verfID: verificationID!, verfCode: phoneCode, userData: userData) { (message) in
                  self.userHasAuthenticated(message)
              }
          } else if let uid = DatabaseManager.Instance.userSavedUid {
              
              userData[FirebaseKeys.uid.rawValue] = uid
              
              if let profileData = userData[FirebaseKeys.profilePhotoURL.rawValue] as? Data {
                  FirebaseManager.Instance.saveToStorage(datum: profileData, identifier: .profilePhoto, storagePath: uid) { (profilePhotoURL) in
                    self.userData[FirebaseKeys.profilePhotoURL.rawValue] = profilePhotoURL
                    FirebaseManager.Instance.updateFirebase(data: self.userData, identifier: .users, mainID: uid) { (message) in
                          self.userHasAuthenticated(message)
                      }
                  }
              } else {
                  FirebaseManager.Instance.updateFirebase(data: userData, identifier: .users, mainID: uid) { (message) in
                      self.userHasAuthenticated(message)
                  }
              }
          }
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

// MARK: - CountryPickerViewDelegate
extension CredentialVC: CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.countryCode = country.phoneCode
        self.phoneField.becomeFirstResponder()
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

        FacebookCore.Profile.loadCurrentProfile { (profile, error) in
            
            var userInfo: [String: Any] = [:]
            let userName = profile?.name ?? UUID().uuidString
            
            userInfo[FirebaseKeys.username.rawValue] = userName
            userInfo[FirebaseKeys.tokenString.rawValue] = tokenString
            userInfo["isApple"] = false
            
            if let userImage = profile?.imageURL(forMode: .normal, size: CGSize(width: 250, height: 200)) {
                userInfo[FirebaseKeys.profilePhotoURL.rawValue] = userImage.absoluteString
            }
            
            self.setupCredentialView(isPhone: false, withData: userInfo)
            /*
            FirebaseManager.Instance.loginWithFacebookUser(token: tokenString, userData: userInfo) { (message) in
                self.userHasAuthenticated(message)
            }
             */
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        FirebaseManager.Instance.logoutUser {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
        }
    }
}

// MARK: - Apple Signin
@available(iOS 13.0, *)
extension CredentialVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard currentNonce != nil else {
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
            
            var userInfo: [String: Any] = [:]
            userInfo[FirebaseKeys.tokenString.rawValue] = idTokenString
            userInfo[FirebaseKeys.username.rawValue] = appleIDCredential.fullName?.givenName ?? "Anonymous"
            userInfo["isApple"] = true

            self.setupCredentialView(isPhone: false, withData: userInfo)
            
            /*
            // Initialize a Firebase credential.
            FirebaseManager.Instance.loginWithApplUser(idTokenString: idTokenString, nonce: nonce, userData: userData) { (message) in
                self.userHasAuthenticated(message)
            }
             */
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
