//
//  CalendarVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/25/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CalendarVC: GeneralViewController, Reusable {
    
    // IBOutlets
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    // Variables
    var userPosts: [UserPost] = []
    var calendarItems: [AnyObject] = []
    var postTag: Int = 0
    let adUnitID = "ca-app-pub-8278458623868241/2398893160"
    var numAdsToLoad = 5
    var nativeAds = [GADUnifiedNativeAd]()
    var adLoader: GADAdLoader!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVCUI()
        setupMobileAds()
        AppStoreManager.requestReviewIfAppropriate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToPost(index: postTag)
    }
    
    func setupVCUI() {
        calendarItems.append(contentsOf: userPosts)
        view.backgroundColor = UIColor.defaultBGColor
        calendarCollectionView.register(CalendarCollectionViewCell.nib, forCellWithReuseIdentifier: CalendarCollectionViewCell.className)
        calendarCollectionView.register(UnifiedNativeAdCVC.nib, forCellWithReuseIdentifier: UnifiedNativeAdCVC.className)
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.backgroundColor = .clear
        calendarCollectionView.scrollToItem(at: IndexPath(item: postTag, section: 0), at: .right, animated: true)
        
        totalLabel.text = "Total: \(userPosts.count)"
    }
    
    
    
    func setupMobileAds() {
        
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        
        // Prepare the ad loader and start loading ads.
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: self,
                               adTypes: [.unifiedNative],
                               options: [options])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func scrollToPost(index: Int) {
        calendarCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .top, animated: true)
    }
    
    func addNativeAds() {
        if nativeAds.count <= 0 {
            return
        }
        
        let adInterval = 5
        var index = 0
        
        for nativeAd in nativeAds {
            if index < userPosts.count {
                calendarItems.insert(nativeAd, at: index)
                index += adInterval
            } else {
                break
            }
        }
        
        calendarCollectionView.reloadData()
        
    }
    
    @IBAction func didDismissCalendar(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - GADUnifiedNativeAdLoaderDelegate
extension CalendarVC: GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAds.append(nativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed to load ads")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        addNativeAds()
    }
}

extension CalendarVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarItem = calendarItems[indexPath.item]
        if let calendar = calendarItem as? UserPost {
            let calendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.className, for: indexPath) as! CalendarCollectionViewCell
            calendarCell.setupCalendarView(post: calendar)
            return calendarCell
        } else {
            let nativeAd = calendarItem as! GADUnifiedNativeAd
            nativeAd.rootViewController = self
            
            let nativeAdCell = collectionView.dequeueReusableCell(withReuseIdentifier: UnifiedNativeAdCVC.className, for: indexPath) as! UnifiedNativeAdCVC
            nativeAdCell.setupAdView(with: nativeAd)
            return nativeAdCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let calenderItem = calendarItems[indexPath.item]
        
        if let calendar = calenderItem as? UserPost {
            let titleHeight = calendar.title.returnStringHeight(fontSize: 20, width: 340).height
            let contentHeight = calendar.content.returnStringHeight(fontSize: 17, width: 340).height
            let totalHeight = titleHeight + contentHeight + 200
            
            return CGSize(width: view.frame.size.width, height: totalHeight)
        } else {
            return CGSize(width: view.frame.size.width, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let calendarItem = calendarItems[indexPath.item] as? UserPost {
            let commentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
            commentVC.currentPost = calendarItem
            self.present(commentVC, animated: true) {
                commentVC.backButton.isHidden = false
            }
        }
        // Go to comments
    }

}
