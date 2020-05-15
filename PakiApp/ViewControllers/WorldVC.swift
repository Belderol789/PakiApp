//
//  WorldVC.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/16/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class WorldVC: GeneralViewController {
    
    @IBOutlet weak var graphsView: GraphsView!
    
    var savedAllPakis: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCountDown()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedAllPaki(notification:)), name: NSNotification.Name(rawValue: "AllPakis"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.defaultBGColor
        
        graphsView.backgroundColor = .clear
        savedAllPakis = DatabaseManager.Instance.savedAllPakis
        graphsView.addWorldPakiCircles(allPaki: savedAllPakis)
    }
    
    @objc
    func receivedAllPaki(notification: Notification) {
        if let payload = notification.object as? [String] {
            print("Payload received")
            if savedAllPakis.isEmpty {
                savedAllPakis = payload
                setupUI()
            }
        }
    }
}
