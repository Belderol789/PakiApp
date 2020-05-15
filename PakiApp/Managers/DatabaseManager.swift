//
//  DatabaseManager.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation
import RealmSwift

enum DatabaseKeys: String {
    case userIsLoggedIn
    case userHasAnswered
    case userLightAppearance
    case savedDate
    case allPakis
}

typealias EmptyClosure = () -> Void
typealias BoolClosure = (_ success: Bool) -> Void

class DatabaseManager {
    // MARK: - Realm Variables
    private static let _instance = DatabaseManager()
    static var Instance: DatabaseManager {
        return _instance
    }
    var realm: Realm = try! Realm()
    
    var userObject: Results<User> {
        get {
            return realm.objects(User.self)
        }
    }
    
    var mainUser: User {
        get {
            if let user = self.userObject.first {
                return user
            }
            return User()
        }
    }
    
    func deleteAll() {
        
        self.updateUserDefaults(value: false, key: .userIsLoggedIn)
        
        do {
            try realm.write {
                realm.delete(userObject)
            }
        } catch {
            
        }
    }
    
    func saveUserData(_ data: [String: Any], completed: EmptyClosure) {
        
        do {
            try self.realm.write {
                self.realm.add(mainUser)
                print("User saved to Realm")
                completed()
            }
        } catch {
            print("Could not add user")
        }
        
        data.forEach { (_ key: String, _ value: Any) in
            do {
                try self.realm.write {
                    if key == FirebaseKeys.starList.rawValue, let uid = value as? String {
                        mainUser.starList.append(uid)
                    } else {
                        mainUser[key] = value
                    }
                    
                    print("Saved to Realm \(key) - \(value)")
                }
            } catch {
                
            }
        }
    }
    
    func saveUserPosts(_ posts: [UserPost]) {
        
        var filteredPosts = [UserPost]()
        let userPosts = mainUser.userPosts.map({$0.dateString})
        for post in posts {
            if !userPosts.contains(post.dateString) {
                filteredPosts.append(post)
            }
        }
        
        do {
            try self.realm.write {
                mainUser.userPosts.append(objectsIn: filteredPosts)
                print("Retrieving UserPosts Saved")
            }
        } catch {
            
        }
    }
    
    func updateRealm(key: String, value: Any) {
        do {
            try self.realm.write {
                mainUser[key] = value
                print("Updated success")
            }
        } catch {
            
        }
    }
    
    func savePost(post: UserPost) {
        print("Current Posts \(self.mainUser.userPosts.count)")
        do {
            try self.realm.write {
                self.mainUser.userPosts.append(post)
                print("Updated Posts \(self.mainUser.userPosts.count)")
            }
        } catch {
            print("Could not save user post")
        }
    }
    
    // MARK: - UserDefaults
    var userIsLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: DatabaseKeys.userIsLoggedIn.rawValue)
    }
    
    var userHasAnswered: Bool {
        return UserDefaults.standard.bool(forKey: DatabaseKeys.userHasAnswered.rawValue)
    }
    
    var savedDate: Double? {
        return UserDefaults.standard.value(forKey: DatabaseKeys.savedDate.rawValue) as? Double
    }
    
    var userSetLightAppearance: Bool {
        return UserDefaults.standard.bool(forKey: DatabaseKeys.userLightAppearance.rawValue)
    }
    
    var savedAllPakis: [String] {
        return UserDefaults.standard.value(forKey: DatabaseKeys.allPakis.rawValue) as? [String] ?? []
    }
    
    func updateUserDefaults(value: Any, key: DatabaseKeys) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
    
}
