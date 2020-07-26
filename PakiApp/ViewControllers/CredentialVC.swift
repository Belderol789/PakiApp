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

class CredentialVC: GeneralViewController, Reusable {
    
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
    
    @IBOutlet weak var phoneView: PhoneView!
    
    @IBOutlet weak var signupButton: TransitionButton!
    // Variables
    var enableAuthButton: Bool = false {
        didSet {
            signupButton.isUserInteractionEnabled = enableAuthButton
            signupButton.backgroundColor = enableAuthButton ? UIColor.defaultPurple : .lightGray
        }
    }
    fileprivate var currentNonce: String?
    var isLogin: Bool = false
    
    var countryCode: String?
    var verificationID: String?
    
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
        
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        cpv.delegate = self
        cpv.textColor = .systemGray
        cpv.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
        
        self.countryCode = cpv.selectedCountry.phoneCode
        countryField.leftView = cpv
        countryField.leftViewMode = .always
        
        phoneView.delegate = self
    }
    
    @objc
    func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func didViewEndUserLicenseAgreement() {
        if let eula = DatabaseManager.Instance.eulaURL {
            self.openURL(string: eula)
        }
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
                        self.proceedToSignup(data: nil, type: .email)
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
                
                self.phoneView.isHidden = false
                
            }) { (message) in
                self.signupButton.stopAnimation()
                self.showAlertWith(title: "Error verifying number", message: message!, actions: [], hasDefaultOK: true)
            }
        }
    }
    
    fileprivate func proceedToSignup(data: [String: Any]?, type: SignupType) {
        let signupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        signupVC.type = type
        signupVC.appleNonce = currentNonce
        self.present(signupVC, animated: true) {
            if let userData = data {
                signupVC.setupThirdParty(data: userData)
            }
        }
    }
    
    fileprivate func userHasAuthenticated(_ message: String?) {
        loadingView.stopLoading()
        signupButton.stopAnimation()
        if message != nil {
            self.showAlertWith(title: "Authentication Error", message: message!, actions: [], hasDefaultOK: true)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: -IBActions
    @IBAction func userDidAuthenticate(_ sender: TransitionButton) {
        authenticateUser()
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

// MARK: - PhoneView
extension CredentialVC: PhoneViewProtocol {
    
    func submitCode(code: String) {
        self.phoneView.isHidden = true
        let phoneData: [String: Any] = [FirebaseKeys.phoneID.rawValue: verificationID!,
                                        FirebaseKeys.phoneCode.rawValue: code]
        proceedToSignup(data: phoneData, type: .phone)
    }
    
}

// MARK: - Facebook Login
extension CredentialVC: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let tokenString = AccessToken.current?.tokenString, result != nil else {
            self.showAlertWith(title: "Login Error", message: "There was an error with your login attempt", actions: [], hasDefaultOK: true)
            return
        }
        
        // login checker
        if isLogin {
            FirebaseManager.Instance.loginWithFacebookUser(token: tokenString) { (message) in
                self.userHasAuthenticated(message)
            }
        } else {
            FacebookCore.Profile.loadCurrentProfile { (profile, error) in
                
                var userInfo: [String: Any] = [:]
                let userName = profile?.name ?? UUID().uuidString
                
                userInfo[FirebaseKeys.username.rawValue] = userName
                userInfo[FirebaseKeys.tokenString.rawValue] = tokenString
                
                if let userImage = profile?.imageURL(forMode: .normal, size: CGSize(width: 250, height: 200)) {
                    userInfo[FirebaseKeys.profilePhotoURL.rawValue] = userImage
                }
                self.proceedToSignup(data: userInfo, type: .facebook)
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
            
            if isLogin {
                FirebaseManager.Instance.loginWithAppleUser(idTokenString: idTokenString, nonce: currentNonce!) { (message) in
                    self.userHasAuthenticated(message)
                }
            } else {
                var userInfo: [String: Any] = [:]
                userInfo[FirebaseKeys.tokenString.rawValue] = idTokenString
                userInfo[FirebaseKeys.username.rawValue] = appleIDCredential.fullName?.givenName ?? "Anonymous"
                proceedToSignup(data: userInfo, type: .apple)
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
