//
//  TestManager.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/10/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class TestManager {
    
    static func getComments() -> [UserPost] {
        let firstComment = UserPost()
        firstComment.paki = "bad"
        firstComment.username = "youngblood"
        firstComment.starList.append(objectsIn: ["hello world", "haha", "asjghjsag", "sigjai"])
        firstComment.content = "Congrats! That does sound awesome when all your hardwork FINALLY pays off"
        
        let secondComment = UserPost()
        secondComment.paki = "meh"
        secondComment.username = "bballer23"
        secondComment.starList.append(objectsIn: ["sgasga"])
        secondComment.content = "Woah congrats! Getting that bread $$$"
        return [firstComment, secondComment]
    }
    
    static func getUserPosts() -> [UserPost] {
        
        let originPost = UserPost()
        originPost.paki = Paki.awesome.rawValue
        originPost.username = "aloecera"
        originPost.uid = "skjgas"
        originPost.datePosted = Date().tomorrow.timeIntervalSince1970
        originPost.title = "Got a promotion today!"
        originPost.content = "I'm sooooo happy! If you've been following my posts, you guys know my days have been riddled with bad and terrible days, but today things finally paid off and I feel awesome!"
        originPost.profileImage = UIImage(named: "model0")
        originPost.starList.append(objectsIn: ["kjgas", "skjgas", "skjgaks", "kgjakdgjad", "skgjadg", "skgasjg"])
        
        let zeroPost = UserPost()
        zeroPost.paki = Paki.bad.rawValue
        zeroPost.username = "supermodelqueen"
        zeroPost.datePosted = Date().tomorrow.timeIntervalSince1970
        zeroPost.title = "In the veterinarian's clinic right now :("
        zeroPost.content = "Sushi got sick and so today I'm just feeling really down. I've been with her for 3 hours now getting her checked up. I hope it doesn't turn out to be anything terrible."
        zeroPost.profileImage = UIImage(named: "model")
    
        let firstPost = UserPost()
        firstPost.paki = Paki.meh.rawValue
        firstPost.username = "AnimeGuru"
        firstPost.uid = "kjgas"
        firstPost.datePosted = Date().tomorrow.timeIntervalSince1970
        firstPost.title = "Stayed Home"
        firstPost.content = "All I did today was stay home. No hangouts, no meetups, no money to spend, just stayed home watching a few animes and playing video games. I need more friends :("
        firstPost.profileImage = UIImage(named: "model1")
        firstPost.starList.append(objectsIn: ["kjgas", "skjgas", "skjgaks", "kgjakdgjad"])
        
        let thirdPost = UserPost()
        thirdPost.paki = Paki.awesome.rawValue
        thirdPost.username = "manbat"
        thirdPost.uid = "skjgas"
        thirdPost.datePosted = Date().tomorrow.timeIntervalSince1970
        thirdPost.title = "Finally went to the gym!"
        thirdPost.content = "I've always put off going to the gym for many, many excuses, but today I just felt like actually going. So I did. Feel get about working out and feel better about myself. DEFINITELY going to do it again!"
        thirdPost.starList.append(objectsIn: ["kjgas", "skjgas", "skjgaks", "kgjakdgjad", "skgjadg", "skgasjg"])
        
        let fourthPost = UserPost()
        fourthPost.paki = Paki.awesome.rawValue
        fourthPost.username = "thelazypotato"
        fourthPost.uid = "skjgas"
        fourthPost.datePosted = Date().tomorrow.timeIntervalSince1970
        fourthPost.title = "Found old photos!"
        fourthPost.content = "I decided to clean my room today and found old photos of myself and parents. I was so freaking cute before (even now I think!), but today felt awesome looking through memories like that :)"
        fourthPost.starList.append(objectsIn: ["kjgas", "skjgas", "skjgaks", "kgjakdgjad", "skgjadg", "skgasjg"])
        
        let fifthPost = UserPost()
        fifthPost.paki = Paki.good.rawValue
        fifthPost.username = "aloecera"
        fifthPost.uid = "skjgas"
        fifthPost.datePosted = Date().tomorrow.timeIntervalSince1970
        fifthPost.title = "Got a promotion today!"
        fifthPost.content = "I'm sooooo happy! If you've been following my posts, you guys know my days have been riddled with bad and terrible days, but today things finally paid off and I feel awesome!"
        fifthPost.starList.append(objectsIn: ["kjgas", "skjgas", "skjgaks", "kgjakdgjad", "skgjadg", "skgasjg"])
        
        
        return [originPost, firstPost, zeroPost, thirdPost, fourthPost, fifthPost]
    }
    
    static func returnCalendarUserPosts() -> [UserPost] {
        var userPosts: [UserPost] = []
        for _ in 0..<50 {
            let post = UserPost()
            post.paki = returnRandomPaki().rawValue
            userPosts.append(post)
        }
        return userPosts
    }
    
    static func returnRandomPaki() -> Paki {
        let paki: [Paki] = [.all, .awesome, .good, .meh, .bad, .terrible]
        return paki[Int(arc4random_uniform(UInt32(paki.count)))]
    }
}
