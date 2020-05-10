//
//  TimerViewController.swift
//  PakiApp
//
//  Created by Kem Belderol on 4/27/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class GeneralViewController: UIViewController, UINavigationControllerDelegate {
    
    var isProfile: Bool  = false
    var hideTabbar: Bool = false
    var navigationBar: Bool = false
    
    var viewCenter: CGRect = .zero
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let appearance: UIStatusBarStyle = DatabaseManager.Instance.userSetLightAppearance ? .lightContent : .darkContent
        return appearance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.defaultBGColor
        //appearanceChanged(notification: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(appearanceChanged(notification:)), name: NSNotification.Name(rawValue: NotifName.AppearanceChanged.rawValue), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc
    func appearanceChanged(notification: Notification?) {
//        let appearanceMode: Bool = DatabaseManager.Instance.userSetLightAppearance
//        let appearance: UIUserInterfaceStyle = appearanceMode ? .light : .dark
//        view.overrideUserInterfaceStyle = appearance
//        navigationController?.navigationBar.overrideUserInterfaceStyle = appearance
//        tabBarController?.tabBar.overrideUserInterfaceStyle = appearance
//
//        setNeedsStatusBarAppearanceUpdate()
//        navigationController?.navigationBar.barStyle = appearanceMode ? .default : .black
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
    
    func reactivateEmojiView() {
        if !DatabaseManager.Instance.userHasAnswered {
            FirebaseManager.Instance.sendEmptyPost()
        }
        DatabaseManager.Instance.updateUserDefaults(value: false, key: .userHasAnswered)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ActivateEmojiView"), object: nil)
        self.setupCountDown()
    }
    
}
