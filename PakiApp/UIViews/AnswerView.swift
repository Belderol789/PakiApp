//
//  AnswerView.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import TTGEmojiRate

protocol AnswerViewProtocol: class {
    func didFinishAnswer()
}

class AnswerView: UIView, Reusable, UITextViewDelegate {
    
    @IBOutlet weak var instLabel: UILabel!
    @IBOutlet weak var howAreYouLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emojiView: EmojiRateView!
    @IBOutlet weak var pakiButton: ButtonX!
    @IBOutlet weak var shareButton: ButtonX!
    
    @IBOutlet weak var awesomeIcon: UIImageView!
    @IBOutlet weak var goodIcon: UIImageView!
    @IBOutlet weak var mehIcon: UIImageView!
    @IBOutlet weak var badIcon: UIImageView!
    @IBOutlet weak var terribleIcon: UIImageView!
    @IBOutlet weak var statsView: UIView!
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareTextView: UITextView!
    @IBOutlet weak var blurHeightConst: NSLayoutConstraint!
    @IBOutlet weak var shareLimitLabel: UILabel!
    
    weak var delegate: AnswerViewProtocol?
    var currentPaki: Paki = .meh
    
    var shareBtnInternaction: Bool = false {
        didSet {
            shareButton.isUserInteractionEnabled = shareBtnInternaction
            shareButton.alpha = shareBtnInternaction ? 1.0 : 0.5
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = textView.text.count
        self.shareBtnInternaction = (currentCount <= 500 && currentCount > 0)
        self.shareLimitLabel.text = "\(currentCount)/500"
    }
    
    func setupEmojiView() {
        
        shareTextView.delegate = self
        let pakiColor = UIColor.getColorFor(paki: currentPaki)
        
        awesomeIcon.tintColor = UIColor.getColorFor(paki: .awesome)
        goodIcon.tintColor = UIColor.getColorFor(paki: .good)
        mehIcon.tintColor = UIColor.getColorFor(paki: .meh)
        badIcon.tintColor = UIColor.getColorFor(paki: .bad)
        terribleIcon.tintColor = UIColor.getColorFor(paki: .terrible)
        
        emojiView.rateColor = .systemBackground
        pakiButton.backgroundColor = UIColor.tertiarySystemGroupedBackground
        pakiButton.setTitle(currentPaki.rawValue.capitalized, for: .normal)
        
        emojiView.backgroundColor = pakiColor
        emojiView.layer.cornerRadius = 100
        emojiView.rateValueChangeCallback = {(rateValue: Float) -> Void in
            
            switch rateValue {
            case 0...1:
                self.currentPaki = .terrible
            case 1...2:
                self.currentPaki = .bad
            case 2...3:
                self.currentPaki = .meh
            case 3...4:
                self.currentPaki = .good
            case 4...5:
                self.currentPaki = .awesome
            default:
                break
            }
            
            let pakiColor = UIColor.getColorFor(paki: self.currentPaki)
            
            self.pakiButton.setTitle(self.currentPaki.rawValue.capitalized, for: .normal)
            self.emojiView.backgroundColor = pakiColor
            self.emojiView.rateColor = .systemBackground
        }
    }
 
    @IBAction func didSelectPaki(_ sender: ButtonX) {
        let scrollOffset = self.frame.height/2 - 100
        
        emojiView.isUserInteractionEnabled = false
        scrollView.scrollToDown(height: scrollOffset)
        howAreYouLabel.isHidden = true
        instLabel.isHidden = true
        
        let pakiColor = UIColor.getColorFor(paki: currentPaki)
        shareButton.backgroundColor = pakiColor
        
        UIView.animate(withDuration: 1, animations: {
            self.pakiButton.backgroundColor = pakiColor
            self.pakiButton.setTitleColor(.white, for: .normal)
            self.pakiButton.layer.borderColor = pakiColor.cgColor
        }) { (_) in
            // Show data
            UIView.animate(withDuration: 1) {
                self.statsView.alpha = 1
            }
        }
    }
    
    @IBAction func didContinueToShare(_ sender: ButtonX) {
        statsView.alpha = 0
        scrollView.isHidden = true
        UIView.animate(withDuration: 1, animations: {
            self.shareView.alpha = 1
        }) { (_) in
            self.shareTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func didShare(_ sender: ButtonX) {
        self.removeFromSuperview()
        self.delegate?.didFinishAnswer()
    }
    
}
