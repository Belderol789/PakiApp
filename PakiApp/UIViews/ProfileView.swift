//
//  ProfileView.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileView: UIView, Reusable {

    @IBOutlet weak var profilePhoto: ImageViewX!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    var user: User!
    
    @IBAction func didRemove(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    func setupProfile(user: UserPost) {
        if let photo = user.profilePhotoURL {
            profilePhoto.sd_setImage(with: URL(string: photo), completed: nil)
        }
        usernameLabel.text = user.username
        
        FirebaseManager.Instance.getUserPosts(userID: user.userUID) { (userPosts) in
            let width = self.frame.width / 10
            
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            for post in userPosts {
                if x == 10 {
                    x = 0
                    y += 1
                }
                
                let pakiView = PakiView()
                
                pakiView.setupView(with: post)
                pakiView.frame = CGRect(x: x * width, y: y * width, width: width, height: width)
                pakiView.layer.borderColor = UIColor.white.cgColor
                pakiView.layer.borderWidth = 0.5
                self.containerView.addSubview(pakiView)

                x += 1
            }
        }
    }
}
