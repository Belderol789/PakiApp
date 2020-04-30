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

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hideTabbar {
           tabBarController?.tabBar.isHidden = true
        }
        if navigationBar {
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if hideTabbar {
           tabBarController?.tabBar.isHidden = false
        }
        if navigationBar {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    func setupCountDown() {
        let today = Date()
        let tomorrow = Date.tomorrow
        
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
                        print("DayEnded")
                        timer.invalidate()
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
    
}
