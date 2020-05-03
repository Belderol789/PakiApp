//
//  ReplyViewController.swift
//  Paki
//
//  Created by Kem Belderol on 4/24/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class ReplyVC: GeneralViewController {
    // IBOutlets
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var replyTextView: UITextView!
    @IBOutlet weak var postLabel: UILabel!
    
    var currentPost: UserPost!

    override func viewDidLoad() {
        super.viewDidLoad()
        postLabel.text = currentPost.title
        replyTextView.becomeFirstResponder()
        
        let postColor = UIColor.getColorFor(paki: currentPost.pakiCase)
        dividerView.backgroundColor = postColor
    }
    
    @IBAction func didSendReply(_ sender: UIButton) {
        
    }

    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
