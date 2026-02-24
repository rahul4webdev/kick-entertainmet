import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/call/call_model.dart';
import 'package:shortzz/screen/call_screen/call_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';

class CallScreen extends StatelessWidget {
  final IncomingCallData callData;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.callData,
    this.isOutgoing = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CallScreenController(callData: callData, isOutgoing: isOutgoing),
      tag: callData.roomId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Obx(() {
        final state = controller.callState.value;
        final isVideo = callData.isVideoCall;

        return Stack(
          children: [
            // Remote video (full screen)
            if (isVideo && controller.remoteVideoTrack.value != null && state == CallState.connected)
              Positioned.fill(
                child: VideoTrackRenderer(
                  controller.remoteVideoTrack.value!,
                  fit: VideoViewFit.cover,
                ),
              ),

            // Dark overlay for non-connected states or voice calls
            if (!isVideo || state != CallState.connected)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    ),
                  ),
                ),
              ),

            // Caller info (centered)
            if (state != CallState.connected || !isVideo)
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    CustomImage(
                      size: const Size(100, 100),
                      image: callData.callerProfile?.addBaseURL(),
                      fullName: callData.callerName,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      callData.callerName,
                      style: TextStyleCustom.unboundedSemiBold600(
                          color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      callData.callerUsername != null
                          ? '@${callData.callerUsername}'
                          : '',
                      style: TextStyleCustom.outFitRegular400(
                          color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    _CallStatusText(controller: controller),
                  ],
                ),
              ),

            // Connected voice call — show duration centered
            if (state == CallState.connected && !isVideo)
              Center(
                child: Obx(() => Text(
                      controller.callDuration.value,
                      style: TextStyleCustom.unboundedBold700(
                          color: Colors.white, fontSize: 48),
                    )),
              ),

            // Local video preview (small PIP)
            if (isVideo && controller.localVideoTrack.value != null && state == CallState.connected)
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: VideoTrackRenderer(
                      controller.localVideoTrack.value!,
                      fit: VideoViewFit.cover,
                      mirrorMode: VideoViewMirrorMode.mirror,
                    ),
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: state == CallState.incoming
                  ? _IncomingCallButtons(controller: controller)
                  : _ActiveCallButtons(
                      controller: controller, isVideo: isVideo),
            ),
          ],
        );
      }),
    );
  }
}

class _CallStatusText extends StatelessWidget {
  final CallScreenController controller;

  const _CallStatusText({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String text;
      switch (controller.callState.value) {
        case CallState.outgoing:
          text = LKey.calling.tr;
          break;
        case CallState.incoming:
          text = controller.callData.isVideoCall
              ? LKey.incomingVideoCall.tr
              : LKey.incomingVoiceCall.tr;
          break;
        case CallState.connected:
          text = controller.callDuration.value;
          break;
        case CallState.ended:
          text = LKey.callEnded.tr;
          break;
        default:
          text = LKey.connecting.tr;
      }
      return Text(
        text,
        style: TextStyleCustom.outFitLight300(
            color: Colors.white60, fontSize: 15),
      );
    });
  }
}

class _IncomingCallButtons extends StatelessWidget {
  final CallScreenController controller;

  const _IncomingCallButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CallActionButton(
          icon: Icons.call_end,
          color: Colors.red,
          label: LKey.declineCall.tr,
          onTap: controller.rejectCall,
        ),
        _CallActionButton(
          icon: Icons.call,
          color: Colors.green,
          label: LKey.acceptCall.tr,
          onTap: controller.answerCall,
        ),
      ],
    );
  }
}

class _ActiveCallButtons extends StatelessWidget {
  final CallScreenController controller;
  final bool isVideo;

  const _ActiveCallButtons({required this.controller, required this.isVideo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() => _CallActionButton(
              icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
              color: controller.isMuted.value ? Colors.red : Colors.white24,
              label: controller.isMuted.value ? 'Mute' : 'Mute',
              onTap: controller.toggleMute,
            )),
        if (isVideo)
          Obx(() => _CallActionButton(
                icon: controller.isCameraOn.value
                    ? Icons.videocam
                    : Icons.videocam_off,
                color: controller.isCameraOn.value
                    ? Colors.white24
                    : Colors.red,
                label: 'Camera',
                onTap: controller.toggleCamera,
              )),
        Obx(() => _CallActionButton(
              icon: controller.isSpeakerOn.value
                  ? Icons.volume_up
                  : Icons.volume_off,
              color: Colors.white24,
              label: 'Speaker',
              onTap: controller.toggleSpeaker,
            )),
        if (isVideo)
          _CallActionButton(
            icon: Icons.cameraswitch,
            color: Colors.white24,
            label: 'Flip',
            onTap: controller.switchCamera,
          ),
        _CallActionButton(
          icon: Icons.call_end,
          color: Colors.red,
          label: LKey.endCall.tr,
          onTap: controller.endCall,
        ),
      ],
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyleCustom.outFitRegular400(
                color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
