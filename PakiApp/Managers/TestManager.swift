//
//  TestManager.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/10/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import Foundation

class TestManager {
    
    static func returnCommentPosts() -> [UserPost] {
        
        let originPost = UserPost()
        originPost.paki = Paki.awesome.rawValue
        originPost.username = "Username"
        originPost.datePosted = Date().tomorrow.timeIntervalSince1970
        originPost.title = "Hello World"
        originPost.content = "sklngaksjgnakhgaskhugbaehkugb aehgkuae gaegkuaeb gkusbfr wuf wbeg kuwbguiyrbg w uegh weu ghe"
        originPost.postTag = 0
        
        let zeroPost = UserPost()
        zeroPost.paki = Paki.awesome.rawValue
        zeroPost.username = "Username"
        zeroPost.datePosted = Date().tomorrow.timeIntervalSince1970
        zeroPost.title = "Hello World"
        zeroPost.content = "sklngaksjgnakhgaskhugbaehkugb aehgkuae gaegkuaeb gkusbfr wuf wbeg kuwbguiyrbg w uegh weu ghe"
        zeroPost.postTag = 0
        
        let firstPost = UserPost()
        firstPost.paki = Paki.awesome.rawValue
        firstPost.username = "Username"
        firstPost.datePosted = Date().tomorrow.timeIntervalSince1970
        firstPost.title = "Hello World"
        firstPost.content = "sklngaksjgnakhgaskhugbaehkugb aehgkuae gaegkuaeb gkusbfr wuf wbeg kuwbguiyrbg w uegh weu ghe"
        firstPost.postTag = 0
        
        let secondPost = UserPost()
        secondPost.paki = Paki.good.rawValue
        secondPost.username = "Username"
        secondPost.datePosted = Date().yesterday.timeIntervalSince1970
        secondPost.title = "Hello World"
        secondPost.content = "sklngaksjgnakhgaskhugbaehkugb"
        secondPost.postTag = 1
        
        let thirdPost = UserPost()
        thirdPost.paki = Paki.meh.rawValue
        thirdPost.username = "Username"
        thirdPost.datePosted = Date().tomorrow.timeIntervalSince1970
        thirdPost.title = "Hello World kajsgnlkjasngijangkjaengkaeglaeijgnaieljgnjea"
        thirdPost.content = "sklngaksjgnakhgaskhugbaehkugb aehgkuae gaegkuaeb gkusbfr wuf wbeg kuwbguiyrbg w uegh weu ghe kajshgljangliengliueangiluagniargnaeignaliejgneligneaignaegliuaengliaengljaengaegaekgjengje"
        thirdPost.postTag = 2
        
        let fourthPost = UserPost()
        fourthPost.paki = Paki.bad.rawValue
        fourthPost.username = "Username"
        fourthPost.datePosted = Date().tomorrow.timeIntervalSince1970
        fourthPost.title = "Hello World"
        fourthPost.content = "sklngaksjgnakhgaskhugbaehkugb aehgkuae gaegkuaeb gkusbfr wuf wbeg kuwbguiyrbg w uegh weu ghe"
        fourthPost.postTag = 3
        
        let fifthPost = UserPost()
        fifthPost.paki = Paki.terrible.rawValue
        fifthPost.username = "Username"
        fifthPost.datePosted = Date().yesterday.timeIntervalSince1970
        fifthPost.title = "Hello"
        fifthPost.content = "skln"
        fifthPost.postTag = 4
        
        return [originPost, secondPost, zeroPost, thirdPost, firstPost, fourthPost, fifthPost]
    }
    
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
