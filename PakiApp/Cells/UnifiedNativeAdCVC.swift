//
//  UnifiedNativeAdCVC.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/17/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import GoogleMobileAds

class UnifiedNativeAdCVC: UICollectionViewCell, Reusable {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.defaultFGColor
        self.contentView.backgroundColor = UIColor.defaultFGColor
    }
    
    func setupAdView(with nativeAd: GADUnifiedNativeAd) {
        let adView : GADUnifiedNativeAdView = self.contentView.subviews.first as! GADUnifiedNativeAdView
        adView.nativeAd = nativeAd
        // Populate the ad view with the ad assets.
        (adView.headlineView as! UILabel).text = nativeAd.headline
        (adView.priceView as! UILabel).text = nativeAd.price
        if let starRating = nativeAd.starRating {
            (adView.starRatingView as! UILabel).text =
                starRating.description + "\u{2605}"
        } else {
            (adView.starRatingView as! UILabel).text = nil
        }
        (adView.bodyView as! UILabel).text = nativeAd.body
        // The SDK automatically turns off user interaction for assets that are part of the ad, but
        // it is still good to be explicit.
        (adView.callToActionView as! UIButton).isUserInteractionEnabled = true
        (adView.callToActionView as! UIButton).setTitleColor(UIColor.hexStringToUIColor(hex: "0984FF"), for: .normal)
        (adView.callToActionView as! UIButton).setTitle(
            nativeAd.callToAction, for: .normal)
    }

}
