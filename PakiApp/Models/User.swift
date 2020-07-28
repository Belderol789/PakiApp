//
//  User.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/29/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    @objc dynamic var uid: String?
    @objc dynamic var username: String = "Anonymous"
    @objc dynamic var dateCreated: String = "\(Date().timeIntervalSince1970)"
    @objc dynamic var birthday: String?
    @objc dynamic var profilePhotoURL: String?
    @objc dynamic var coverPhotoURL: String?
    @objc dynamic var email: String?
    @objc dynamic var currentPaki: String?
    @objc dynamic var number: String?
    
    var pakiCase: Paki {
        return Paki(rawValue: currentPaki ?? "none")!
    }
    
    var dateStarted: Double {
        return Double(dateCreated)!
    }
    
    var starCount: Int {
        return starList.count
    }
    
    let blockedList = List<String>()
    let starList = List<String>()
    var userPosts = List<UserPost>()
}
