//
//  FirebaseManager-Auth.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/30/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

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

    func signupUser(email: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let uid = result?.user.uid {
                DatabaseManager.Instance.updateUserDefaults(value: uid, key: .userSavedUID)
                loginHandler?(nil)
            }
        }
    }
    
    func loginUser(email: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let uid = result?.user.uid {
                self.getUserData(with: uid) { completed in
                    if completed {
                        loginHandler?(nil)
                    } else {
                        loginHandler?("Network Error. Kindly check your internet connection")
                    }
                }
            }
        }
    }
    
    func authenticatePhoneUser(phone: String, verifyWithID: @escaping (String) -> Void, loginHandler: LoginHandler?) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verify, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let verificationID = verify {
                verifyWithID(verificationID)
            }
        }
    }
    
    func proceedPhoneUser(verfID: String, verfCode: String, userData: [String: Any], loginHandler: LoginHandler?) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verfID, verificationCode: verfCode)
        Auth.auth().signIn(with: credential) { (result, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else if let uid = result?.user.uid {
                self.getUserData(with: uid) { completed in
                    if completed {
                        loginHandler?(nil)
                    } else {
                        DatabaseManager.Instance.updateUserDefaults(value: uid, key: .userSavedUID)
                        var data = userData
                        data[FirebaseKeys.uid.rawValue] = uid
                        if let imageData = userData[FirebaseKeys.profilePhotoURL.rawValue] as? Data {
                            self.saveToStorage(datum: imageData, identifier: .profilePhoto, storagePath: uid) { (profilePhotoURL) in
                                data[FirebaseKeys.profilePhotoURL.rawValue] = profilePhotoURL
                                self.updateFirebase(data: data, identifier: .users, mainID: uid, loginHandler: loginHandler)
                            }
                        } else {
                            self.updateFirebase(data: data, identifier: .users, mainID: uid, loginHandler: loginHandler)
                        }
                    }
                }
            }
        }
    }
    
    func loginWithFacebookUser(token: String, userData: [String: Any], loginHandler: LoginHandler?) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.handleErrors(error: error as NSError, loginHandler: loginHandler)
            } else if let uid = authResult?.user.uid {
                self.getUserData(with: uid) { completed in
                    if completed {
                        loginHandler?(nil)
                    } else {
                        var data = userData
                        data[FirebaseKeys.uid.rawValue] = uid
                        data[FirebaseKeys.tokenString.rawValue] = nil
                        data["isApple"] = nil
                        if let imageData = userData[FirebaseKeys.profilePhotoURL.rawValue] as? Data {
                            self.saveToStorage(datum: imageData, identifier: .profilePhoto, storagePath: uid) { (profilePhotoURL) in
                                data[FirebaseKeys.profilePhotoURL.rawValue] = profilePhotoURL
                                self.updateFirebase(data: data, identifier: .users, mainID: uid, loginHandler: loginHandler)
                            }
                        } else {
                            self.updateFirebase(data: data, identifier: .users, mainID: uid, loginHandler: loginHandler)
                        }
                    }
                }
            }
        }
    }
    
    func loginWithApplUser(idTokenString: String, nonce: String, userData: [String: Any], loginHandler: LoginHandler?) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.handleErrors(error: error as NSError, loginHandler: loginHandler)
            } else if let uid = authResult?.user.uid {
                self.getUserData(with: uid) { completed in
                    if completed {
                        loginHandler?(nil)
                    } else {
                        var data = userData
                        data[FirebaseKeys.uid.rawValue] = uid
                        data[FirebaseKeys.tokenString.rawValue] = nil
                        data["isApple"] = nil
                        if let imageData = userData[FirebaseKeys.profilePhotoURL.rawValue] as? Data {
                            self.saveToStorage(datum: imageData, identifier: .profilePhoto, storagePath: uid) { (profilePhotoURL) in
                                data[FirebaseKeys.profilePhotoURL.rawValue] = profilePhotoURL
                                self.updateFirebase(data: data, identifier: .users, mainID: uid, loginHandler: loginHandler)
                            }
                        } else {
                            self.updateFirebase(data: data, identifier: .users, mainID: uid, loginHandler: loginHandler)
                        }
                    }
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
