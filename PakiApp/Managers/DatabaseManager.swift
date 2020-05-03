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
        
        let newUser = userObject.first != nil ? userObject.first! : User()
        
        data.forEach { (_ key: String, _ value: Any) in
            do {
                try self.realm.write {
                    newUser[key] = value
                    print("Saved to Realm \(key) - \(value)")
                }
            } catch {
                
            }
        }
        
        do {
            try self.realm.write {
                self.realm.add(newUser)
                print("User saved to Realm")
                completed()
            }
        } catch {
            print("Could not add user")
        }
    }
    
    func saveUserPosts(_ posts: [UserPost]) {
        do {
            try self.realm.write {
                mainUser.userPosts.removeAll()
                mainUser.userPosts.append(objectsIn: posts)
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
    
    func saveUserPost(post: UserPost) {
        
        let postIndex = self.mainUser.postTag + 1
        post.postTag = postIndex
         
        do {
            try self.realm.write {
                self.mainUser.postTag = postIndex
                self.mainUser.userPosts.append(post)
                print("User posts saved with index \(postIndex)")
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
    
    var userSetLightAppearance: Bool {
        return UserDefaults.standard.bool(forKey: DatabaseKeys.userLightAppearance.rawValue)
    }
    
    func updateUserDefaults(value: Any, key: DatabaseKeys) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
    
}
