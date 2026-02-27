import 'package:flutter/material.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';

/// Inline IMA SDK video ad card for use in ListView feeds.
/// Shows a 16:9 native ad container with Ad badge and progress bar.
class ImaAdCard extends StatefulWidget {
  const ImaAdCard({super.key});

  @override
  State<ImaAdCard> createState() => _ImaAdCardState();
}

class _ImaAdCardState extends State<ImaAdCard> with WidgetsBindingObserver {
  late final AdsLoader _adsLoader;
  AdsManager? _adsManager;
  bool _adFailed = false;
  bool _adLoaded = false;

  late final AdDisplayContainer _adDisplayContainer = AdDisplayContainer(
    onContainerAdded: (AdDisplayContainer container) {
      final adTagUrl = ImaAdManager.instance.directFeedAdTagUrl;
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
                debugPrint('[ImaCard] AdEvent: ${event.type}');
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
                debugPrint('[ImaCard] AdError: ${event.error.message}');
                if (mounted) setState(() => _adFailed = true);
              },
            ),
          );

          manager.init(
            settings: AdsRenderingSettings(enablePreloading: true),
          );
        },
        onAdsLoadError: (AdsLoadErrorData data) {
          debugPrint('[ImaCard] LoadError: ${data.error.message}');
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
    if (state == AppLifecycleState.inactive) {
      _adsManager?.pause();
    } else if (state == AppLifecycleState.resumed && !_adFailed) {
      _adsManager?.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adsManager?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adFailed) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
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
              top: 8,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Ad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
