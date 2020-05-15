//
//  FirebaseManager-Comment.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/3/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import Firebase

extension FirebaseManager {
    
    func sendUserComment(text: String, post: UserPost, loginHandler: LoginHandler?) {
        
        let mainUser = DatabaseManager.Instance.mainUser
        let dateSent = Date().timeIntervalSince1970
        let commentKey = post.commentKey
        let uniqueID = UUID().uuidString
        
        let commentData: [String: Any] = [FirebaseKeys.datePosted.rawValue: dateSent,
                                          FirebaseKeys.username.rawValue: mainUser.username!,
                                          FirebaseKeys.profilePhotoURL.rawValue: mainUser.profilePhotoURL ?? "",
                                          FirebaseKeys.content.rawValue: text,
                                          FirebaseKeys.paki.rawValue: mainUser.currentPaki ?? "none",
                                          FirebaseKeys.uid.rawValue: mainUser.uid!,
                                          FirebaseKeys.commentID.rawValue: uniqueID,
                                          FirebaseKeys.starList.rawValue: [mainUser.uid]]
        
        self.firestoreDB.collection(Identifiers.comments.rawValue).document(post.paki).collection(commentKey!).document(uniqueID).setData(commentData) { (error) in
            if let err = error {
                self.handleErrors(error: err as NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil)
            }
        }
    }
    
    func updateCommentStar(post: UserPost, commentKey: String) {
        guard let commentID = post.commentID, let uid = DatabaseManager.Instance.mainUser.uid else { return }
        self.firestoreDB.collection(Identifiers.comments.rawValue).document(post.paki).collection(commentKey).document(commentID).updateData([FirebaseKeys.starList.rawValue: FieldValue.arrayUnion([uid])])
    }
    
    func getAllCommentsFrom(post: UserPost, loginHandler: LoginHandler?, comment: @escaping (UserPost) -> Void) {
        let commentKey = post.commentKey
        
        self.firestoreDB.collection(Identifiers.comments.rawValue).document(post.paki).collection(commentKey!).addSnapshotListener { (documentData, error) in
            if let err = error {
                self.handleErrors(error: err as NSError, loginHandler: loginHandler)
            } else if let documents = documentData?.documents {
                for document in documents {
                    let data = document.data()
                    let commentPost = UserPost.convert(data: data)
                    comment(commentPost)
                }
            }
        }
    }
}
