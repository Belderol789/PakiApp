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
    @objc dynamic var username: String?
    @objc dynamic var dateCreated: String = "0"
    @objc dynamic var birthday: String?
    @objc dynamic var profilePhotoURL: String?
    @objc dynamic var email: String?
    @objc dynamic var currentPaki: String?
   
    
    var pakiCase: Paki {
        return Paki(rawValue: currentPaki ?? "none")!
    }
    
    var dateStarted: Double {
        return Double(dateCreated)!
    }
    
    var starCount: Int {
        return starList.count
    }
    
    var starList = List<String>()
    var userPosts = List<UserPost>()
}
