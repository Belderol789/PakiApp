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
    func didFinishAnswer(post: UserPost)
}

class AnswerView: UIView, Reusable {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var instLabel: UILabel!
    @IBOutlet weak var howAreYouLabel: UILabel!
    @IBOutlet weak var emojiView: EmojiRateView!
    @IBOutlet weak var pakiButton: ButtonX!
    @IBOutlet weak var shareButton: ButtonX!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var awesomeIcon: UIImageView!
    @IBOutlet weak var goodIcon: UIImageView!
    @IBOutlet weak var mehIcon: UIImageView!
    @IBOutlet weak var badIcon: UIImageView!
    @IBOutlet weak var terribleIcon: UIImageView!
    @IBOutlet weak var statsView: UIView!
    
    @IBOutlet weak var totalPakiLabel: UILabel!
    @IBOutlet weak var awesomeLabel: UILabel!
    @IBOutlet weak var goodLabel: UILabel!
    @IBOutlet weak var mehLabel: UILabel!
    @IBOutlet weak var badLabel: UILabel!
    @IBOutlet weak var terribleLabel: UILabel!
    
    @IBOutlet weak var titleLimitLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareTextView: UITextView!
    @IBOutlet weak var shareLimitLabel: UILabel!
    
    @IBOutlet var headerLabels: [UILabel]!
    
    weak var delegate: AnswerViewProtocol?
    var currentPaki: Paki = .meh
    var pakiData: [String: Any] = [:]
    
    var shareBtnInternaction: Bool = false {
        didSet {
            shareButton.isUserInteractionEnabled = shareBtnInternaction
            shareButton.alpha = shareBtnInternaction ? 1.0 : 0.5
            shareButton.backgroundColor = shareBtnInternaction ? UIColor.defaultPurple : UIColor.lightGray
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc
    func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    func getUpdatedPakiCount() {
        FirebaseManager.Instance.getAllPakiCount { (pakiData) in
            var totalCount: Int = 0
            self.pakiData = pakiData
            for key in pakiData.keys {
                let pakiCount: Int = pakiData[key] as? Int ?? 0
                totalCount += pakiCount
                self.setupPakiLabel(key: key, pakiCount: pakiCount)
            }
            self.totalPakiLabel.text = "\(totalCount)"
        }
    }
    
    func setupPakiLabel(key: String, pakiCount: Int) {
        switch key {
        case Paki.awesome.rawValue:
            self.awesomeLabel.text = "\(pakiCount)"
        case Paki.good.rawValue:
            self.goodLabel.text = "\(pakiCount)"
        case Paki.meh.rawValue:
            self.mehLabel.text = "\(pakiCount)"
        case Paki.bad.rawValue:
            self.badLabel.text = "\(pakiCount)"
        case Paki.terrible.rawValue:
            self.terribleLabel.text = "\(pakiCount)"
        default:
            break
        }
    }
    
    func setupEmojiView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        shareView.addGestureRecognizer(tapGesture)
        
        let dateToday = Date().convertToMediumString()
        dateLabel.text = "\(dateToday)"
        
        shareView.backgroundColor = UIColor.defaultBGColor
        howAreYouLabel.textColor = UIColor.defaultPurple
        shareTextView.delegate = self
        titleTextView.delegate = self
        let pakiColor = UIColor.getColorFor(paki: currentPaki)
        
        awesomeIcon.tintColor = UIColor.getColorFor(paki: .awesome)
        goodIcon.tintColor = UIColor.getColorFor(paki: .good)
        mehIcon.tintColor = UIColor.getColorFor(paki: .meh)
        badIcon.tintColor = UIColor.getColorFor(paki: .bad)
        terribleIcon.tintColor = UIColor.getColorFor(paki: .terrible)
        
        emojiView.rateColor = .black
        pakiButton.backgroundColor = UIColor.darkGray
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
            self.emojiView.rateColor = .black
        }
    }
    
    @IBAction func didSelectPaki(_ sender: ButtonX) {
        sender.isUserInteractionEnabled = false
        
        emojiView.isUserInteractionEnabled = false
        headerLabels.forEach({$0.isHidden = true})
        
        let pakiColor = UIColor.getColorFor(paki: currentPaki)
        
        UIView.animate(withDuration: 1, animations: {
            self.pakiButton.backgroundColor = pakiColor
            self.pakiButton.setTitleColor(.white, for: .normal)
            self.pakiButton.layer.shadowColor = UIColor.darkGray.cgColor
        }) { (_) in
            // Show data
            UIView.animate(withDuration: 1.5) {
                self.pakiButton.alpha = 0
                self.emojiView.alpha = 0
                self.statsView.alpha = 1
            }
        }
    }
    
    @IBAction func didContinueToShare(_ sender: ButtonX) {
        UIView.animate(withDuration: 1, animations: {
            self.statsView.alpha = 0
            self.shareView.alpha = 1
        }) { (_) in
            self.blurView.isHidden = true
            self.titleTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func didShare(_ sender: ButtonX) {
        
        let mainUser = DatabaseManager.Instance.mainUser
        let userPost: UserPost = UserPost()
        
        userPost.username = mainUser.username!
        userPost.paki = currentPaki.rawValue
        userPost.profilePhotoURL = mainUser.profilePhotoURL
        userPost.content = shareTextView.text
        userPost.title = titleTextView.text ?? "N/A"
        
        userPost.commentKey = UUID().uuidString
        userPost.datePosted = Date().timeIntervalSince1970
        userPost.starList.append(mainUser.uid!)
        
        let postKey = Date().convertToString(with: "LLLL dd, yyyy").replacingOccurrences(of: " ", with: "")
        userPost.postKey = postKey
        
        DatabaseManager.Instance.updateRealm(key: FirebaseKeys.currentPaki.rawValue, value: currentPaki.rawValue)
        DatabaseManager.Instance.updateUserDefaults(value: true, key: .userHasAnswered)
        
        let count = self.pakiData[currentPaki.rawValue] as? Int ?? 0
        pakiData[currentPaki.rawValue] = count + 1
        FirebaseManager.Instance.setupPakiCount(count: pakiData)
        FirebaseManager.Instance.sendPostToFirebase(userPost)
        
        self.delegate?.didFinishAnswer(post: userPost)
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

// MARK: - AnwerFields
extension AnswerView: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == titleTextView {
            shareTextView.becomeFirstResponder()
        }
    }
    
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let limit = textView == titleTextView ? 100 : 500
        return textView.text.count + (text.count - range.length) <= limit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = textView.text.count
        if textView == titleTextView {
            self.titleLimitLabel.text = "\(currentCount)/100"
        } else {
            self.shareLimitLabel.text = "\(currentCount)/500"
        }
        self.shareBtnInternaction = (currentCount <= 500 && currentCount > 0) && (titleTextView.text != "")
    }
}
