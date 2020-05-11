//
//  ReplyViewController.swift
//  Paki
//
//  Created by Kem Belderol on 4/24/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import TransitionButton

class ReplyVC: GeneralViewController {
    // IBOutlets
    @IBOutlet weak var titleContainer: ViewX!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var replyTextView: UITextView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var sendButton: TransitionButton!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var replyContainer: ViewX!
    // Constraints
    @IBOutlet weak var replyContainerHeightConst: NSLayoutConstraint!
    @IBOutlet weak var titleConst: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userPakiIcon: UIImageView!
    
    var currentPost: UserPost!
    var sendButtonInteraction: Bool = false {
        didSet {
            sendButton.isUserInteractionEnabled = sendButtonInteraction
            let color: UIColor = sendButtonInteraction ? UIColor.defaultPurple : .systemGray2
            let textColor: UIColor = sendButtonInteraction ? .label : .lightGray
            sendButton.setTitleColor(textColor, for: .normal)
            sendButton.backgroundColor = color
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleContainer.backgroundColor = UIColor.defaultFGColor
        replyContainer.backgroundColor = UIColor.defaultBGColor
        view.backgroundColor = UIColor.defaultBGColor
        
        postLabel.text = currentPost.title
        usernameLabel.text = currentPost.username
        userPakiIcon.image = UIImage(named: currentPost.paki)
        
        replyTextView.delegate = self
        replyTextView.becomeFirstResponder()
        
        let postColor = UIColor.getColorFor(paki: currentPost.pakiCase)
        dividerView.backgroundColor = postColor
        
        let titleHeight = currentPost.title.returnStringHeight(fontSize: 20, width: (view.frame.width - 40)).height
        let postHeight = titleHeight > 80 ? titleHeight : 80
        titleConst.constant = postHeight + 20
        
    }
    
    @IBAction func didSendReply(_ sender: TransitionButton) {
        if replyTextView.text != "" {
            sender.startAnimation()
            FirebaseManager.Instance.sendUserComment(text: replyTextView.text, post: currentPost) { (message) in
                sender.stopAnimation()
                if let message = message {
                    self.showAlertWith(title: "Error", message: message, actions: [], hasDefaultOK: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ReplyVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = textView.text.count
        let textHeight = textView.text.returnStringHeight(fontSize: 17, width: replyContainer.frame.width).height
        print("TextViewHeight \(textHeight)")
        
        replyContainerHeightConst.constant = textHeight > 200 ? textHeight + 20 : 220
        
        self.sendButtonInteraction = (currentCount <= 300 && currentCount > 0) && (textView.text != "")
        self.limitLabel.text = "\(currentCount)/300"
    }
    
}
