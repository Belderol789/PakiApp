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

struct FeedPost {
    let paki: Paki
    
    let username: String
    let datePosted: String
    let profilePhoto: String?
    
    let title: String
    let content: String
    
    let commentCount: Int
    let starCount: Int
    let shareCount: Int
}

class UserPost: Object {
    @objc dynamic var paki: String!
    @objc dynamic var username: String!
    @objc dynamic var datePosted: String!
    @objc dynamic var profilePhoto: String?
    
    @objc dynamic var title: String!
    @objc dynamic var content: String!
    
    @objc dynamic var commentCount: Int = 0
    @objc dynamic var starCount: Int = 0
    @objc dynamic var shareCount: Int = 0
}
