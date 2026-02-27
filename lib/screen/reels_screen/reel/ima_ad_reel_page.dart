import 'package:flutter/material.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';

/// Full-screen IMA SDK video ad page for the reel feed.
/// Uses Google's native IMA SDK which sends GAID + app signals for AdMob demand.
class ImaAdReelPage extends StatefulWidget {
  const ImaAdReelPage({super.key});

  @override
  State<ImaAdReelPage> createState() => _ImaAdReelPageState();
}

class _ImaAdReelPageState extends State<ImaAdReelPage>
    with WidgetsBindingObserver {
  late final AdsLoader _adsLoader;
  AdsManager? _adsManager;
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;
  bool _adFailed = false;
  bool _adLoaded = false;

  late final AdDisplayContainer _adDisplayContainer = AdDisplayContainer(
    onContainerAdded: (AdDisplayContainer container) {
      final adTagUrl =
          ImaAdManager.instance.getDirectAdTagUrl(ImaAdPlacement.preRoll);
      if (adTagUrl == null || adTagUrl.isEmpty) {
        if (mounted) setState(() => _adFailed = true);
        return;
      }

      _adsLoader = AdsLoader(
        container: container,
        onAdsLoaded: (OnAdsLoadedData data) {
          final AdsManager manager = data.manager;
          _adsManager = manager;

          manager.setAdsManagerDelegate(
            AdsManagerDelegate(
              onAdEvent: (AdEvent event) {
                debugPrint('[ImaReel] AdEvent: ${event.type}');
                switch (event.type) {
                  case AdEventType.loaded:
                    manager.start();
                    if (mounted) setState(() => _adLoaded = true);
                  case AdEventType.allAdsCompleted:
                    manager.destroy();
                    _adsManager = null;
                  default:
                    break;
                }
              },
              onAdErrorEvent: (AdErrorEvent event) {
                debugPrint('[ImaReel] AdError: ${event.error.message}');
                if (mounted) setState(() => _adFailed = true);
              },
            ),
          );

          manager.init(
            settings: AdsRenderingSettings(enablePreloading: true),
          );
        },
        onAdsLoadError: (AdsLoadErrorData data) {
          debugPrint('[ImaReel] LoadError: ${data.error.message}');
          if (mounted) setState(() => _adFailed = true);
        },
      );

      _adsLoader.requestAds(
        AdsRequest(
          adTagUrl: adTagUrl,
          contentProgressProvider: ContentProgressProvider(),
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive &&
        _lastLifecycleState == AppLifecycleState.resumed) {
      _adsManager?.pause();
    } else if (state == AppLifecycleState.resumed && !_adFailed) {
      _adsManager?.resume();
    }
    _lastLifecycleState = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adsManager?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adFailed) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.swipe_up_rounded, color: Colors.white24, size: 48),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // IMA SDK renders the ad video into this container
          _adDisplayContainer,

          // Loading indicator before ad starts
          if (!_adLoaded)
            const Center(
              child: CircularProgressIndicator(
                  color: Colors.white38, strokeWidth: 2),
            ),

          // "Ad" badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
