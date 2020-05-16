//
//  SettingsVC.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/1/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage
import SafariServices
import MessageUI
import TransitionButton

enum NotifName: String {
    case AppearanceChanged
}

class SettingsVC: GeneralViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    //IBOutlets
    @IBOutlet weak var profileImageView: ImageViewX!
    @IBOutlet weak var profileUsername: SkyFloatingLabelTextField!
    @IBOutlet var segmentViews: [UIView]!
    @IBOutlet weak var saveButton: TransitionButton!
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    
    var isProfilePhoto: Bool = true
    var didUpdatePhoto: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileUsername.delegate = self
        loadUserData()
        hideTabbar = true
        
        view.backgroundColor = UIColor.defaultBGColor
        segmentViews.forEach({$0.backgroundColor = UIColor.defaultFGColor})
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textCount = textField.returnTextCount(textField: textField, string: string, range: range, count: 15)
        profileUsername.selectedTitle = "\(textCount)/15"
        return textCount < 15
    }

    @IBAction func didTapSave(_ sender: TransitionButton) {
        sender.startAnimation()
        saveUserProfile()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
       dismiss(animated: true, completion: nil)
    }
    
    @objc
    func saveUserProfile() {
        
        var updatedProfile: [String: Any] = [:]
        
        let mainUser = DatabaseManager.Instance.mainUser
        if mainUser.username != profileUsername.text && profileUsername.text != "" {
            updatedProfile[FirebaseKeys.username.rawValue] = profileUsername.text
            let updatedUsername: [String: Any] = [FirebaseKeys.username.rawValue: profileUsername.text!]
            FirebaseManager.Instance.updateFirebase(data: updatedUsername, identifier: .users, mainID: mainUser.uid!) { (message) in
                self.saveButton.stopAnimation()
                if let message = message {
                    self.showAlertWith(title: "Error Saving", message: message, actions: [], hasDefaultOK: true)
                } else {
                    self.showAlertWith(title: "Success!", message: "Profile has been updated", actions: [], hasDefaultOK: true)
                }
            }
        }
        
        if didUpdatePhoto {
            updatedProfile[FirebaseKeys.photo.rawValue] = self.profileImageView.image
            if let updatedPhoto = self.profileImageView.image?.compressTo(1) {
                FirebaseManager.Instance.saveToStorage(datum: updatedPhoto, identifier: .profilePhoto, storagePath: mainUser.uid!) { (profilePhoto) in
                    self.saveButton.stopAnimation()
                    if let profilePhoto = profilePhoto {
                        let updatedPhoto: [String: Any] = [FirebaseKeys.profilePhotoURL.rawValue: profilePhoto]
                        FirebaseManager.Instance.updateFirebase(data: updatedPhoto, identifier: .users, mainID: mainUser.uid!, loginHandler: nil)
                    }
                }
            }
            updatedProfile[FirebaseKeys.coverPhoto.rawValue] = self.coverPhotoImageView.image
            if let updatedCover = self.coverPhotoImageView.image?.compressTo(1) {
                FirebaseManager.Instance.saveToStorage(datum: updatedCover, identifier: .coverPhoto, storagePath: mainUser.uid!) { (profilePhoto) in
                    self.saveButton.stopAnimation()
                    if let updatedCoverPhoto = profilePhoto {
                        let updatedPhoto: [String: Any] = [FirebaseKeys.coverPhotoURL.rawValue: updatedCoverPhoto]
                        FirebaseManager.Instance.updateFirebase(data: updatedPhoto, identifier: .users, mainID: mainUser.uid!, loginHandler: nil)
                    }
                }
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("UpdateProfile"), object: updatedProfile)
        
    }
    
    fileprivate func loadUserData() {
        let user = DatabaseManager.Instance.mainUser
        profileUsername.text = user.username
        if let profileURL = user.profilePhotoURL {
            let url = URL(string: profileURL)
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "Mascot"), options: .continueInBackground, completed: nil)
        }
        
        if let coverPhotoURL = user.coverPhotoURL {
            let url = URL(string: coverPhotoURL)
            coverPhotoImageView.sd_setImage(with: url, placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
        
    }
    
    func openInSafari(urlString: String) {
        if let url = URL(string: urlString) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
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

    @IBAction func didOpenGallery(_ sender: UIButton) {
        isProfilePhoto = sender.tag == 0
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func didContactEmail(_ sender: UIButton) {
        sendEmail()
    }
    
    @IBAction func didContactFacebook(_ sender: UIButton) {
        openInSafari(urlString: "https://www.facebook.com/PakiApp-110665120632070/?view_public_for=110665120632070")
    }
    
    @IBAction func didTapTermsConditions(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPrivacyPolicy(_ sender: UIButton) {
        
    }
    
    @IBAction func didLogout(_ sender: ButtonX) {
        self.showAlertWith(title: "Logout", message: "This will log you out of Paki", actions: [UIAlertAction(title: "Logout", style: .default, handler: { (_) in
            FirebaseManager.Instance.logoutUser {
                self.navigationController?.popViewController(animated: true)
                self.tabBarController?.selectedIndex = 1
            }
        }), UIAlertAction(title: "Cancel", style: .cancel, handler: nil)], hasDefaultOK: false)
    }
    
    @IBAction func didDelete(_ sender: ButtonX) {
        self.showAlertWith(title: "Delete?", message: "This will delete your account and all information related to it.", actions: [UIAlertAction(title: "Confirm", style: .destructive, handler: { (_) in
            self.deleteUserForGood()
        }), UIAlertAction(title: "Cancel", style: .cancel, handler: nil)], hasDefaultOK: false)
    }
    
    fileprivate func deleteUserForGood() {
        let user = DatabaseManager.Instance.mainUser
        FirebaseManager.Instance.deleteUser { (success) in
            if success {
                self.navigationController?.popViewController(animated: true)
                self.tabBarController?.selectedIndex = 1
            } else {
                let alert = UIAlertController(title: "Kindly login again", message: "Deleting of account requires authentication from owner", preferredStyle: .alert)
                if user.email != nil {
                    alert.addTextField { (emailField) in
                        emailField.placeholder = "Enter Email"
                    }
                    alert.addTextField { (passwordField) in
                        passwordField.placeholder = "Enter Password"
                    }
                    let confirm = UIAlertAction(title: "Confirm", style: .destructive) { (action) in
                        guard let email = alert.textFields?[0].text,
                            let password = alert.textFields?[1].text else { return }
                        FirebaseManager.Instance.loginUser(email: email, password: password) { (message) in
                            if let message = message {
                                self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                            } else {
                                self.navigationController?.popViewController(animated: true)
                                self.tabBarController?.selectedIndex = 1
                            }
                        }
                    }
                    alert.addAction(confirm)
                } else {
                    alert.addTextField { (numberField) in
                        numberField.placeholder = "Enter Phone Number"
                    }
                    let phoneConfirm = UIAlertAction(title: "Confirm", style: .destructive) { (action) in
                        
                    }
                    alert.addAction(phoneConfirm)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UIImagePickerController
extension SettingsVC: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        didUpdatePhoto = true
        if isProfilePhoto {
            profileImageView.image = image
        } else {
            coverPhotoImageView.image = image
        }
    }
}
