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
    
    func setupProfile(user: User) {
        if let photo = user.profilePhotoURL {
            profilePhoto.sd_setImage(with: URL(string: photo), completed: nil)
        }
        usernameLabel.text = user.username
        
    }

}
