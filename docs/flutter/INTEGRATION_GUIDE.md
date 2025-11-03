# CloudX Flutter SDK - Complete Integration Guide

This comprehensive guide provides detailed code examples for integrating CloudX SDK into your Flutter app using AI agents.

---

## Table of Contents

1. [Integration Overview](#integration-overview)
2. [Integration Modes](#integration-modes)
3. [Basic Setup](#basic-setup)
4. [Banner Ads](#banner-ads)
5. [Interstitial Ads](#interstitial-ads)
6. [MREC Ads](#mrec-ads)
7. [Fallback Patterns](#fallback-patterns)
8. [Lifecycle Management](#lifecycle-management)
9. [State Management Integration](#state-management-integration)
10. [Privacy Compliance](#privacy-compliance)
11. [Testing Strategies](#testing-strategies)
12. [Common Patterns](#common-patterns)
13. [Troubleshooting](#troubleshooting)

---

## Integration Overview

### What the Agents Do

The `cloudx-flutter-integrator` agent automatically:
1. Detects existing ad SDKs (AdMob, AppLovin)
2. Chooses integration mode (CloudX-only or first-look with fallback)
3. Adds CloudX dependency
4. Initializes SDK
5. Implements ad loading with proper patterns
6. Sets up lifecycle management

### Two Integration Modes

**CloudX-Only (Greenfield)**:
- No existing ad SDK detected
- Simple, clean integration
- Recommended for new projects

**CloudX-First with Fallback (Migration)**:
- AdMob or AppLovin detected
- CloudX tries first, falls back on error
- Recommended when migrating from existing SDK

---

## Integration Modes

### Mode 1: CloudX-Only Integration

**When**: No `google_mobile_ads` or `applovin_max` in pubspec.yaml

**Benefits**:
- Simpler code (no fallback logic)
- Easier to maintain
- Faster to implement
- Lower complexity

**Use case**:
- New apps starting fresh
- Apps willing to rely 100% on CloudX
- Apps wanting simplest integration

### Mode 2: CloudX-First with Fallback

**When**: `google_mobile_ads` or `applovin_max` in pubspec.yaml

**Benefits**:
- Risk mitigation (fallback if CloudX fails)
- Gradual migration path
- Maintains existing revenue stream
- A/B testing capability

**Use case**:
- Apps migrating from AdMob/AppLovin
- Apps wanting backup ad source
- Apps in testing/validation phase

---

## Basic Setup

### Step 1: Add Dependency

The agent adds this to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cloudx_flutter: ^0.1.2
  # Existing ad SDKs preserved if present
  # google_mobile_ads: ^3.0.0
  # applovin_max: ^2.0.0
```

### Step 2: Initialize SDK

The agent modifies `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:cloudx_flutter/cloudx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: Enable logging for development
  await CloudX.setLoggingEnabled(true);

  // Optional: Set environment (dev/staging/production)
  await CloudX.setEnvironment('production');

  // Initialize CloudX FIRST
  final success = await CloudX.initialize(
    appKey: 'YOUR_APP_KEY_FROM_CLOUDX_DASHBOARD',
    allowIosExperimental: true,  // Required for iOS
  );

  if (success) {
    print('CloudX SDK initialized successfully');
  } else {
    print('Failed to initialize CloudX SDK');
  }

  // Then initialize other ad SDKs (if any)
  // await MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomeScreen(),
    );
  }
}
```

---

## Banner Ads

### Widget-Based Approach (Recommended)

**Advantage**: Automatic lifecycle management

#### CloudX-Only (No Fallback)

```dart
import 'package:flutter/material.dart';
import 'package:cloudx_flutter/cloudx.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          Expanded(
            child: Center(child: Text('Your content here')),
          ),

          // CloudX banner at bottom
          CloudXBannerView(
            placementName: 'banner_home',
            listener: CloudXAdViewListener(
              onAdLoaded: (ad) {
                print('Banner loaded from ${ad.bidder}');
                print('Revenue: \$${ad.revenue}');
              },
              onAdLoadFailed: (error) {
                print('Banner failed to load: $error');
              },
              onAdDisplayed: (ad) => print('Banner displayed'),
              onAdClicked: (ad) => print('Banner clicked'),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### CloudX-First with AdMob Fallback

```dart
import 'package:flutter/material.dart';
import 'package:cloudx_flutter/cloudx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreenWithFallback extends StatefulWidget {
  @override
  _HomeScreenWithFallbackState createState() => _HomeScreenWithFallbackState();
}

class _HomeScreenWithFallbackState extends State<HomeScreenWithFallback> {
  bool _cloudxLoaded = false;
  bool _fallbackLoaded = false;
  BannerAd? _admobBanner;

  @override
  void initState() {
    super.initState();
    // CloudX banner tries automatically (widget-based)
  }

  void _loadAdMobBanner() {
    print('Loading AdMob fallback banner');
    _admobBanner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _fallbackLoaded = true;
            });
          }
          print('AdMob banner loaded as fallback');
        },
        onAdFailedToLoad: (ad, error) {
          print('AdMob banner also failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _admobBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          Expanded(
            child: Center(child: Text('Your content here')),
          ),

          // Try CloudX first
          if (!_fallbackLoaded)
            CloudXBannerView(
              placementName: 'banner_home',
              listener: CloudXAdViewListener(
                onAdLoaded: (ad) {
                  if (mounted) {
                    setState(() {
                      _cloudxLoaded = true;
                    });
                  }
                  print('CloudX banner loaded');
                },
                onAdLoadFailed: (error) {
                  print('CloudX failed: $error');
                  _loadAdMobBanner();  // Trigger fallback
                },
              ),
            ),

          // Show AdMob fallback if CloudX failed
          if (_fallbackLoaded && _admobBanner != null)
            Container(
              height: 50,
              child: AdWidget(ad: _admobBanner!),
            ),
        ],
      ),
    );
  }
}
```

### Programmatic Approach

**Use when**: You need overlay banners or custom positioning

#### CloudX-Only

```dart
class ProgrammaticBannerScreen extends StatefulWidget {
  @override
  _ProgrammaticBannerScreenState createState() => _ProgrammaticBannerScreenState();
}

class _ProgrammaticBannerScreenState extends State<ProgrammaticBannerScreen> {
  String? _bannerAdId;
  bool _isBannerShowing = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    _bannerAdId = await CloudX.createBanner(
      placementName: 'banner_overlay',
      listener: CloudXAdViewListener(
        onAdLoaded: (ad) {
          print('Banner ready');
          _showBanner();
        },
        onAdLoadFailed: (error) {
          print('Failed to load: $error');
        },
      ),
      position: AdViewPosition.bottomCenter, // Overlay position
    );

    if (_bannerAdId != null) {
      await CloudX.loadBanner(adId: _bannerAdId!);
    }
  }

  Future<void> _showBanner() async {
    if (_bannerAdId != null) {
      final success = await CloudX.showBanner(adId: _bannerAdId!);
      if (success && mounted) {
        setState(() {
          _isBannerShowing = true;
        });
      }
    }
  }

  Future<void> _hideBanner() async {
    if (_bannerAdId != null) {
      await CloudX.hideBanner(adId: _bannerAdId!);
      if (mounted) {
        setState(() {
          _isBannerShowing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_bannerAdId != null) {
      CloudX.stopAutoRefresh(adId: _bannerAdId!);  // Stop refresh first
      CloudX.destroyAd(adId: _bannerAdId!);  // Then destroy
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Programmatic Banner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Content here'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isBannerShowing ? _hideBanner : _showBanner,
              child: Text(_isBannerShowing ? 'Hide Banner' : 'Show Banner'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Interstitial Ads

### CloudX-Only

```dart
class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? _interstitialAdId;
  bool _isInterstitialReady = false;
  int _gameScore = 0;

  @override
  void initState() {
    super.initState();
    _loadInterstitial();
  }

  Future<void> _loadInterstitial() async {
    _interstitialAdId = await CloudX.createInterstitial(
      placementName: 'interstitial_level_complete',
      listener: CloudXInterstitialListener(
        onAdLoaded: (ad) {
          print('Interstitial ready');
          if (mounted) {
            setState(() {
              _isInterstitialReady = true;
            });
          }
        },
        onAdLoadFailed: (error) {
          print('Interstitial failed: $error');
        },
        onAdDisplayed: (ad) {
          print('Interstitial showing');
        },
        onAdHidden: (ad) {
          print('Interstitial closed');
          _isInterstitialReady = false;
          _loadInterstitial();  // Reload for next time
        },
        onAdClicked: (ad) {
          print('Interstitial clicked');
        },
      ),
    );

    if (_interstitialAdId != null) {
      await CloudX.loadInterstitial(adId: _interstitialAdId!);
    }
  }

  Future<void> _showInterstitialIfReady() async {
    if (_interstitialAdId == null) {
      print('Interstitial not created yet');
      return;
    }

    final isReady = await CloudX.isInterstitialReady(adId: _interstitialAdId!);
    if (isReady) {
      await CloudX.showInterstitial(adId: _interstitialAdId!);
    } else {
      print('Interstitial not ready yet');
    }
  }

  void _onLevelComplete() {
    setState(() {
      _gameScore += 100;
    });
    _showInterstitialIfReady();  // Show ad after level
  }

  @override
  void dispose() {
    if (_interstitialAdId != null) {
      CloudX.destroyAd(adId: _interstitialAdId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game - Score: $_gameScore')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Play your game here'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onLevelComplete,
              child: Text('Complete Level'),
            ),
            SizedBox(height: 10),
            Text(
              _isInterstitialReady ? 'Ad Ready' : 'Ad Loading...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

### CloudX-First with AdMob Fallback

```dart
class GameScreenWithFallback extends StatefulWidget {
  @override
  _GameScreenWithFallbackState createState() => _GameScreenWithFallbackState();
}

class _GameScreenWithFallbackState extends State<GameScreenWithFallback> {
  String? _cloudxInterstitialId;
  InterstitialAd? _admobInterstitial;
  bool _cloudxReady = false;
  bool _admobReady = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitials();
  }

  Future<void> _loadInterstitials() async {
    // Try CloudX first
    _cloudxInterstitialId = await CloudX.createInterstitial(
      placementName: 'interstitial_main',
      listener: CloudXInterstitialListener(
        onAdLoaded: (ad) {
          print('CloudX interstitial ready');
          if (mounted) {
            setState(() {
              _cloudxReady = true;
            });
          }
        },
        onAdLoadFailed: (error) {
          print('CloudX failed: $error, loading AdMob fallback');
          _loadAdMobInterstitial();  // Trigger fallback
        },
        onAdHidden: (ad) {
          _cloudxReady = false;
          _loadInterstitials();  // Reload for next time
        },
      ),
    );

    if (_cloudxInterstitialId != null) {
      await CloudX.loadInterstitial(adId: _cloudxInterstitialId!);
    }
  }

  Future<void> _loadAdMobInterstitial() async {
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _admobInterstitial = ad;
          if (mounted) {
            setState(() {
              _admobReady = true;
            });
          }
          print('AdMob interstitial loaded as fallback');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _admobReady = false;
              _loadInterstitials();  // Reload for next time
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('AdMob interstitial also failed: $error');
        },
      ),
    );
  }

  Future<void> _showInterstitial() async {
    // Try CloudX first
    if (_cloudxReady && _cloudxInterstitialId != null) {
      final isReady = await CloudX.isInterstitialReady(adId: _cloudxInterstitialId!);
      if (isReady) {
        await CloudX.showInterstitial(adId: _cloudxInterstitialId!);
        return;
      }
    }

    // Fall back to AdMob
    if (_admobReady && _admobInterstitial != null) {
      await _admobInterstitial!.show();
      return;
    }

    print('No interstitial ready to show');
  }

  @override
  void dispose() {
    if (_cloudxInterstitialId != null) {
      CloudX.destroyAd(adId: _cloudxInterstitialId!);
    }
    _admobInterstitial?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game with Fallback')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your game here'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showInterstitial,
              child: Text('Show Interstitial'),
            ),
            SizedBox(height: 10),
            Text(
              _cloudxReady ? 'CloudX Ready' :
              _admobReady ? 'AdMob Ready' : 'Loading...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## MREC Ads

MREC (Medium Rectangle, 300x250) ads work similarly to banners.

### Widget-Based MREC

```dart
class MRECScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MREC Ad')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.blue[100],
              child: Center(child: Text('Content above')),
            ),

            // MREC ad in content
            CloudXMRECView(
              placementName: 'mrec_main',
              listener: CloudXAdViewListener(
                onAdLoaded: (ad) => print('MREC loaded'),
                onAdLoadFailed: (error) => print('MREC failed: $error'),
              ),
            ),

            Container(
              height: 400,
              color: Colors.green[100],
              child: Center(child: Text('Content below')),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Programmatic MREC

```dart
class ProgrammaticMRECScreen extends StatefulWidget {
  @override
  _ProgrammaticMRECScreenState createState() => _ProgrammaticMRECScreenState();
}

class _ProgrammaticMRECScreenState extends State<ProgrammaticMRECScreen> {
  String? _mrecAdId;

  @override
  void initState() {
    super.initState();
    _loadMREC();
  }

  Future<void> _loadMREC() async {
    _mrecAdId = await CloudX.createMREC(
      placementName: 'mrec_overlay',
      listener: CloudXAdViewListener(
        onAdLoaded: (ad) {
          print('MREC ready');
          _showMREC();
        },
        onAdLoadFailed: (error) {
          print('MREC failed: $error');
        },
      ),
      position: AdViewPosition.centered,  // Overlay position
    );

    if (_mrecAdId != null) {
      await CloudX.loadMREC(adId: _mrecAdId!);
    }
  }

  Future<void> _showMREC() async {
    if (_mrecAdId != null) {
      await CloudX.showMREC(adId: _mrecAdId!);
    }
  }

  @override
  void dispose() {
    if (_mrecAdId != null) {
      CloudX.stopAutoRefresh(adId: _mrecAdId!);
      CloudX.destroyAd(adId: _mrecAdId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Programmatic MREC')),
      body: Center(
        child: Text('MREC will overlay on this content'),
      ),
    );
  }
}
```

---

## Fallback Patterns

### Pattern 1: Manager Class (Recommended)

Encapsulate ad logic in a dedicated manager:

```dart
class BannerAdManager {
  bool _cloudxLoaded = false;
  bool _fallbackLoaded = false;
  BannerAd? _admobBanner;
  VoidCallback? _onAdLoaded;

  BannerAdManager({VoidCallback? onAdLoaded}) : _onAdLoaded = onAdLoaded;

  Widget buildCloudXBanner(String placementName) {
    return CloudXBannerView(
      placementName: placementName,
      listener: CloudXAdViewListener(
        onAdLoaded: (ad) {
          _cloudxLoaded = true;
          _onAdLoaded?.call();
          print('CloudX banner loaded');
        },
        onAdLoadFailed: (error) {
          print('CloudX failed, loading AdMob');
          _loadAdMobBanner();
        },
      ),
    );
  }

  void _loadAdMobBanner() {
    _admobBanner = BannerAd(
      adUnitId: 'YOUR_ADMOB_UNIT_ID',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _fallbackLoaded = true;
          _onAdLoaded?.call();
          print('AdMob banner loaded as fallback');
        },
      ),
    )..load();
  }

  Widget? buildFallbackBanner() {
    if (_fallbackLoaded && _admobBanner != null) {
      return Container(
        height: 50,
        child: AdWidget(ad: _admobBanner!),
      );
    }
    return null;
  }

  bool get hasAdLoaded => _cloudxLoaded || _fallbackLoaded;

  void dispose() {
    _admobBanner?.dispose();
  }
}

// Usage:
class ScreenWithManager extends StatefulWidget {
  @override
  _ScreenWithManagerState createState() => _ScreenWithManagerState();
}

class _ScreenWithManagerState extends State<ScreenWithManager> {
  late BannerAdManager _adManager;
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();
    _adManager = BannerAdManager(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _showFallback = !_adManager._cloudxLoaded;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Text('Content')),
          if (!_showFallback)
            _adManager.buildCloudXBanner('banner_home'),
          if (_showFallback)
            _adManager.buildFallbackBanner() ?? SizedBox.shrink(),
        ],
      ),
    );
  }
}
```

### Pattern 2: Fallback with AppLovin

```dart
import 'package:applovin_max/applovin_max.dart';

class AppLovinFallbackManager {
  String? _cloudxAdId;
  bool _cloudxReady = false;
  bool _appLovinReady = false;
  String _appLovinAdUnitId = 'YOUR_APPLOVIN_UNIT_ID';

  Future<void> loadInterstitial() async {
    // Try CloudX first
    _cloudxAdId = await CloudX.createInterstitial(
      placementName: 'interstitial_main',
      listener: CloudXInterstitialListener(
        onAdLoaded: (ad) {
          _cloudxReady = true;
        },
        onAdLoadFailed: (error) {
          print('CloudX failed, loading AppLovin');
          _loadAppLovinInterstitial();
        },
      ),
    );

    if (_cloudxAdId != null) {
      await CloudX.loadInterstitial(adId: _cloudxAdId!);
    }
  }

  Future<void> _loadAppLovinInterstitial() async {
    await AppLovinMAX.loadInterstitial(_appLovinAdUnitId);

    // Note: AppLovin uses event listeners, set them up in init
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        _appLovinReady = true;
        print('AppLovin interstitial loaded as fallback');
      },
      onAdDisplayedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        _appLovinReady = false;
        loadInterstitial();  // Reload
      },
      onAdClickedCallback: (ad) {},
      onAdLoadFailedCallback: (adUnitId, error) {
        print('AppLovin also failed: ${error.message}');
      },
      onAdDisplayFailedCallback: (ad, error) {},
    ));
  }

  Future<void> show() async {
    // Try CloudX first
    if (_cloudxReady && _cloudxAdId != null) {
      final isReady = await CloudX.isInterstitialReady(adId: _cloudxAdId!);
      if (isReady) {
        await CloudX.showInterstitial(adId: _cloudxAdId!);
        return;
      }
    }

    // Fall back to AppLovin
    if (_appLovinReady) {
      final isReady = (await AppLovinMAX.isInterstitialReady(_appLovinAdUnitId))!;
      if (isReady) {
        await AppLovinMAX.showInterstitial(_appLovinAdUnitId);
        return;
      }
    }

    print('No interstitial ready');
  }

  void dispose() {
    if (_cloudxAdId != null) {
      CloudX.destroyAd(adId: _cloudxAdId!);
    }
  }
}
```

---

## Lifecycle Management

### Critical Rules

1. **Widget-based ads** (CloudXBannerView, CloudXMRECView): Lifecycle auto-managed ✅
2. **Programmatic ads**: Must call `destroyAd()` in `dispose()` ⚠️
3. **Auto-refresh**: Must call `stopAutoRefresh()` before `destroyAd()` ⚠️
4. **mounted check**: Always check `mounted` before `setState()` ⚠️

### Complete Lifecycle Example

```dart
class CompleteLifecycleScreen extends StatefulWidget {
  @override
  _CompleteLifecycleScreenState createState() => _CompleteLifecycleScreenState();
}

class _CompleteLifecycleScreenState extends State<CompleteLifecycleScreen>
    with WidgetsBindingObserver {
  String? _bannerAdId;
  String? _interstitialAdId;
  bool _isBannerShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAds();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background
      _pauseAds();
    } else if (state == AppLifecycleState.resumed) {
      // App coming to foreground
      _resumeAds();
    }
  }

  Future<void> _initAds() async {
    await _loadBanner();
    await _loadInterstitial();
  }

  Future<void> _loadBanner() async {
    _bannerAdId = await CloudX.createBanner(
      placementName: 'banner_lifecycle',
      listener: CloudXAdViewListener(
        onAdLoaded: (ad) {
          print('Banner ready');
          _showBanner();
        },
      ),
      position: AdViewPosition.bottomCenter,
    );

    if (_bannerAdId != null) {
      await CloudX.loadBanner(adId: _bannerAdId!);
    }
  }

  Future<void> _showBanner() async {
    if (_bannerAdId != null && !_isBannerShowing) {
      await CloudX.showBanner(adId: _bannerAdId!);
      await CloudX.startAutoRefresh(adId: _bannerAdId!);
      if (mounted) {
        setState(() {
          _isBannerShowing = true;
        });
      }
    }
  }

  Future<void> _loadInterstitial() async {
    _interstitialAdId = await CloudX.createInterstitial(
      placementName: 'interstitial_lifecycle',
      listener: CloudXInterstitialListener(
        onAdLoaded: (ad) => print('Interstitial ready'),
        onAdHidden: (ad) {
          // Reload after showing
          _loadInterstitial();
        },
      ),
    );

    if (_interstitialAdId != null) {
      await CloudX.loadInterstitial(adId: _interstitialAdId!);
    }
  }

  void _pauseAds() {
    // Stop auto-refresh when app goes to background
    if (_bannerAdId != null) {
      CloudX.stopAutoRefresh(adId: _bannerAdId!);
    }
  }

  void _resumeAds() {
    // Resume auto-refresh when app comes to foreground
    if (_bannerAdId != null && _isBannerShowing) {
      CloudX.startAutoRefresh(adId: _bannerAdId!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Clean up banner
    if (_bannerAdId != null) {
      CloudX.stopAutoRefresh(adId: _bannerAdId!);  // Stop first
      CloudX.destroyAd(adId: _bannerAdId!);  // Then destroy
    }

    // Clean up interstitial
    if (_interstitialAdId != null) {
      CloudX.destroyAd(adId: _interstitialAdId!);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lifecycle Management')),
      body: Center(
        child: Text('Ads managed with full lifecycle'),
      ),
    );
  }
}
```

---

## State Management Integration

### With Provider

```dart
import 'package:provider/provider.dart';

class AdProvider extends ChangeNotifier {
  String? _interstitialAdId;
  bool _isInterstitialReady = false;

  bool get isInterstitialReady => _isInterstitialReady;

  Future<void> loadInterstitial() async {
    _interstitialAdId = await CloudX.createInterstitial(
      placementName: 'interstitial_provider',
      listener: CloudXInterstitialListener(
        onAdLoaded: (ad) {
          _isInterstitialReady = true;
          notifyListeners();
        },
        onAdHidden: (ad) {
          _isInterstitialReady = false;
          notifyListeners();
          loadInterstitial();  // Reload
        },
      ),
    );

    if (_interstitialAdId != null) {
      await CloudX.loadInterstitial(adId: _interstitialAdId!);
    }
  }

  Future<void> showInterstitial() async {
    if (_interstitialAdId != null && _isInterstitialReady) {
      final isReady = await CloudX.isInterstitialReady(adId: _interstitialAdId!);
      if (isReady) {
        await CloudX.showInterstitial(adId: _interstitialAdId!);
      }
    }
  }

  void dispose() {
    if (_interstitialAdId != null) {
      CloudX.destroyAd(adId: _interstitialAdId!);
    }
    super.dispose();
  }
}

// Usage:
class GameScreenWithProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdProvider>(
      builder: (context, adProvider, child) {
        return Scaffold(
          body: Center(
            child: Column(
              children: [
                Text('Game content'),
                ElevatedButton(
                  onPressed: adProvider.isInterstitialReady
                      ? () => adProvider.showInterstitial()
                      : null,
                  child: Text('Show Ad'),
                ),
                Text(
                  adProvider.isInterstitialReady ? 'Ready' : 'Loading...',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// In main.dart:
runApp(
  ChangeNotifierProvider(
    create: (_) => AdProvider()..loadInterstitial(),
    child: MyApp(),
  ),
);
```

### With Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterstitialAdNotifier extends StateNotifier<bool> {
  InterstitialAdNotifier() : super(false) {
    _loadInterstitial();
  }

  String? _adId;

  Future<void> _loadInterstitial() async {
    _adId = await CloudX.createInterstitial(
      placementName: 'interstitial_riverpod',
      listener: CloudXInterstitialListener(
        onAdLoaded: (ad) {
          state = true;  // Ready
        },
        onAdHidden: (ad) {
          state = false;  // Not ready
          _loadInterstitial();
        },
      ),
    );

    if (_adId != null) {
      await CloudX.loadInterstitial(adId: _adId!);
    }
  }

  Future<void> show() async {
    if (_adId != null && state) {
      final isReady = await CloudX.isInterstitialReady(adId: _adId!);
      if (isReady) {
        await CloudX.showInterstitial(adId: _adId!);
      }
    }
  }

  @override
  void dispose() {
    if (_adId != null) {
      CloudX.destroyAd(adId: _adId!);
    }
    super.dispose();
  }
}

final interstitialProvider = StateNotifierProvider<InterstitialAdNotifier, bool>((ref) {
  return InterstitialAdNotifier();
});

// Usage:
class GameScreenWithRiverpod extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = ref.watch(interstitialProvider);

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: isReady
              ? () => ref.read(interstitialProvider.notifier).show()
              : null,
          child: Text(isReady ? 'Show Ad' : 'Loading...'),
        ),
      ),
    );
  }
}
```

---

## Privacy Compliance

### CCPA (California)

```dart
Future<void> setupPrivacy() async {
  // Get user's CCPA consent choice
  bool userOptedOut = await getUserCCPAChoice();

  // CCPA string format: "1YNN"
  // 1 = Version
  // Y/N = Do not sell
  // N = LSPA covered
  // N = Opt out sharing
  String ccpaString = userOptedOut ? '1YNN' : '1NNN';

  await CloudX.setCCPAPrivacyString(ccpaString);
}
```

### GPP (Global Privacy Platform)

```dart
Future<void> setupGPP() async {
  // Get GPP consent string from IAB CMP
  String? gppString = await getGPPConsentString();
  List<int> gppSid = [7, 8];  // US-National, US-CA

  if (gppString != null) {
    await CloudX.setGPPString(gppString);
    await CloudX.setGPPSid(gppSid);
  }
}
```

### COPPA (Children's Privacy)

```dart
Future<void> setupCOPPA() async {
  // For child-directed apps
  await CloudX.setIsAgeRestrictedUser(true);

  // OR dynamically based on user age
  bool isChild = await isUserUnder13();
  await CloudX.setIsAgeRestrictedUser(isChild);
}
```

### Complete Privacy Setup

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Set privacy FIRST
  await setupPrivacy();
  await setupGPP();
  await setupCOPPA();

  // 2. THEN initialize SDK
  await CloudX.initialize(
    appKey: 'YOUR_APP_KEY',
    allowIosExperimental: true,
  );

  // 3. Then other SDKs
  // await MobileAds.instance.initialize();

  runApp(MyApp());
}
```

---

## Testing Strategies

### Test 1: CloudX Integration

```dart
void testCloudXIntegration() {
  print('Testing CloudX integration...');

  // Check initialization
  // Look for: "CloudX SDK initialized successfully"

  // Load test banner
  // Check: onAdLoaded callback fires

  // Load test interstitial
  // Check: onAdLoaded callback fires
  // Check: isInterstitialReady returns true
}
```

### Test 2: Fallback Logic (If Applicable)

```dart
void testFallbackLogic() {
  print('Testing fallback logic...');

  // Enable airplane mode
  // Try to load CloudX ad
  // Verify: onAdLoadFailed fires
  // Verify: Fallback SDK loads
  // Disable airplane mode
  // Try again
  // Verify: CloudX loads successfully
}
```

### Test 3: Lifecycle Management

```dart
void testLifecycle() {
  print('Testing lifecycle...');

  // Navigate to screen with ads
  // Verify: Ads load
  // Navigate away
  // Verify: dispose() called, no crashes
  // Navigate back
  // Verify: Ads reload
  // Check DevTools for memory leaks
}
```

---

## Common Patterns

### Pattern: Retry on Failure

```dart
class RetryAdManager {
  int _retryCount = 0;
  final int _maxRetries = 3;
  String? _adId;

  Future<void> loadWithRetry() async {
    _adId = await CloudX.createInterstitial(
      placementName: 'interstitial_retry',
      listener: CloudXInterstitialListener(
        onAdLoadFailed: (error) {
          if (_retryCount < _maxRetries) {
            _retryCount++;
            print('Retry attempt $_retryCount');
            Future.delayed(Duration(seconds: 2), loadWithRetry);
          }
        },
        onAdLoaded: (ad) {
          _retryCount = 0;  // Reset on success
        },
      ),
    );

    if (_adId != null) {
      await CloudX.loadInterstitial(adId: _adId!);
    }
  }
}
```

### Pattern: Lazy Loading

```dart
class LazyAdLoader {
  String? _adId;
  bool _isLoading = false;
  bool _isLoaded = false;

  Future<void> loadIfNeeded() async {
    if (_isLoaded || _isLoading) return;

    _isLoading = true;
    _adId = await CloudX.createInterstitial(
      placementName: 'interstitial_lazy',
      listener: CloudXInterstitialListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          _isLoading = false;
        },
        onAdLoadFailed: (error) {
          _isLoading = false;
        },
      ),
    );

    if (_adId != null) {
      await CloudX.loadInterstitial(adId: _adId!);
    }
  }

  Future<void> showIfLoaded() async {
    if (!_isLoaded) {
      await loadIfNeeded();
    }

    if (_adId != null && _isLoaded) {
      final isReady = await CloudX.isInterstitialReady(adId: _adId!);
      if (isReady) {
        await CloudX.showInterstitial(adId: _adId!);
        _isLoaded = false;  // Need to reload after showing
      }
    }
  }
}
```

---

## Troubleshooting

### Issue: "setState() called after dispose()"

**Fix**:
```dart
if (mounted) {
  setState(() { ... });
}
```

### Issue: Memory leaks

**Fix**: Always destroy ads in dispose():
```dart
@override
void dispose() {
  if (_adId != null) {
    CloudX.destroyAd(adId: _adId!);
  }
  super.dispose();
}
```

### Issue: Ads not loading

**Debug**:
```dart
CloudXAdViewListener(
  onAdLoadFailed: (error) {
    print('Detailed error: $error');  // Check exact error
  },
)
```

**Common causes**:
- Invalid placement name
- Invalid app key
- No internet
- No ad inventory

---

## Next Steps

1. **Test your integration thoroughly**
2. **Run agents for validation**:
   ```
   Use cloudx-flutter-auditor to verify integration
   Use cloudx-flutter-build-verifier to build project
   Use cloudx-flutter-privacy-checker for compliance
   ```
3. **Read [Orchestration Guide](./ORCHESTRATION.md)** for multi-agent workflows
4. **Deploy to production**

---

**Questions?** Open an issue: https://github.com/cloudx-io/cloudx-sdk-agents/issues
