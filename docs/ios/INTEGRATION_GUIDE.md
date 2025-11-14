# CloudX iOS SDK - Complete Integration Guide

Comprehensive guide for integrating CloudX SDK in iOS apps using Claude Code agents. Includes code examples for all ad formats in both Objective-C and Swift.

## Table of Contents

1. [Installation](#installation)
2. [Initialization](#initialization)
3. [Banner Ads](#banner-ads)
4. [MREC Ads](#mrec-ads)
5. [Interstitial Ads](#interstitial-ads)
6. [Rewarded Ads](#rewarded-ads)
7. [Native Ads](#native-ads)
8. [Privacy Configuration](#privacy-configuration)
9. [Fallback Patterns](#fallback-patterns)
10. [Testing](#testing)

---

## Installation

### Option 1: CocoaPods (Recommended)

Add to your `Podfile`:

```ruby
platform :ios, '14.0'

target 'YourApp' do
  use_frameworks!

  # CloudX Core SDK
  pod 'CloudXCore', '~> 1.2.0'

  # Optional: Fallback SDKs
  pod 'Google-Mobile-Ads-SDK'  # AdMob
  # pod 'AppLovinSDK'          # AppLovin
end
```

Install:
```bash
pod install
```

### Option 2: Swift Package Manager

**Via Xcode:**
1. File → Add Packages...
2. Enter: `https://github.com/cloudx-io/cloudx-ios`
3. Select CloudXCore
4. Add to your target

**Via Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/cloudx-io/cloudx-ios", from: "1.2.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "CloudXCore", package: "cloudx-ios")
        ]
    )
]
```

---

## Initialization

### Basic Initialization

Initialize CloudX SDK in your AppDelegate **before** loading any ads.

#### Objective-C (AppDelegate.m)

```objective-c
#import <CloudXCore/CloudXCore.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Set privacy settings BEFORE initialization
    [CloudXCore setCCPAPrivacyString:@"1YNN"];
    [CloudXCore setIsUserConsent:YES];
    [CloudXCore setIsAgeRestrictedUser:NO];

    // Initialize CloudX SDK
    [[CloudXCore shared] initializeSDKWithAppKey:@"YOUR_APP_KEY"
                                      completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"[CloudX] SDK initialized successfully");
        } else {
            NSLog(@"[CloudX] SDK initialization failed: %@", error.localizedDescription);
        }
    }];

    return YES;
}

@end
```

#### Swift (AppDelegate.swift)

```swift
import UIKit
import CloudXCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set privacy settings BEFORE initialization
        CloudXCore.setCCPAPrivacyString("1YNN")
        CloudXCore.setIsUserConsent(true)
        CloudXCore.setIsAgeRestrictedUser(false)

        // Initialize CloudX SDK
        CloudXCore.shared.initializeSDK(appKey: "YOUR_APP_KEY") { success, error in
            if success {
                print("[CloudX] SDK initialized successfully")
            } else if let error = error {
                print("[CloudX] SDK initialization failed: \(error.localizedDescription)")
            }
        }

        return true
    }
}
```

#### SwiftUI App

```swift
import SwiftUI
import CloudXCore

@main
struct YourApp: App {

