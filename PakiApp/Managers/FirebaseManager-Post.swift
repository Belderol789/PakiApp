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
    
    // MARK: - Update Paki Count
    func getAllPakiCount(data: @escaping ([String: Any]) -> Void) {
        let postKey = Date().convertToString(with: "LLLL dd, yyyy").replacingOccurrences(of: " ", with: "")
        print("PakiCountPostCount \(postKey)")
        self.firestoreDB.collection(Identifiers.pakiCount.rawValue).document(postKey).getDocument { (snapshot, error) in
            if let snapshotData = snapshot?.data() {
                print("PakiCount Data \(snapshotData)")
                data(snapshotData)
            }
        }
    }
    
    func setupPakiCount(count: [String: Any]) {
        let postKey = Date().convertToString(with: "LLLL dd, yyyy").replacingOccurrences(of: " ", with: "")
        self.firestoreDB.collection(Identifiers.pakiCount.rawValue).document(postKey).setData(count, merge: true)
    }
    
    func setPakiCount(countData: [String: Any]) {
        let postKey = Date().convertToString(with: "LLLL dd, yyyy").replacingOccurrences(of: " ", with: "")
        self.firestoreDB.collection(Identifiers.pakiCount.rawValue).document(postKey).setData(countData)
    }
    
    // MARK: - Post Empty
//    func sendEmptyPost() {
//        guard let userID = DatabaseManager.Instance.mainUser.uid else { return }
//        let userPost = UserPost()
//        let data: [String: Any] = [FirebaseKeys.username.rawValue: userPost.username,
//                                   FirebaseKeys.profilePhotoURL.rawValue: userPost.profilePhotoURL ?? "",
//                                   FirebaseKeys.datePosted.rawValue: userPost.datePosted,
//                                   FirebaseKeys.title.rawValue: userPost.title,
//                                   FirebaseKeys.content.rawValue: userPost.content,
//                                   FirebaseKeys.paki.rawValue: userPost.paki,
//                                   FirebaseKeys.shareCount.rawValue: userPost.shareCount,
//                                   FirebaseKeys.starCount.rawValue: userPost.starCount,
//                                   FirebaseKeys.commentCount.rawValue: userPost.commentCount,
//                                   FirebaseKeys.uid.rawValue: userID,
//                                   FirebaseKeys.reportCount.rawValue: 0]
//
//        self.firestoreDB.collection(Identifiers.userPosts.rawValue).document(userID).collection(Identifiers.userPosts.rawValue).document(userPost.postKey).setData(data, merge: true)
//        DatabaseManager.Instance.savePost(post: userPost)
//    }
    // MARK: - Post
    func sendPostToFirebase(_ userPost: UserPost) {
        
        guard let userID = DatabaseManager.Instance.mainUser.uid else { return }
        
        let uniquePostID: String = UUID().uuidString
        let data: [String: Any] = [FirebaseKeys.username.rawValue: userPost.username,
                                   FirebaseKeys.profilePhotoURL.rawValue: userPost.profilePhotoURL ?? "",
                                   FirebaseKeys.datePosted.rawValue: userPost.datePosted,
                                   FirebaseKeys.title.rawValue: userPost.title,
                                   FirebaseKeys.content.rawValue: userPost.content,
                                   FirebaseKeys.paki.rawValue: userPost.paki,
                                   FirebaseKeys.shareCount.rawValue: userPost.shareCount,
                                   FirebaseKeys.starList.rawValue: Array(userPost.starList),
                                   FirebaseKeys.commentCount.rawValue: userPost.commentCount,
                                   FirebaseKeys.postID.rawValue: uniquePostID,
                                   FirebaseKeys.postKey.rawValue: userPost.postKey,
                                   FirebaseKeys.commentKey.rawValue: userPost.commentKey!,
                                   FirebaseKeys.uid.rawValue: userID,
                                   FirebaseKeys.reportCount.rawValue: 0]
        
        if !userPost.postPrivate {
            self.firestoreDB.collection(Identifiers.posts.rawValue).document(userPost.postKey).collection(userPost.postKey).document(uniquePostID).setData(data, merge: true)
        }
        
        self.firestoreDB.collection(Identifiers.userPosts.rawValue).document(userID).collection(Identifiers.userPosts.rawValue).document(uniquePostID).setData(data, merge: true)
        DatabaseManager.Instance.savePost(post: userPost)
    }
    // MARK: - Get Feed Post
    func getAllPostFor(completed: @escaping ([UserPost]?) -> Void) {
        
        let postKey = Date().convertToString(with: "LLLL dd, yyyy").replacingOccurrences(of: " ", with: "")
        print("Getting Post with key \(postKey)")
        let blockedList = DatabaseManager.Instance.mainUser.blockedList
        self.firestoreDB.collection(Identifiers.posts.rawValue).document(postKey).collection(postKey).getDocuments { (snapshot, error) in
            if error != nil {
                print("Post error \(error!.localizedDescription)")
                completed(nil)
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                var userPosts: [UserPost] = []
                for document in documents {
                    let data = document.data()
                    let post = UserPost.convert(data: data)
                    if !blockedList.contains(post.userUID) {
                        userPosts.append(post)
                    }
                    print("User blockedList \(blockedList) uid \(post.userUID)")
                }
                completed(userPosts)
            } else {
                completed(nil)
            }
        }
    }
    
    // MARK: - Get User Posts
    func getUserPosts(userID: String, completed: @escaping ([UserPost]) -> Void) {
        self.firestoreDB.collection(Identifiers.userPosts.rawValue).document(userID).collection(Identifiers.userPosts.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                print("Calendar error \(error.localizedDescription)")
            } else if let documents = snapshot?.documents {
                
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
    
    // MARK: - Update Post Data
    func updatePostsStar(userPost: UserPost) {
        guard let userID = DatabaseManager.Instance.mainUser.uid else { return }
        self.firestoreDB.collection(Identifiers.posts.rawValue).document(userPost.postKey).collection(userPost.postKey).document(userPost.userUID).updateData([FirebaseKeys.starList.rawValue: FieldValue.arrayUnion([userID])])
    }
    
    func reportPost(post: UserPost) {
        let updatedData: [String: Any] = [FirebaseKeys.reportCount.rawValue: post.reportCount + 1]
        if post.reportCount + 1 < 10 {
            self.firestoreDB.collection(Identifiers.posts.rawValue).document(post.postKey).collection(post.paki).document(post.userUID).updateData(updatedData)
        } else {
            self.firestoreDB.collection(Identifiers.posts.rawValue).document(post.postKey).collection(post.paki).document(post.userUID).delete()
        }
        reportUserWith(uid: post.userUID)
    }
    
    // MARK: - Image Upload
    func saveImagesToStorage(images: [UIImage], completed: @escaping ([String]) -> Void) {
        let imageData: [Data] = images.map({return $0.compressTo(1)!})
        
        var photoURLs: [String] = []

        for datum in imageData {
            let storageRef = Storage.storage().reference().child(Identifiers.posts.rawValue).child("\(UUID().uuidString).jpg")
            
            storageRef.putData(datum, metadata: nil) { (metaData, error) in
                if error == nil {
                    storageRef.downloadURL(completion: { (url, err) in
                        if let photoURL = url?.absoluteString {
                            photoURLs.append(photoURL)
                            if photoURLs.count == images.count {
                                completed(photoURLs)
                            }
                        }
                    })
                }
            }
        }
    }
    
}
