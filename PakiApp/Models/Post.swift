//
//  Post.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import RealmSwift

enum Paki: String {
    case all
    case none
    case awesome
    case good
    case meh
    case bad
    case terrible
}

class UserPost: Object {
    
    @objc dynamic var uniquePostKey: String = ""
    
    @objc dynamic var paki: String = Paki.none.rawValue
    @objc dynamic var username: String = ""
    @objc dynamic var datePosted: Double = 0
    @objc dynamic var profilePhotoURL: String?
    @objc dynamic var uid: String = ""
    
    @objc dynamic var title: String = ""
    @objc dynamic var content: String = ""
    
    @objc dynamic var commentKey: String?
    @objc dynamic var commentID: String?
    @objc dynamic var commentCount: Int = 0
    @objc dynamic var shareCount: Int = 0
    
    @objc dynamic var postKey: String = ""
    
    var starList = List<String>()
    var starCount: Int {
        return starList.count
    }
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: datePosted)
        return date.convertToMediumString()
    }
    
    var pakiCase: Paki {
        return Paki(rawValue: self.paki) ?? .none
    }
    
    var photoURL: URL? {
        if let profilePhotoURL = profilePhotoURL {
            return URL(string: profilePhotoURL)
        }
        return nil
    }
    
    static func convert(data: [String: Any]) -> UserPost {
        let userPost = UserPost()
        userPost.postKey = data[FirebaseKeys.postKey.rawValue] as? String ?? ""
        userPost.username = data[FirebaseKeys.username.rawValue] as? String ?? ""
        userPost.paki = data[FirebaseKeys.paki.rawValue] as? String ?? ""
        userPost.datePosted = data[FirebaseKeys.datePosted.rawValue] as? Double ?? Date().timeIntervalSinceNow
        userPost.profilePhotoURL = data[FirebaseKeys.profilePhotoURL.rawValue] as? String
        userPost.uid = data[FirebaseKeys.uid.rawValue] as? String ?? ""
        
        userPost.content = data[FirebaseKeys.content.rawValue] as? String ?? ""
        userPost.title = data[FirebaseKeys.title.rawValue] as? String ?? ""
        
        userPost.commentKey = data[FirebaseKeys.commentKey.rawValue] as? String
        userPost.commentID = data[FirebaseKeys.commentID.rawValue] as? String
        userPost.commentCount = data[FirebaseKeys.commentCount.rawValue] as? Int ?? 0
        if let stars = data[FirebaseKeys.starList.rawValue] as? [String] {
            userPost.starList.append(objectsIn: stars)
        }
        userPost.shareCount = data[FirebaseKeys.shareCount.rawValue] as? Int ?? 0
        return userPost
    }
    
}
