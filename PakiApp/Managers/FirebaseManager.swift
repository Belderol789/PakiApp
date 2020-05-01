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
    case username
    case profilePhotoURL
    case birthday
    case uid
    case datePosted
    case title
    case content
    case paki
    case starCount
    case commentCount
    case shareCount
    case postTag
}

enum Identifiers: String {
    case users
    case profilePhoto
    case posts
    case userPosts
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
    
    // MARK: - Get User Data
    func getUserData(with uid: String, completed: @escaping () -> Void) {
        self.firestoreDB.collection(Identifiers.users.rawValue).document(uid).getDocument { (snapshot, error) in
            if let snapshotData = snapshot?.data() {
                DatabaseManager.Instance.saveUserData(snapshotData, completed: {
                    FirebaseManager.Instance.getUserPosts { (userPosts) in
                        DatabaseManager.Instance.updateRealm(key: FirebaseKeys.postTag.rawValue, value: (userPosts.count - 1))
                        DatabaseManager.Instance.saveUserPosts(userPosts)
                    }
                    completed()
                })
            }
        }
    }
    
    // MARK: - Update FirestoreDB
    func updateFirebase(data: [String: Any], identifier: String, docuID: String, loginHandler: LoginHandler?) {
        self.firestoreDB.collection(identifier).document(docuID).setData(data, merge: true) { (err) in
            if err != nil {
                self.handleErrors(error: err! as NSError, loginHandler: loginHandler)
            } else {
                DatabaseManager.Instance.saveUserData(data, completed: {})
                loginHandler?(nil)
            }
        }
    }
    
    // MARK: - Image Upload
    func saveToStorage(datum: Data, storagePath: String, photoURLCompleted: @escaping (String) -> Void) {
        
        let storageRef = Storage.storage().reference().child(Identifiers.profilePhoto.rawValue).child(storagePath).child("\(UUID().uuidString).jpg")
        
        storageRef.putData(datum, metadata: nil) { (metaData, error) in
            if error == nil {
                storageRef.downloadURL(completion: { (url, err) in
                    if let photoURL = url?.absoluteString {
                        photoURLCompleted(photoURL)
                    }
                })
            }
        }
    }
}
