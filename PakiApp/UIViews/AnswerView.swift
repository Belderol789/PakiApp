//
//  AnswerView.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import TTGEmojiRate
import OpalImagePicker

protocol AnswerViewProtocol: class {
    func didCancelAnswer()
    func didFinishAnswer(post: UserPost)
    func presentImageController(_ controller: UIImagePickerController)
}

class AnswerView: UIView, Reusable {
    
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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadingVIew: LoadingView!
    @IBOutlet var headerLabels: [UILabel]!
    
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var pakiIcon: UIImageView!
    @IBOutlet weak var pakiName: LabelX!
    
    weak var delegate: AnswerViewProtocol?
    var currentPaki: Paki = .meh
    var pakiData: [String: Any] = [:]
    var photos: [UIImage] = []
    
    var togglePrivacy: Bool = false {
        didSet {
            privacyLabel.text = togglePrivacy ? "Public" : "Personal"
        }
    }
    
    var shareBtnInternaction: Bool = false {
        didSet {
            shareButton.isUserInteractionEnabled = shareBtnInternaction
            shareButton.alpha = shareBtnInternaction ? 1.0 : 0.5
            shareButton.backgroundColor = shareBtnInternaction ? UIColor.defaultPurple : UIColor.lightGray
        }
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
        
        scrollView.alpha = 0
        self.backgroundColor = UIColor.defaultBGColor
        
        privacySwitch.isOn = togglePrivacy
        
//        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
//            layout.delegate = self
//            collectionView.register(ImageCollectionCell.nib, forCellWithReuseIdentifier: ImageCollectionCell.className)
//            collectionView.delegate = self
//            collectionView.dataSource = self
//            collectionView.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
//        }
//        collectionView.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        shareView.addGestureRecognizer(tapGesture)
        
        shareView.backgroundColor = UIColor.defaultBGColor
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
    
    func stopLoading() {
        self.loadingVIew.stopLoading()
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    func didSharePost() {
        loadingVIew.startLoading()
        
        let mainUser = DatabaseManager.Instance.mainUser
        let userPost: UserPost = UserPost()
        let postKey = Date().convertToString(with: "LLLL dd, yyyy").replacingOccurrences(of: " ", with: "")
        
        userPost.username = mainUser.username
        userPost.paki = currentPaki.rawValue
        userPost.profilePhotoURL = mainUser.profilePhotoURL
        userPost.content = shareTextView.text
        userPost.title = titleTextView.text ?? "N/A"
        userPost.commentKey = UUID().uuidString
        userPost.datePosted = Date().timeIntervalSince1970
        if let mainUID = mainUser.uid {
            userPost.starList.append(mainUID)
        }
        
        userPost.postKey = postKey
        userPost.postPrivate = !togglePrivacy
        
        self.delegate?.didFinishAnswer(post: userPost)
        
        /*
        if photos.isEmpty {
            
        } else {
            FirebaseManager.Instance.saveImagesToStorage(images: photos) { (photoURLs) in
                userPost.mediaURLs.append(objectsIn: photoURLs)
                FirebaseManager.Instance.sendPostToFirebase(userPost)
                self.delegate?.didFinishAnswer(post: userPost)
                self.stopLoading()
            }
        }
        */
        
        DatabaseManager.Instance.updateRealm(key: FirebaseKeys.currentPaki.rawValue, value: currentPaki.rawValue)
        DatabaseManager.Instance.updateUserDefaults(value: postKey, key: .userHasAnswered)
        
        if mainUser.uid != nil && DatabaseManager.Instance.userIsLoggedIn {
            let count = self.pakiData[currentPaki.rawValue] as? Int ?? 0
            pakiData[currentPaki.rawValue] = count + 1
            FirebaseManager.Instance.setupPakiCount(count: pakiData)
            FirebaseManager.Instance.sendPostToFirebase(userPost)
        } else {
            DatabaseManager.Instance.savePost(post: userPost)
        }
        
        self.removeFromSuperview()
    }
    
    @IBAction func didSelectPaki(_ sender: ButtonX) {
        sender.isUserInteractionEnabled = false
        
        emojiView.isUserInteractionEnabled = false
        
        let pakiColor = UIColor.getColorFor(paki: currentPaki)
        pakiName.backgroundColor = pakiColor
        pakiName.text = currentPaki.rawValue.capitalized
        pakiIcon.image = UIImage(named: currentPaki.rawValue)
        
        UIView.animate(withDuration: 1, animations: {
            self.pakiButton.backgroundColor = pakiColor
            self.pakiButton.setTitleColor(.white, for: .normal)
            self.pakiButton.layer.shadowColor = UIColor.darkGray.cgColor
        }) { (_) in
            // Show data
            UIView.animate(withDuration: 1.5) {
                self.headerLabels.forEach({$0.alpha = 0})
                self.pakiButton.alpha = 0
                self.emojiView.alpha = 0
                self.statsView.alpha = 1
            }
        }
    }
    
    @IBAction func didTogglePrivacy(_ sender: UISwitch) {
        togglePrivacy = sender.isOn
    }
    

    @IBAction func didContinueToShare(_ sender: ButtonX) {
        scrollView.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.statsView.alpha = 0
            self.scrollView.alpha = 1
        }) { (_) in
            self.blurView.isHidden = true
            self.titleTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func didShare(_ sender: ButtonX) {
        didSharePost()
        self.endEditing(true)
    }

    @IBAction func didTapCancel(_ sender: UIButton) {
        self.delegate?.didCancelAnswer()
        self.removeFromSuperview()
    }
    
//    fileprivate func openImageOptions(type: UIImagePickerController.SourceType) {
//        let pickerController = UIImagePickerController()
//        pickerController.delegate = self
//        pickerController.allowsEditing = true
//        pickerController.mediaTypes = ["public.image"]
//        pickerController.sourceType = type
//        delegate?.presentImageController(pickerController)
//    }
    
//    fileprivate func reloadImageColletion() {
//        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
//            layout.cache.removeAll()
//            layout.prepare()
//            collectionView.reloadData()
//        }
//    }
    
}
// MARK - ImagePickerController
//extension AnswerView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
//
//        if let editedImage = info[.editedImage] as? UIImage {
//            photos.append(editedImage)
//        } else if let originalImage = info[.originalImage] as? UIImage {
//            photos.append(originalImage)
//        }
//
//        reloadImageColletion()
//    }
//}

// MARK: - AnwerFields
extension AnswerView: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == titleTextView {
            shareTextView.becomeFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let limit = textView == titleTextView ? 50 : 500
        return textView.text.count + (text.count - range.length) <= limit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = textView.text.count
        if textView == titleTextView {
            self.titleLimitLabel.text = "\(currentCount)/50"
        } else {
            self.shareLimitLabel.text = "\(currentCount)/500"
        }
        self.shareBtnInternaction = (currentCount <= 500 && currentCount > 0) && (titleTextView.text != "")
    }
}

//extension AnswerView: PinterestLayoutDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, ImageCollectionCellProtocol {
//
//    func didRemoveImage(_ image: UIImage?) {
//        if let index = photos.firstIndex(of: image!) {
//            photos.remove(at: index)
//            collectionView.reloadData()
//        }
//        reloadImageColletion()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return photos.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionCell", for: indexPath as IndexPath) as! ImageCollectionCell
//        cell.imageView.image = photos[indexPath.item]
//        cell.imageView.contentMode = .scaleAspectFill
//        cell.closeButton.isHidden = false
//        cell.imageView.backgroundColor = UIColor.defaultFGColor
//        cell.imageView.layer.cornerRadius = 15
//        cell.imageView.layer.masksToBounds = true
//        cell.delegate = self
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
//        return CGSize(width: itemSize, height: itemSize)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
//        let randomzier = CGFloat.random(in: 250...300)
//        let photoHeight = photos[indexPath.item].size.height > 300 ? randomzier : photos[indexPath.item].size.height
//        print("Photo Height \(photoHeight)")
//        return photoHeight
//    }
//}