    init() {
        // Set privacy settings
        CloudXCore.setCCPAPrivacyString("1YNN")
        CloudXCore.setIsUserConsent(true)
        CloudXCore.setIsAgeRestrictedUser(false)

        // Initialize SDK
        CloudXCore.shared.initializeSDK(appKey: "YOUR_APP_KEY") { success, error in
            if success {
                print("[CloudX] SDK initialized")
            } else if let error = error {
                print("[CloudX] Initialization failed: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Initialization with ATT (iOS 14.5+)

Request App Tracking Transparency permission before SDK initialization:

#### Objective-C

```objective-c
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CloudXCore/CloudXCore.h>

- (void)requestATTAndInitializeSDK {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"[ATT] User authorized tracking");
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"[ATT] User denied tracking");
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    NSLog(@"[ATT] User hasn't been asked yet");
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    NSLog(@"[ATT] Tracking is restricted");
                    break;
            }

            // Initialize CloudX after ATT response
            [self initializeCloudX];
        }];
    } else {
        // iOS < 14, no ATT required
        [self initializeCloudX];
    }
}

- (void)initializeCloudX {
    [CloudXCore setCCPAPrivacyString:@"1YNN"];
    [[CloudXCore shared] initializeSDKWithAppKey:@"YOUR_KEY" completion:^(BOOL success, NSError *error) {
        // ...
    }];
}
```

#### Swift

```swift
import AppTrackingTransparency
import AdSupport
import CloudXCore

func requestATTAndInitializeSDK() {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("[ATT] User authorized tracking")
            case .denied:
                print("[ATT] User denied tracking")
            case .notDetermined:
                print("[ATT] User hasn't been asked yet")
            case .restricted:
                print("[ATT] Tracking is restricted")
            @unknown default:
                break
            }

            // Initialize CloudX after ATT response
            self.initializeCloudX()
        }
    } else {
        // iOS < 14, no ATT required
        initializeCloudX()
    }
}

func initializeCloudX() {
    CloudXCore.setCCPAPrivacyString("1YNN")
    CloudXCore.shared.initializeSDK(appKey: "YOUR_KEY") { success, error in
        // ...
    }
}
```

---

## Banner Ads

### CloudX-Only Banner (No Fallback)

#### Objective-C

```objective-c
#import <CloudXCore/CloudXCore.h>

@interface BannerViewController : UIViewController <CLXBannerDelegate>
@property (nonatomic, strong) CLXBannerAdView *bannerAdView;
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBanner];
}

- (void)loadBanner {
    // Create CloudX banner
    self.bannerAdView = [[CloudXCore shared] createBannerWithPlacement:@"banner_home"
                                                        viewController:self
                                                              delegate:self
                                                                  tmax:nil];

    if (self.bannerAdView) {
        // Add to view hierarchy
        [self.view addSubview:self.bannerAdView];

        // Auto Layout
        self.bannerAdView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.bannerAdView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.bannerAdView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
        ]];
    }
}

#pragma mark - CLXBannerDelegate

- (void)bannerDidLoad:(CLXBannerAdView *)banner {
    NSLog(@"[CloudX] Banner loaded");
}

- (void)bannerDidFailToLoad:(CLXBannerAdView *)banner withError:(NSError *)error {
    NSLog(@"[CloudX] Banner failed to load: %@", error.localizedDescription);
}

- (void)bannerDidDisplay:(CLXBannerAdView *)banner {
    NSLog(@"[CloudX] Banner displayed");
}

- (void)bannerDidClick:(CLXBannerAdView *)banner {
    NSLog(@"[CloudX] Banner clicked");
}

- (void)bannerDidDismiss:(CLXBannerAdView *)banner {
    NSLog(@"[CloudX] Banner dismissed");
}

- (void)dealloc {
    self.bannerAdView = nil;
}

@end
```

#### Swift

```swift
import UIKit
import CloudXCore

class BannerViewController: UIViewController {

    private var bannerAdView: CLXBannerAdView?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBanner()
    }

    private func loadBanner() {
        // Create CloudX banner
        bannerAdView = CloudXCore.shared.createBanner(placement: "banner_home",
                                                      viewController: self,
                                                      delegate: self,
                                                      tmax: nil)

        guard let banner = bannerAdView else { return }

        // Add to view hierarchy
        view.addSubview(banner)

        // Auto Layout
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    deinit {
        bannerAdView = nil
    }
}

// MARK: - CLXBannerDelegate
extension BannerViewController: CLXBannerDelegate {

    func bannerDidLoad(_ banner: CLXBannerAdView) {
        print("[CloudX] Banner loaded")
    }

    func bannerDidFailToLoad(_ banner: CLXBannerAdView, withError error: Error) {
        print("[CloudX] Banner failed to load: \(error.localizedDescription)")
    }

    func bannerDidDisplay(_ banner: CLXBannerAdView) {
        print("[CloudX] Banner displayed")
    }

    func bannerDidClick(_ banner: CLXBannerAdView) {
        print("[CloudX] Banner clicked")
    }

    func bannerDidDismiss(_ banner: CLXBannerAdView) {
        print("[CloudX] Banner dismissed")
    }
}
```

### Banner with AdMob Fallback

#### Objective-C

```objective-c
#import <CloudXCore/CloudXCore.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface BannerViewController : UIViewController <CLXBannerDelegate, GADBannerViewDelegate>
@property (nonatomic, strong) CLXBannerAdView *cloudXBanner;
@property (nonatomic, strong) GADBannerView *adMobBanner;
@property (nonatomic, assign) BOOL isCloudXLoaded;
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBanner];
}

- (void)loadBanner {
    self.isCloudXLoaded = NO;

    // Try CloudX first
    self.cloudXBanner = [[CloudXCore shared] createBannerWithPlacement:@"banner_home"
                                                        viewController:self
                                                              delegate:self
                                                                  tmax:nil];

    if (self.cloudXBanner) {
        [self.view addSubview:self.cloudXBanner];
        self.cloudXBanner.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.cloudXBanner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.cloudXBanner.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
        ]];
    }
}

#pragma mark - CLXBannerDelegate

- (void)bannerDidLoad:(CLXBannerAdView *)banner {
    NSLog(@"[CloudX] Banner loaded - using CloudX");
    self.isCloudXLoaded = YES;
}

- (void)bannerDidFailToLoad:(CLXBannerAdView *)banner withError:(NSError *)error {
    NSLog(@"[CloudX] Banner failed: %@ - falling back to AdMob", error.localizedDescription);
    [self loadAdMobBannerFallback];
}

#pragma mark - AdMob Fallback

- (void)loadAdMobBannerFallback {
    // Remove CloudX banner
    if (self.cloudXBanner) {
        [self.cloudXBanner removeFromSuperview];
        self.cloudXBanner = nil;
    }

    // Create AdMob banner
    self.adMobBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.adMobBanner.adUnitID = @"ca-app-pub-xxxxx/banner";
    self.adMobBanner.rootViewController = self;
    self.adMobBanner.delegate = self;

    [self.view addSubview:self.adMobBanner];
    self.adMobBanner.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.adMobBanner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.adMobBanner.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
    ]];

    // Load AdMob ad
    GADRequest *request = [GADRequest request];
    [self.adMobBanner loadRequest:request];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"[AdMob] Banner loaded successfully (fallback)");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"[AdMob] Banner failed to load: %@", error.localizedDescription);
}

@end
```

#### Swift

```swift
import UIKit
import CloudXCore
import GoogleMobileAds

class BannerViewController: UIViewController {

    private var cloudXBanner: CLXBannerAdView?
    private var adMobBanner: GADBannerView?
    private var isCloudXLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBanner()
    }

    private func loadBanner() {
        isCloudXLoaded = false

        // Try CloudX first
        cloudXBanner = CloudXCore.shared.createBanner(placement: "banner_home",
                                                      viewController: self,
                                                      delegate: self,
                                                      tmax: nil)

        guard let banner = cloudXBanner else { return }

        view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func loadAdMobBannerFallback() {
        // Remove CloudX banner
        cloudXBanner?.removeFromSuperview()
        cloudXBanner = nil

        // Create AdMob banner
        adMobBanner = GADBannerView(adSize: GADAdSizeBanner)
        adMobBanner?.adUnitID = "ca-app-pub-xxxxx/banner"
        adMobBanner?.rootViewController = self
        adMobBanner?.delegate = self

        guard let banner = adMobBanner else { return }

        view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        banner.load(GADRequest())
    }
}

// MARK: - CLXBannerDelegate
extension BannerViewController: CLXBannerDelegate {

    func bannerDidLoad(_ banner: CLXBannerAdView) {
        print("[CloudX] Banner loaded - using CloudX")
        isCloudXLoaded = true
    }

    func bannerDidFailToLoad(_ banner: CLXBannerAdView, withError error: Error) {
        print("[CloudX] Banner failed: \(error.localizedDescription) - falling back to AdMob")
        loadAdMobBannerFallback()
    }
}

// MARK: - GADBannerViewDelegate
extension BannerViewController: GADBannerViewDelegate {

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("[AdMob] Banner loaded successfully (fallback)")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("[AdMob] Banner failed to load: \(error.localizedDescription)")
    }
}
```

---

## MREC Ads

MREC (Medium Rectangle) ads use the same delegate as banners (`CLXBannerDelegate`).

### Objective-C

```objective-c
- (void)loadMREC {
    CLXBannerAdView *mrecAd = [[CloudXCore shared] createMRECWithPlacement:@"mrec_main"
                                                            viewController:self
                                                                  delegate:self];

    if (mrecAd) {
        [self.view addSubview:mrecAd];

        // Center in view
        mrecAd.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [mrecAd.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [mrecAd.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
        ]];
    }
}
```

### Swift

```swift
private func loadMREC() {
    let mrecAd = CloudXCore.shared.createMREC(placement: "mrec_main",
                                              viewController: self,
                                              delegate: self)

    guard let mrec = mrecAd else { return }

    view.addSubview(mrec)

    // Center in view
    mrec.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        mrec.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        mrec.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
}
```

---

## Interstitial Ads

### CloudX-Only Interstitial

#### Objective-C

```objective-c
#import <CloudXCore/CloudXCore.h>

@interface InterstitialViewController : UIViewController <CLXInterstitialDelegate>
@property (nonatomic, strong) CLXInterstitial *interstitial;
@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInterstitial];
}

- (void)loadInterstitial {
    // Create and load interstitial
    self.interstitial = [[CloudXCore shared] createInterstitialWithPlacement:@"interstitial_main"
                                                                     delegate:self];
}

- (IBAction)showInterstitialButtonTapped:(id)sender {
    if (self.interstitial) {
        [self.interstitial showFromViewController:self];
    } else {
        NSLog(@"[CloudX] Interstitial not ready");
    }
}

#pragma mark - CLXInterstitialDelegate

- (void)interstitialDidLoad:(CLXInterstitial *)interstitial {
    NSLog(@"[CloudX] Interstitial loaded and ready to show");
}

- (void)interstitialDidFailToLoad:(CLXInterstitial *)interstitial withError:(NSError *)error {
    NSLog(@"[CloudX] Interstitial failed to load: %@", error.localizedDescription);
}

- (void)interstitialDidDisplay:(CLXInterstitial *)interstitial {
    NSLog(@"[CloudX] Interstitial displayed");
}

- (void)interstitialDidClick:(CLXInterstitial *)interstitial {
    NSLog(@"[CloudX] Interstitial clicked");
}

- (void)interstitialDidDismiss:(CLXInterstitial *)interstitial {
    NSLog(@"[CloudX] Interstitial dismissed");
    // Reload for next time
    [self loadInterstitial];
}

@end
```

#### Swift

```swift
import UIKit
import CloudXCore

class InterstitialViewController: UIViewController {

    private var interstitial: CLXInterstitial?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterstitial()
    }

    private func loadInterstitial() {
        // Create and load interstitial
        interstitial = CloudXCore.shared.createInterstitial(placement: "interstitial_main",
                                                            delegate: self)
    }

    @IBAction func showInterstitialButtonTapped(_ sender: Any) {
        if let interstitial = interstitial {
            interstitial.show(from: self)
        } else {
            print("[CloudX] Interstitial not ready")
        }
    }
}

// MARK: - CLXInterstitialDelegate
extension InterstitialViewController: CLXInterstitialDelegate {

    func interstitialDidLoad(_ interstitial: CLXInterstitial) {
        print("[CloudX] Interstitial loaded and ready to show")
    }

    func interstitialDidFailToLoad(_ interstitial: CLXInterstitial, withError error: Error) {
        print("[CloudX] Interstitial failed to load: \(error.localizedDescription)")
    }

    func interstitialDidDisplay(_ interstitial: CLXInterstitial) {
        print("[CloudX] Interstitial displayed")
    }

    func interstitialDidClick(_ interstitial: CLXInterstitial) {
        print("[CloudX] Interstitial clicked")
    }

    func interstitialDidDismiss(_ interstitial: CLXInterstitial) {
        print("[CloudX] Interstitial dismissed")
        // Reload for next time
        loadInterstitial()
    }
}
```

---

## Rewarded Ads

### CloudX-Only Rewarded

#### Objective-C

```objective-c
#import <CloudXCore/CloudXCore.h>

@interface RewardedViewController : UIViewController <CLXRewardedDelegate>
@property (nonatomic, strong) CLXRewarded *rewardedAd;
@end

@implementation RewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRewardedAd];
}

- (void)loadRewardedAd {
    // Create and load rewarded ad
    self.rewardedAd = [[CloudXCore shared] createRewardedWithPlacement:@"rewarded_main"
                                                               delegate:self];
}

- (IBAction)showRewardedAdButtonTapped:(id)sender {
    if (self.rewardedAd) {
        [self.rewardedAd showFromViewController:self];
    } else {
        NSLog(@"[CloudX] Rewarded ad not ready");
    }
}

#pragma mark - CLXRewardedDelegate

- (void)rewardedDidLoad:(CLXRewarded *)rewarded {
    NSLog(@"[CloudX] Rewarded ad loaded and ready");
}

- (void)rewardedDidFailToLoad:(CLXRewarded *)rewarded withError:(NSError *)error {
    NSLog(@"[CloudX] Rewarded ad failed to load: %@", error.localizedDescription);
}

- (void)rewardedDidDisplay:(CLXRewarded *)rewarded {
    NSLog(@"[CloudX] Rewarded ad displayed");
}

- (void)rewardedDidClick:(CLXRewarded *)rewarded {
    NSLog(@"[CloudX] Rewarded ad clicked");
}

- (void)rewardedDidDismiss:(CLXRewarded *)rewarded {
    NSLog(@"[CloudX] Rewarded ad dismissed");
    // Reload for next time
    [self loadRewardedAd];
}

- (void)rewardedUserDidEarnReward:(CLXRewarded *)rewarded {
    NSLog(@"[CloudX] User earned reward!");
    // Grant reward to user (coins, lives, etc.)
    [self grantRewardToUser];
}

- (void)grantRewardToUser {
    // Implement your reward logic here
    NSLog(@"Granting 100 coins to user");
}

@end
```

#### Swift

```swift
import UIKit
import CloudXCore

class RewardedViewController: UIViewController {

    private var rewardedAd: CLXRewarded?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRewardedAd()
    }

    private func loadRewardedAd() {
        // Create and load rewarded ad
        rewardedAd = CloudXCore.shared.createRewarded(placement: "rewarded_main",
                                                      delegate: self)
    }

    @IBAction func showRewardedAdButtonTapped(_ sender: Any) {
        if let rewarded = rewardedAd {
            rewarded.show(from: self)
        } else {
            print("[CloudX] Rewarded ad not ready")
        }
    }

    private func grantRewardToUser() {
        // Implement your reward logic here
        print("Granting 100 coins to user")
    }
}

// MARK: - CLXRewardedDelegate
extension RewardedViewController: CLXRewardedDelegate {

    func rewardedDidLoad(_ rewarded: CLXRewarded) {
        print("[CloudX] Rewarded ad loaded and ready")
    }

    func rewardedDidFailToLoad(_ rewarded: CLXRewarded, withError error: Error) {
        print("[CloudX] Rewarded ad failed to load: \(error.localizedDescription)")
    }

    func rewardedDidDisplay(_ rewarded: CLXRewarded) {
        print("[CloudX] Rewarded ad displayed")
    }

    func rewardedDidClick(_ rewarded: CLXRewarded) {
        print("[CloudX] Rewarded ad clicked")
    }

    func rewardedDidDismiss(_ rewarded: CLXRewarded) {
        print("[CloudX] Rewarded ad dismissed")
        // Reload for next time
        loadRewardedAd()
    }

    func rewardedUserDidEarnReward(_ rewarded: CLXRewarded) {
        print("[CloudX] User earned reward!")
        // Grant reward to user
        grantRewardToUser()
    }
}
```

---

## Native Ads

### Basic Native Ad

#### Swift

```swift
import UIKit
import CloudXCore

class NativeAdViewController: UIViewController {

    private var nativeAdView: CLXNativeAdView?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNativeAd()
    }

    private func loadNativeAd() {
        nativeAdView = CloudXCore.shared.createNativeAd(placement: "native_main",
                                                        viewController: self,
                                                        delegate: self)

        guard let nativeAd = nativeAdView else { return }

        view.addSubview(nativeAd)
        nativeAd.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nativeAd.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nativeAd.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nativeAd.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nativeAd.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - CLXNativeDelegate
extension NativeAdViewController: CLXNativeDelegate {

    func nativeAdDidLoad(_ nativeAd: CLXNativeAdView) {
        print("[CloudX] Native ad loaded")
    }

    func nativeAdDidFailToLoad(_ nativeAd: CLXNativeAdView, withError error: Error) {
        print("[CloudX] Native ad failed: \(error.localizedDescription)")
    }

    func nativeAdDidDisplay(_ nativeAd: CLXNativeAdView) {
        print("[CloudX] Native ad displayed")
    }

    func nativeAdDidClick(_ nativeAd: CLXNativeAdView) {
        print("[CloudX] Native ad clicked")
    }
}
```

---

## Privacy Configuration

### Complete Privacy Setup

#### Objective-C (AppDelegate.m)

```objective-c
#import <CloudXCore/CloudXCore.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Request ATT permission (iOS 14.5+)
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            [self initializeSDKWithPrivacy];
        }];
    } else {
        [self initializeSDKWithPrivacy];
    }

    return YES;
}

- (void)initializeSDKWithPrivacy {
    // CCPA (California Consumer Privacy Act)
    [CloudXCore setCCPAPrivacyString:@"1YNN"];

    // GDPR (General Data Protection Regulation)
    // Note: Not yet supported by CloudX servers
    [CloudXCore setIsUserConsent:YES];

    // COPPA (Children's Online Privacy Protection Act)
    BOOL isChildDirected = NO;  // Set to YES if app targets children under 13
    [CloudXCore setIsAgeRestrictedUser:isChildDirected];

    // CCPA - Do Not Sell option
    [CloudXCore setIsDoNotSell:NO];  // Set to YES if user opts out

    // Initialize SDK
    [[CloudXCore shared] initializeSDKWithAppKey:@"YOUR_APP_KEY" completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"[CloudX] SDK initialized with privacy settings");
        } else {
            NSLog(@"[CloudX] Initialization failed: %@", error.localizedDescription);
        }
    }];
}

@end
```

#### Swift (AppDelegate.swift)

```swift
import UIKit
import CloudXCore
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Request ATT permission (iOS 14.5+)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                self.initializeSDKWithPrivacy()
            }
        } else {
            initializeSDKWithPrivacy()
        }

        return true
    }

    private func initializeSDKWithPrivacy() {
        // CCPA (California Consumer Privacy Act)
        CloudXCore.setCCPAPrivacyString("1YNN")

        // GDPR (General Data Protection Regulation)
        // Note: Not yet supported by CloudX servers
        CloudXCore.setIsUserConsent(true)

        // COPPA (Children's Online Privacy Protection Act)
        let isChildDirected = false  // Set to true if app targets children under 13
        CloudXCore.setIsAgeRestrictedUser(isChildDirected)

        // CCPA - Do Not Sell option
        CloudXCore.setIsDoNotSell(false)  // Set to true if user opts out

        // Initialize SDK
        CloudXCore.shared.initializeSDK(appKey: "YOUR_APP_KEY") { success, error in
            if success {
                print("[CloudX] SDK initialized with privacy settings")
            } else if let error = error {
                print("[CloudX] Initialization failed: \(error.localizedDescription)")
            }
        }
    }
}
```

### Info.plist Privacy Declarations

Add to your `Info.plist`:

```xml
<!-- Required for iOS 14.5+ -->
<key>NSUserTrackingUsageDescription</key>
<string>This app would like to access IDFA for ad personalization and frequency capping.</string>

<!-- Required if using AdMob -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>

<!-- Recommended: SKAdNetwork items for iOS 14+ attribution -->
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Add more as needed -->
</array>
```

---

## Fallback Patterns

### Pattern 1: Sequential Fallback (CloudX → AdMob → AppLovin)

```swift
class AdManager {
    private var cloudXInterstitial: CLXInterstitial?
    private var adMobInterstitial: GADInterstitialAd?
    private var appLovinInterstitial: MAInterstitialAd?

    private var currentProvider: AdProvider = .none

    enum AdProvider {
        case none, cloudX, adMob, appLovin
    }

    func loadInterstitial() {
        currentProvider = .none

        // Try CloudX first
        cloudXInterstitial = CloudXCore.shared.createInterstitial(
            placement: "interstitial_main",
            delegate: self
        )
    }

    private func fallbackToAdMob() {
        print("[AdManager] Falling back to AdMob")
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-xxxxx/interstitial",
            request: GADRequest()
        ) { [weak self] ad, error in
            if let ad = ad {
                self?.adMobInterstitial = ad
                self?.currentProvider = .adMob
            } else {
                self?.fallbackToAppLovin()
            }
        }
    }

    private func fallbackToAppLovin() {
        print("[AdManager] Falling back to AppLovin")
        appLovinInterstitial = MAInterstitialAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
        appLovinInterstitial?.delegate = self
        appLovinInterstitial?.load()
    }
}

extension AdManager: CLXInterstitialDelegate {
    func interstitialDidLoad(_ interstitial: CLXInterstitial) {
        currentProvider = .cloudX
    }

    func interstitialDidFailToLoad(_ interstitial: CLXInterstitial, withError error: Error) {
        fallbackToAdMob()
    }
}
```

---

## Testing

### Test CloudX Initialization

```swift
// In AppDelegate
CloudXCore.shared.initializeSDK(appKey: "YOUR_KEY") { success, error in
    if success {
        print("✅ CloudX SDK initialized successfully")
        print("SDK Version: \(CloudXCore.shared.sdkVersion)")
    } else if let error = error {
        print("❌ CloudX initialization failed: \(error.localizedDescription)")
    }
}
```

### Test Ad Loading

```swift
// Enable detailed logging
CloudXCore.setLoggingEnabled(true)
CloudXCore.setMinLogLevel(.verbose)

// Load ad and watch console
let banner = CloudXCore.shared.createBanner(
    placement: "banner_home",
    viewController: self,
    delegate: self,
    tmax: nil
)
```

### Test Fallback Behavior

Simulate CloudX failure to test fallback:
1. Use invalid placement name
2. Disconnect internet
3. Watch fallback trigger in console

---

## Best Practices

1. **Initialize Early**: Call `initializeSDK` in AppDelegate
2. **Set Privacy First**: Configure privacy BEFORE initialization
3. **Implement All Delegates**: At minimum `didLoad` and `didFailToLoad`
4. **Handle Errors**: Log errors and implement fallback
5. **Memory Management**: Nil out ad properties in `deinit`/`dealloc`
6. **Test Thoroughly**: Test success and failure scenarios
7. **Respect User Privacy**: Implement ATT, CCPA, GDPR correctly

---

## Next Steps

1. **Verify Integration**: Use @agent-cloudx-ios-auditor
2. **Check Privacy**: Use @agent-cloudx-ios-privacy-checker
3. **Build Project**: Use @agent-cloudx-ios-build-verifier
4. **Test in Production**: Use real app key and placements
5. **Monitor**: Check CloudX dashboard for metrics

---

## Support

- **Email**: mobile@cloudx.io
- **GitHub Issues**: [cloudx-sdk-agents/issues](https://github.com/cloudx-io/cloudx-sdk-agents/issues)
- **iOS SDK**: [cloudx-ios](https://github.com/cloudx-io/cloudx-ios)
