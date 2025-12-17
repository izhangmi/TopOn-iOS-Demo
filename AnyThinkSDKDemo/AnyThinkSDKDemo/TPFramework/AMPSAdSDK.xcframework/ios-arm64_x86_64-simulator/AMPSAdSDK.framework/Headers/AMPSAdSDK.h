//
//  AMPSAdSDK.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/22.
//

#import <Foundation/Foundation.h>

//! Project version number for AMPSAdSDK.
FOUNDATION_EXPORT double AMPSAdSDKVersionNumber;

//! Project version string for AMPSAdSDK.
FOUNDATION_EXPORT const unsigned char AMPSAdSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AMPSAdSDK/PublicHeader.h>

//  Protocol
#import <AMPSAdSDK/AMPSBaseProtocol.h>
#import <AMPSAdSDK/AMPSBiddingProtocol.h>

//  Public init class
#import <AMPSAdSDK/AMPSAdSDKManager.h>
#import <AMPSAdSDK/AMPSAdSDKConfiguration.h>
#import <AMPSAdSDK/AMPSAdSDKDefines.h>

//  Public base class
#import <AMPSAdSDK/AMPSInterfaceBaseObject.h>
#import <AMPSAdSDK/AMPSInterfaceBaseView.h>
#import <AMPSAdSDK/AMPSAdConfiguration.h>
#import <AMPSAdSDK/AMPSAdSDKError.h>

//  Public advertisings class
#import <AMPSAdSDK/AMPSSplashAd.h>
#import <AMPSAdSDK/AMPSSplashAdDelegate.h>

#import <AMPSAdSDK/AMPSNativeExpressManager.h>
#import <AMPSAdSDK/AMPSNativeExpressManagerDelegate.h>
#import <AMPSAdSDK/AMPSNativeExpressView.h>
#import <AMPSAdSDK/AMPSNativeExpressViewDelegate.h>

#import <AMPSAdSDK/AMPSInterstitialAd.h>
#import <AMPSAdSDK/AMPSInterstitialAdDelegate.h>

#import <AMPSAdSDK/AMPSUnifiedNativeManager.h>
#import <AMPSAdSDK/AMPSUnifiedNativeManagerDelegate.h>
#import <AMPSAdSDK/AMPSUnifiedNativeAd.h>
#import <AMPSAdSDK/AMPSUnifiedNativeViewDelegate.h>
#import <AMPSAdSDK/AMPSUnifiedNativeView.h>
#import <AMPSAdSDK/AMPSMediaView.h>

