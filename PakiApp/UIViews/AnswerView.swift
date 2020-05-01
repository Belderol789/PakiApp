//
//  AnswerView.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import TTGEmojiRate
import SkyFloatingLabelTextField

protocol AnswerViewProtocol: class {
    func didFinishAnswer()
}

class AnswerView: UIView, Reusable {
    
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
    @IBOutlet weak var shareTitleField: SkyFloatingLabelTextField!
    
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
    
    func setupEmojiView() {
        
        shareTextView.delegate = self
        shareTitleField.delegate = self
        let pakiColor = UIColor.getColorFor(paki: currentPaki)
        shareTitleField.placeholder = "Title"
        
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
        shareTitleField.selectedTitleColor = pakiColor
        shareTitleField.selectedLineColor = pakiColor
        
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
            self.shareTitleField.becomeFirstResponder()
        }
    }
    
    @IBAction func didShare(_ sender: ButtonX) {
        
        let mainUser = DatabaseManager.Instance.mainUser
        let userPost: UserPost = UserPost()
        
        userPost.username = mainUser.username
        userPost.paki = currentPaki.rawValue
        userPost.profilePhotoURL = mainUser.profilePhotoURL
        userPost.content = shareTextView.text
        userPost.title = shareTitleField.text ?? "N/A"
        
        let datePosted = Date().localDate().convertToString(with: "LLLL dd, yyyy")
        userPost.datePosted = datePosted
        userPost.starCount = 1
        
        FirebaseManager.Instance.sendPostToFirebase(userPost)
        
        self.delegate?.didFinishAnswer()
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

// MARK: - AnwerFields
extension AnswerView: UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            shareLimitLabel.isHidden = false
            shareTextView.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            shareLimitLabel.isHidden = false
            shareTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textCount = returnTextCount(textField: textField, string: string, range: range, count: 100)
        shareTitleField.selectedTitle = "\(textCount)/100"
        self.shareBtnInternaction = (shareTextView.text.count <= 500 && shareTextView.text.count > 0) && (shareTitleField.text != "")
        return textCount < 100
    }
    
    func returnTextCount(textField: UITextField, string: String, range: NSRange, count: Int) -> Int {
           let currentText = textField.text ?? ""
           guard let stringRange = Range(range, in: currentText) else { return 0 }
           let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
           return updatedText.count
       }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = textView.text.count
        self.shareBtnInternaction = (currentCount <= 500 && currentCount > 0) && (shareTitleField.text != "")
        self.shareLimitLabel.text = "\(currentCount)/500"
    }
}
