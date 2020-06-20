//
//  AppstoreManager.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/19/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import StoreKit

enum AppStoreManager {
    
    // 1.
    static let minimumReviewWorthyActionCount = 10
    
    static func requestReviewIfAppropriate() {
        let bundle = Bundle.main
        let databaseManager = DatabaseManager.Instance
        
        // 2.
        var actionCount = databaseManager.reviewCount
        
        // 3.
        actionCount += 1
        
        // 4.
        databaseManager.updateUserDefaults(value: actionCount, key: .reviewWorthyActionCount)
        
        // 5.
        guard actionCount >= minimumReviewWorthyActionCount else {
            return
        }
        
        // 6.
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = databaseManager.lastVersion
        
        // 7.
        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }
        
        // 8.
        SKStoreReviewController.requestReview()
        
        // 9.
        databaseManager.updateUserDefaults(value: 0, key: .reviewWorthyActionCount)
        databaseManager.updateUserDefaults(value: currentVersion ?? lastVersion!, key: .lastVersion)
    }
    
}
