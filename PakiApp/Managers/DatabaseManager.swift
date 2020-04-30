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
}
typealias EmptyClosure = () -> Void
class DatabaseManager {
    // MARK: - Realm Variables
    private static let _instance = DatabaseManager()
    static var Instance: DatabaseManager {
        return _instance
    }
    var realm: Realm = try! Realm()
    
    var mainUser: User? {
        return realm.objects(User.self).first
    }
    
    func saveUserData(_ data: [String: Any], completed: EmptyClosure) {
        data.forEach { (_ key: String, _ value: Any) in
            do {
                try self.realm.write {
                    mainUser?[key] = value
                }
            } catch {
                
            }
        }
        
        do {
            try self.realm.write {
                self.realm.add(mainUser!)
                completed()
            }
        } catch {
            print("Could not add user")
        }
        
    }
    
    // MARK: - UserDefaults
    var userIsLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: DatabaseKeys.userIsLoggedIn.rawValue)
    }
    
    var userHasAnswered: Bool {
        return UserDefaults.standard.bool(forKey: DatabaseKeys.userHasAnswered.rawValue)
    }
    
    func updateUserDefaults(value: Any, key: DatabaseKeys) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
    
}
