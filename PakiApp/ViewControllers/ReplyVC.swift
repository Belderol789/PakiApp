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
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var replyTextView: UITextView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var sendButton: TransitionButton!
    @IBOutlet weak var limitLabel: UILabel!
    
    var currentPost: UserPost!
    var sendButtonInteraction: Bool = false {
        didSet {
            sendButton.isUserInteractionEnabled = sendButtonInteraction
            let color: UIColor = sendButtonInteraction ? .label : .systemGray2
            sendButton.setTitleColor(color, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        replyTextView.delegate = self
        postLabel.text = currentPost.title
        replyTextView.becomeFirstResponder()
        
        let postColor = UIColor.getColorFor(paki: currentPost.pakiCase)
        dividerView.backgroundColor = postColor
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
        self.sendButtonInteraction = (currentCount <= 300 && currentCount > 0) && (textView.text != "")
        self.limitLabel.text = "\(currentCount)/300"
    }
    
}
