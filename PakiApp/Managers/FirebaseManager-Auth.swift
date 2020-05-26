//
//  FirebaseManager-Auth.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/30/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import Firebase

typealias LoginHandler = (_ msg: String?) -> Void;
struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid email address, please provide a valid email address";
    static let WRONG_PASSWORD = "Wrong password, please enter the correct password";
    static let PROBLEM_CONNECTING = "Problem connecting to server";
    static let USER_NOT_FOUND = "User not Found, please register";
    static let EMAIL_ALREADY_IN_USE = "Email is already in use, please use another email";
    static let WEAK_PASSWORD = "Password should be at least 6 characters long";
    static let WRONG_CREDENTIALS = "Either the password or email is wrong";
}

// MARK: - Authentication
extension FirebaseManager {
    func signupUser(email: String, password: String, username: String, birth: String, photo: Data?, loginHandler: LoginHandler?) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let uid = result?.user.uid {
                
                let dateCreated = Date().timeIntervalSince1970
                
                var userData: [String: Any] = [FirebaseKeys.username.rawValue: username,
                                               FirebaseKeys.birthday.rawValue: birth,
                                               FirebaseKeys.uid.rawValue: uid,
                                               FirebaseKeys.email.rawValue: email,
                                               FirebaseKeys.dateCreated.rawValue: "\(dateCreated)",
                    FirebaseKeys.starList.rawValue: [uid]]
                
                DatabaseManager.Instance.updateUserDefaults(value: true, key: .userIsLoggedIn)
                
                if let datum = photo {
                    self.saveToStorage(datum: datum, identifier: .profilePhoto, storagePath: uid) { (photoURL) in
                        userData[FirebaseKeys.profilePhotoURL.rawValue] = photoURL
                        self.updateFirebase(data: userData, identifier: Identifiers.users, mainID: uid, loginHandler: loginHandler)
                    }
                } else {
                    self.updateFirebase(data: userData, identifier: Identifiers.users, mainID: uid, loginHandler: loginHandler)
                }
            }
        }
    }
    
    func loginUser(email: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let uid = result?.user.uid {
                self.getUserData(with: uid) {
                    DatabaseManager.Instance.updateUserDefaults(value: true, key: .userIsLoggedIn)
                    loginHandler?(nil)
                }
            }
        }
    }
    
    func authenticateUser(phone: String, verifyWithID: @escaping (String) -> Void, loginHandler: LoginHandler?) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verify, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let verificationID = verify {
                verifyWithID(verificationID)
            }
        }
    }
    
    func signUpPhoneUser(verfID: String, verfCode: String, username: String, birth: String, photo: Data?, loginHandler: LoginHandler?) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verfID, verificationCode: verfCode)
        Auth.auth().signIn(with: credential) { (result, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let uid = result?.user.uid {
                
                var userData: [String: Any] = [FirebaseKeys.username.rawValue: username,
                                               FirebaseKeys.birthday.rawValue: birth,
                                               FirebaseKeys.uid.rawValue: uid]
                DatabaseManager.Instance.updateUserDefaults(value: true, key: .userIsLoggedIn)
                
                if let datum = photo {
                    self.saveToStorage(datum: datum, identifier: .profilePhoto, storagePath: Identifiers.profilePhoto.rawValue) { (photoURL) in
                        userData[FirebaseKeys.profilePhotoURL.rawValue] = photoURL
                        self.updateFirebase(data: userData, identifier: Identifiers.users, mainID: uid, loginHandler: loginHandler)
                    }
                } else {
                    self.updateFirebase(data: userData, identifier: Identifiers.users, mainID: uid, loginHandler: loginHandler)
                }
            }
        }
    }
    
    func loginPhoneUser(verfID: String, verfCode: String, loginHandler: LoginHandler?) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verfID, verificationCode: verfCode)
        Auth.auth().signIn(with: credential) { (result, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let uid = result?.user.uid {
                self.getUserData(with: uid) {
                    DatabaseManager.Instance.updateUserDefaults(value: true, key: .userIsLoggedIn)
                    loginHandler?(nil)
                }
            }
        }
    }
    
    func logoutUser(complete: EmptyClosure) {
        do {
            DatabaseManager.Instance.updateUserDefaults(value: false, key: .userIsLoggedIn)
            try Auth.auth().signOut()
            complete()
        } catch {
            
        }
    }
    
    func deleteUser(success: @escaping BoolClosure) {
        if let user = Auth.auth().currentUser {
            user.delete { (error) in
                if error != nil {
                    success(false)
                } else {
                    DatabaseManager.Instance.deleteAll()
                    success(true)
                }
            }
        }
    }
    
    // MARK: - Error Handling
    func handleErrors(error: NSError, loginHandler: LoginHandler?) {
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break;
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break;
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break;
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break;
            case .accountExistsWithDifferentCredential:
                loginHandler?(LoginErrorCode.WRONG_CREDENTIALS)
                break
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break;
            }
        }
    }
}
