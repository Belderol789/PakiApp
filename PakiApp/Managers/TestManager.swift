//
//  TestManager.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/10/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation

class TestManager {
    
    static func returnCalendarUserPosts() -> [UserPost] {
        var userPosts: [UserPost] = []
        for i in 0..<50 {
            let post = UserPost()
            post.paki = returnRandomPaki().rawValue
            post.postTag = i
            userPosts.append(post)
        }
        return userPosts
    }
    
    static func returnRandomPaki() -> Paki {
        let paki: [Paki] = [.all, .awesome, .good, .meh, .bad, .terrible]
        return paki[Int(arc4random_uniform(UInt32(paki.count)))]
    }
}
