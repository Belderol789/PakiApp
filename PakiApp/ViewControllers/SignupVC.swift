//
//  SignupVC.swift
//  PakiApp
//
//  Created by Kem Belderol on 7/26/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import Photos
import SkyFloatingLabelTextField
import SDWebImage
import TransitionButton

enum SignupType {
    case email
    case phone
    case facebook
    case apple
}

class SignupVC: UIViewController {
    
    @IBOutlet weak var successScreen: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var usernameField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameNext: ButtonX!
    
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBOutlet weak var birthdayNext: ButtonX!
    
    @IBOutlet weak var profileImageView: ImageViewX!
    @IBOutlet weak var profileNext: ButtonX!
    
    @IBOutlet weak var loadingView: LoadingView!
    
    
    var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    var usernameEnable: Bool = false {
        didSet {
            let color: UIColor = usernameEnable ? UIColor.defaultPurple : .lightGray
            usernameNext.isUserInteractionEnabled = usernameEnable
            usernameNext.backgroundColor = color
        }
    }
    
    var birthdayEnable: Bool = false {
        didSet {
            let color: UIColor = birthdayEnable ? UIColor.defaultPurple : .lightGray
            birthdayNext.isUserInteractionEnabled = birthdayEnable
            birthdayNext.backgroundColor = color
        }
    }
    
    var photoEnable: Bool = false {
        didSet {
            let color: UIColor = photoEnable ? UIColor.defaultPurple : .lightGray
            profileNext.isUserInteractionEnabled = photoEnable
            profileNext.backgroundColor = color
        }
    }
    
    var userData: [String: Any] = [:] {
        didSet {
            print("UserData \(userData)")
        }
    }
    
    var appleNonce: String?
    var tokenString: String?
    var years: Int?
    var type: SignupType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
        usernameField.delegate = self
        birthdayPicker.setValue(UIColor.white, forKeyPath: "textColor")
        birthdayPicker.setValue(false, forKey: "highlightsToday")
        
        view.backgroundColor = UIColor.defaultBGColor
        successScreen.backgroundColor = UIColor.defaultBGColor
        
        loadingView.isHidden = true
        loadingView.setupCircleViews(paki: .all)
    }
    
    public func setupThirdParty(data: [String: Any]) {
        userData = data
        usernameEnable = true
        usernameField.text = data[FirebaseKeys.username.rawValue] as? String
        if let photoURL = data[FirebaseKeys.profilePhotoURL.rawValue] as? URL {
            photoEnable = true
            profileImageView.sd_setImage(with: photoURL, completed: nil)
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
    
    fileprivate func signupUser() {
        // start loading here
        loadingView.startLoading()
        
        if let profilePhoto = profileImageView.image?.compressTo(1) {
            userData[FirebaseKeys.profilePhotoURL.rawValue] = profilePhoto
        }
        
        if years != nil {
           userData[FirebaseKeys.birthday.rawValue] = birthdayPicker.date.convertToMediumString()
        }
        
        userData[FirebaseKeys.username.rawValue] = usernameField.text
        userData[FirebaseKeys.dateCreated.rawValue] = "\(Date().timeIntervalSince1970)"
        
        switch type {
        case .email:
            guard let uid = DatabaseManager.Instance.userSavedUid else { return }
            userData[FirebaseKeys.uid.rawValue] = uid
            if let profileData = userData[FirebaseKeys.profilePhotoURL.rawValue] as? Data {
                FirebaseManager.Instance.saveToStorage(datum: profileData, identifier: .profilePhoto, storagePath: uid) { (profilePhotoURL) in
                    self.userData[FirebaseKeys.profilePhotoURL.rawValue] = profilePhotoURL
                    FirebaseManager.Instance.updateFirebase(data: self.userData, identifier: .users, mainID: uid) { (message) in
                        self.loadingView.stopLoading()
                        if let message = message {
                            self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                        } else {
                            self.successScreen.isHidden = false
                        }
                    }
                }
            } else {
                FirebaseManager.Instance.updateFirebase(data: userData, identifier: .users, mainID: uid) { (message) in
                    self.loadingView.stopLoading()
                    if let message = message {
                        self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                    } else {
                        self.successScreen.isHidden = false
                    }
                }
            }
        case .phone:
            if let code = userData[FirebaseKeys.phoneCode.rawValue] as? String, let verfID = userData[FirebaseKeys.phoneID.rawValue] as? String {
                
                userData[FirebaseKeys.phoneCode.rawValue] = nil
                userData[FirebaseKeys.phoneID.rawValue] = nil

                FirebaseManager.Instance.proceedPhoneUser(verfID: verfID, verfCode: code, userData: userData) { (message) in
                    self.loadingView.stopLoading()
                    if let message = message {
                        self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                    } else {
                        self.successScreen.isHidden = false
                    }
                }
            }
        case .facebook:
            guard let tokenString = userData[FirebaseKeys.tokenString.rawValue] as? String else { return }
            FirebaseManager.Instance.signupWithFacebookUser(token: tokenString, userData: userData) { (message) in
                self.loadingView.stopLoading()
                if let message = message {
                    self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                } else {
                    self.successScreen.isHidden = false
                }
            }
        case .apple:
            guard let tokenString = userData[FirebaseKeys.tokenString.rawValue] as? String else { return }
            FirebaseManager.Instance.signupWithAppleUser(idTokenString: tokenString, nonce: appleNonce!, userData: userData) { (message) in
                self.loadingView.stopLoading()
                if let message = message {
                    self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                } else {
                    self.successScreen.isHidden = false
                }
            }
        default:
            break
        }
    }
    
    @IBAction func didChangeBirthday(_ sender: UIDatePicker) {
        let birthday = sender.date
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.day, .month, .year], from: birthday, to: now)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        years = ageComponents.year
        birthdayEnable = (ageComponents.year! >= 13)
    }
    
    @IBAction func signupSuccess(_ sender: ButtonX) {
        
    }
    
    @IBAction func didRemoveKeyboard(_ sender: UIButton) {
        view.endEditing(true)
    }
    @IBAction func didTapNextUsername(_ sender: ButtonX) {
        currentPage += 1
        scrollView.moveToNextView()
    }
    
    @IBAction func didTapProfile(_ sender: UIButton) {
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
    @IBAction func didTapNextProfile(_ sender: ButtonX) {
        signupUser()
    }
    @IBAction func didSkipProfile(_ sender: UIButton) {
        signupUser()
    }
    
    @IBAction func didNextBirthday(_ sender: ButtonX) {
        if birthdayEnable {
            currentPage += 1
            scrollView.moveToNextView()
        }
    }
    @IBAction func didSkipBirthday(_ sender: UIButton) {
        currentPage += 1
        scrollView.moveToNextView()
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        if currentPage != 0 {
            currentPage -= 1
            scrollView.moveToPreviousView()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITextFieldDelegate
extension SignupVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        usernameEnable = usernameField.text != ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if usernameEnable {
            scrollView.moveToNextView()
        }
        view.endEditing(true)
        return true
    }
    
}
// MARK: - UIImagePickerController
extension SignupVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        self.profileImageView.image = image
        photoEnable = true
    }
}
