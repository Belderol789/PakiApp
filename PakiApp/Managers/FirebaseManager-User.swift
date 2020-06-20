//
//  FirebaseManager.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import Firebase

enum FirebaseKeys: String {
    case email
    case password
    case number
    case username
    case profilePhotoURL
    case coverPhotoURL
    case photo
    case coverPhoto
    //case birthday
    case uid
    case mediaURLs
    case tokenString
    
    case reportCount
    case commentID
    case commentKey
    case datePosted
    case dateCreated
    case dateStarted
    case title
    case content
    case paki
    case starCount
    case starList
    case blockedList
    case commentCount
    case shareCount
    case postKey
    case nsfw
    case postPrivate
    case currentPaki
}

enum SettingsKeys: String {
    case PrivacyPolicy
    case TermsConditions
    case EULA
    case EULAText
}

enum Identifiers: String {
    case users
    case profilePhoto
    case coverPhoto
    case posts
    case userPosts
    case pakiCount
    case comments
    case settings
}

class FirebaseManager {
    private static let _instance = FirebaseManager()
    static var Instance: FirebaseManager {
        return _instance
    }
    
    var firestoreDB: Firestore {
        get {
            let db = Firestore.firestore()
            let settings = db.settings
            settings.isPersistenceEnabled = false
            db.settings = settings
            return db
        }
    }
}

// MARK: - Firestore Handling
extension FirebaseManager {
    
    // MARK: - Get Settings Data
    func getSettingsData() {
        self.firestoreDB.collection(Identifiers.settings.rawValue).document("version1").getDocument { (data, error) in
            if let data = data?.data() {
                if let privacyPolicy = data[SettingsKeys.PrivacyPolicy.rawValue] as? String {
                    DatabaseManager.Instance.updateUserDefaults(value: privacyPolicy, key: .privacyPolicy)
                }
                
                if let termsConditions = data[SettingsKeys.TermsConditions.rawValue] as? String {
                    DatabaseManager.Instance.updateUserDefaults(value: termsConditions, key: .termsConditions)
                }
                
                if let eula = data[SettingsKeys.EULA.rawValue] as? String {
                    DatabaseManager.Instance.updateUserDefaults(value: eula, key: .eula)
                }
                
                if let eulaText = data[SettingsKeys.EULAText.rawValue] as? String {
                    DatabaseManager.Instance.updateUserDefaults(value: eulaText, key: .eulaText)
                }
                
            }
        }
    }
    
    // MARK: - Get User Data
    func getUserData(with uid: String, completed: @escaping (Bool) -> Void) {
        self.firestoreDB.collection(Identifiers.users.rawValue).document(uid).getDocument { (snapshot, error) in
            if let snap = snapshot, let snapshotData = snap.data(), snap.exists {
                DatabaseManager.Instance.updateUserDefaults(value: true, key: .userIsLoggedIn)
                DatabaseManager.Instance.saveUserData(snapshotData, completed: {
                    completed(true)
                    FirebaseManager.Instance.getUserPosts(userID: uid) { (userPosts) in
                        DatabaseManager.Instance.saveUserPosts(userPosts)
                    }
                })
            } else {
                completed(false)
            }
        }
    }
    
    func getUserStars(_ stars: @escaping ([String]) -> Void) {
        guard let uid = DatabaseManager.Instance.mainUser.uid else { return }
        self.firestoreDB.collection(Identifiers.users.rawValue).document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                if let starList = data[FirebaseKeys.starList.rawValue] as? [String] {
                    stars(starList)
                }
            }
        }
    }
    
    // MARK: - Update FirestoreDB
    func updateFirebase(data: [String: Any], identifier: Identifiers, mainID: String, loginHandler: LoginHandler?) {
        self.firestoreDB.collection(identifier.rawValue).document(mainID).setData(data, merge: true) { (err) in
            if err != nil {
                self.handleErrors(error: err! as NSError, loginHandler: loginHandler)
            } else {
                DatabaseManager.Instance.updateUserDefaults(value: true, key: .userIsLoggedIn)
                DatabaseManager.Instance.saveUserData(data, completed: {})
                loginHandler?(nil)
            }
        }
    }
    
    // MARK: - Image Upload
    func saveToStorage(datum: Data, identifier: Identifiers, storagePath: String, photoURLCompleted: LoginHandler?) {
        
        let storageRef = Storage.storage().reference().child(identifier.rawValue).child(storagePath).child("\(UUID().uuidString).jpg")
        
        storageRef.putData(datum, metadata: nil) { (metaData, error) in
            if error == nil {
                storageRef.downloadURL(completion: { (url, err) in
                    if let photoURL = url?.absoluteString {
                        photoURLCompleted?(photoURL)
                    }
                })
            }
        }
    }
    
    // MARK: - Update User Stars
    func updateUserStars(uid: String) {
        guard let userID = DatabaseManager.Instance.mainUser.uid else { return }
        
        print("UserUID \(userID) - PostUID \(uid)")
        
        let data = [FirebaseKeys.starList.rawValue: FieldValue.arrayUnion([userID])]
        self.firestoreDB.collection(Identifiers.users.rawValue).document(uid).setData(data, merge: true)
    }
    
    // MARK: - Report User
    func reportUserWith(uid: String) {
        guard let userID = DatabaseManager.Instance.mainUser.uid else { return }
        self.firestoreDB.collection(Identifiers.users.rawValue).document(userID).updateData([FirebaseKeys.blockedList.rawValue: FieldValue.arrayUnion([uid])]) { (error) in
            if error == nil {
                DatabaseManager.Instance.updateBlockedList(uid: uid)
            }
        }
    }
    
}
