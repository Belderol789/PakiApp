//
//  ReplyViewController.swift
//  Paki
//
//  Created by Kem Belderol on 4/24/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class ReplyViewController: UIViewController {
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var replyTextView: UITextView!
    
    var currentPaki: Paki!

    override func viewDidLoad() {
        super.viewDidLoad()
        dividerView.backgroundColor = UIColor.getColorFor(paki: currentPaki)
        replyTextView.becomeFirstResponder()
        
    }

    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
