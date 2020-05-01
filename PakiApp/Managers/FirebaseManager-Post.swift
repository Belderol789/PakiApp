//
//  FirebaseManager-Post.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/30/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import Firebase

extension FirebaseManager {
    // MARK: - Post Empty
    func sendEmptyPost() {
        guard let userID = DatabaseManager.Instance.mainUser.uid else { return }
        let currentPostTag = DatabaseManager.Instance.mainUser.postTag
        let userPost = UserPost()
        let data: [String: Any] = [FirebaseKeys.username.rawValue: userPost.username,
                                   FirebaseKeys.profilePhotoURL.rawValue: userPost.profilePhotoURL ?? "",
                                   FirebaseKeys.datePosted.rawValue: userPost.datePosted,
                                   FirebaseKeys.title.rawValue: userPost.title,
                                   FirebaseKeys.content.rawValue: userPost.content,
                                   FirebaseKeys.paki.rawValue: userPost.paki,
                                   FirebaseKeys.shareCount.rawValue: userPost.shareCount,
                                   FirebaseKeys.starCount.rawValue: userPost.starCount,
                                   FirebaseKeys.commentCount.rawValue: userPost.commentCount,
                                   FirebaseKeys.uid.rawValue: userID,
                                   FirebaseKeys.postTag.rawValue: (currentPostTag + 1)]
        
        
        self.firestoreDB.collection(Identifiers.userPosts.rawValue).document(userID).collection(Identifiers.userPosts.rawValue).document(userPost.postKey).setData(data, merge: true)
        DatabaseManager.Instance.saveUserPost(post: userPost)
    }
    // MARK: - Post
    func sendPostToFirebase(_ userPost: UserPost) {
        
        guard let userID = DatabaseManager.Instance.mainUser.uid else { return }
        
        var data: [String: Any] = [FirebaseKeys.username.rawValue: userPost.username,
                                   FirebaseKeys.profilePhotoURL.rawValue: userPost.profilePhotoURL ?? "",
                                   FirebaseKeys.datePosted.rawValue: userPost.datePosted,
                                   FirebaseKeys.title.rawValue: userPost.title,
                                   FirebaseKeys.content.rawValue: userPost.content,
                                   FirebaseKeys.paki.rawValue: userPost.paki,
                                   FirebaseKeys.shareCount.rawValue: userPost.shareCount,
                                   FirebaseKeys.starCount.rawValue: userPost.starCount,
                                   FirebaseKeys.commentCount.rawValue: userPost.commentCount,
                                   FirebaseKeys.uid.rawValue: userID]
        
        self.firestoreDB.collection(Identifiers.posts.rawValue).document(userPost.paki).collection(userPost.postKey).document(userID).setData(data, merge: true) { _ in
            
            let currentPostTag = DatabaseManager.Instance.mainUser.postTag
            data[FirebaseKeys.postTag.rawValue] = currentPostTag + 1
            
            self.firestoreDB.collection(Identifiers.userPosts.rawValue).document(userID).collection(Identifiers.userPosts.rawValue).document(userPost.postKey).setData(data, merge: true)
            DatabaseManager.Instance.saveUserPost(post: userPost)
        }
    }
    // MARK: - Get Feed Post
    func getPostFor(paki: Paki, completed: @escaping (UserPost?) -> Void) {
        
        let postKey = Date().localDate().convertToString(with: "LLLL dd, yyyy").replacingOccurrences(of: " ", with: "")
        
        self.firestoreDB.collection(Identifiers.posts.rawValue).document(paki.rawValue).collection(postKey).getDocuments { (snapshot, error) in
            if error != nil {
                print("Post error \(error!.localizedDescription)")
                completed(nil)
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                for document in documents {
                    let data = document.data()
                    let post = UserPost.convert(data: data)
                    completed(post)
                }
            }
        }
    }
    
    func updatePostCount(key: String, count: Int, post: UserPost) {
        let updatedCount = [key: count]
        self.firestoreDB.collection(Identifiers.posts.rawValue).document(post.paki).collection(post.postKey).document(post.uid).updateData(updatedCount)
        self.firestoreDB.collection(Identifiers.userPosts.rawValue).document(post.uid).collection(Identifiers.userPosts.rawValue).document(post.postKey).updateData(updatedCount)
    }
    
    // MARK: - Get User Posts
    func getUserPosts(completed: @escaping ([UserPost]) -> Void) {
        if let userID = DatabaseManager.Instance.mainUser.uid {
            self.firestoreDB.collection(Identifiers.userPosts.rawValue).document(userID).collection(Identifiers.userPosts.rawValue).getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents, !documents.isEmpty {
                    
                    var userPosts = [UserPost]()
                    
                    for document in documents {
                        let data = document.data()
                        let userPost = UserPost.convert(data: data)
                        userPosts.append(userPost)
                    }
                    
                    completed(userPosts)
                    
                }
            }
        }
    }
}
