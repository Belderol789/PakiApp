//
//  TimerViewController.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import MessageUI

class GeneralViewController: UIViewController, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    var isProfile: Bool  = false
    var hideTabbar: Bool = false {
        didSet {
            self.tabBarController?.tabBar.isHidden = hideTabbar
        }
    }
    var navigationBar: Bool = false
    
    var viewCenter: CGRect = .zero
    var currentText: String = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let appearance: UIStatusBarStyle = .lightContent
        return appearance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.defaultBGColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func sendEmail() {
        let email = "krats.apps@gmail.com"
        let emailURLString = "mailto:\(email)"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody("", isHTML: true)
            present(mail, animated: true)
        } else if let emailURL = URL(string: emailURLString), UIApplication.shared.canOpenURL(emailURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(emailURL)
            } else {
                UIApplication.shared.openURL(emailURL)
            }
        } else {
            print("Device unable to send emails")
        }
    }
    
    func setupCountDown() {
        let today = Date()
        let tomorrow = Date().tomorrow
        
        let dateToday = Calendar.current.dateComponents([.year, .month, .day], from: today)
        let dateDifference = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: today, to: tomorrow)
        
        let year = dateToday.year ?? 0
        let month = dateToday.month ?? 0
        let day = dateToday.day ?? 0
        
        var hours = dateDifference.hour ?? 0
        var minutes = dateDifference.minute ?? 0
        var seconds = dateDifference.second ?? 0
        
        var hourText = setupTimeWith(value: hours)
        var minuteText = setupTimeWith(value: minutes)
        var secondText = setupTimeWith(value: seconds)
        
        let dateKey = "\(year)\(month)\(day)"
        print("CurrentDateKey \(dateKey)")
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if seconds > 0 {
                seconds -= 1
            } else {
                seconds = 60
                if minutes > 0 {
                    minutes -= 1
                } else {
                    minutes = 60
                    if hours > 0 {
                        hours -= 1
                    } else {
                        timer.invalidate()
                        self.reactivateEmojiView()
                    }
                }
            }
            hourText = self.setupTimeWith(value: hours)
            minuteText = self.setupTimeWith(value: minutes)
            secondText = self.setupTimeWith(value: seconds)
            if self.isProfile {
                self.title = "Profile"
                self.navigationItem.title = "\(hourText):\(minuteText):\(secondText)"
            } else {
                self.title = "\(hourText):\(minuteText):\(secondText)"
            }
            
        }
    }
    
    fileprivate func setupTimeWith(value: Int) -> String {
        if value < 10 {
            return "0\(value)"
        }
        return "\(value)"
    }
    
    func openURL(string: String) {
        guard let url = URL(string: string) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func reactivateEmojiView() {
        if !DatabaseManager.Instance.userHasAnswered {
            FirebaseManager.Instance.sendEmptyPost()
        }
        DatabaseManager.Instance.updateUserDefaults(value: false, key: .userHasAnswered)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
        self.setupCountDown()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
