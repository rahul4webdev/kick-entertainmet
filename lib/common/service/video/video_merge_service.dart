import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/transition_picker_sheet.dart';

enum MergeMode { sequential, sideBySide, topBottom }

enum MergeAudio { mixBoth, videoAOnly, videoBOnly, muteAll }

class VideoMergeService {
  static final shared = VideoMergeService();

  /// Merges two video files into a single MP4.
  /// Normalizes resolution to 1080x1920 (portrait) and concatenates.
  /// Returns the output file path on success, null on failure.
  Future<String?> mergeTwo({
    required String videoA,
    required String videoB,
    required String outputPath,
  }) async {
    try {
      // Try with audio first
      final withAudio = await _runMerge(
        videoA: videoA,
        videoB: videoB,
        outputPath: outputPath,
        includeAudio: true,
      );
      if (withAudio != null) return withAudio;

      // Fallback: video only (in case audio streams are incompatible)
      Loggers.warning('[VideoMerge] Retrying without audio');
      return _runMerge(
        videoA: videoA,
        videoB: videoB,
        outputPath: outputPath,
        includeAudio: false,
      );
    } catch (e) {
      Loggers.error('[VideoMerge] Error: $e');
      return null;
    }
  }

  /// Merges two videos with layout mode and per-video audio control.
  Future<String?> mergeTwoWithLayout({
    required String videoA,
    required String videoB,
    required String outputPath,
    required MergeMode mode,
    MergeAudio audio = MergeAudio.mixBoth,
  }) async {
    if (mode == MergeMode.sequential) {
      return mergeTwo(videoA: videoA, videoB: videoB, outputPath: outputPath);
    }
    try {
      final result = await _runSplitMerge(
        videoA: videoA,
        videoB: videoB,
        outputPath: outputPath,
        mode: mode,
        audio: audio,
      );
      if (result != null) return result;

      // Fallback: retry without audio if audio mixing failed
      if (audio != MergeAudio.muteAll) {
        Loggers.warning('[VideoMerge] Retrying split merge without audio');
        return _runSplitMerge(
          videoA: videoA,
          videoB: videoB,
          outputPath: outputPath,
          mode: mode,
          audio: MergeAudio.muteAll,
        );
      }
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] Split merge error: $e');
      return null;
    }
  }

  Future<String?> _runSplitMerge({
    required String videoA,
    required String videoB,
    required String outputPath,
    required MergeMode mode,
    required MergeAudio audio,
  }) async {
    final filter = StringBuffer();

    // Video scaling — crop-to-fill (scale up + center crop, no black bars)
    if (mode == MergeMode.sideBySide) {
      // Each video: half width (540), full height (1920)
      filter.write(
          '[0:v]scale=540:1920:force_original_aspect_ratio=increase,'
          'crop=540:1920,setsar=1[v0];');
      filter.write(
          '[1:v]scale=540:1920:force_original_aspect_ratio=increase,'
          'crop=540:1920,setsar=1[v1];');
      filter.write('[v0][v1]hstack=inputs=2[outv]');
    } else {
      // Top-Bottom: full width (1080), half height (960)
      filter.write(
          '[0:v]scale=1080:960:force_original_aspect_ratio=increase,'
          'crop=1080:960,setsar=1[v0];');
      filter.write(
          '[1:v]scale=1080:960:force_original_aspect_ratio=increase,'
          'crop=1080:960,setsar=1[v1];');
      filter.write('[v0][v1]vstack=inputs=2[outv]');
    }

    // Audio handling
    String maps;
    switch (audio) {
      case MergeAudio.mixBoth:
        filter.write(';[0:a][1:a]amix=inputs=2:duration=longest:'
            'dropout_transition=2[outa]');
        maps = '-map "[outv]" -map "[outa]" -shortest '
            '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k';
        break;
      case MergeAudio.videoAOnly:
        maps = '-map "[outv]" -map 0:a -shortest '
            '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k';
        break;
      case MergeAudio.videoBOnly:
        maps = '-map "[outv]" -map 1:a -shortest '
            '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k';
        break;
      case MergeAudio.muteAll:
        maps = '-map "[outv]" -an -shortest '
            '-c:v libx264 -preset ultrafast -crf 23';
        break;
    }

    final command =
        '-i "$videoA" -i "$videoB" -filter_complex "${filter.toString()}" $maps -y "$outputPath"';

    Loggers.info('[VideoMerge] Running FFmpeg split merge ($mode, $audio)');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      Loggers.success('[VideoMerge] Split merge successful: $outputPath');
      return outputPath;
    } else {
      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] FFmpeg split merge failed: $logs');
      return null;
    }
  }

  Future<String?> _runMerge({
    required String videoA,
    required String videoB,
    required String outputPath,
    required bool includeAudio,
  }) async {
    final filter = StringBuffer();
    filter.write(
        '[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
        'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v0];');
    filter.write(
        '[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
        'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v1];');

    String maps;
    if (includeAudio) {
      filter.write(
          '[0:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo[a0];');
      filter.write(
          '[1:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo[a1];');
      filter.write('[v0][a0][v1][a1]concat=n=2:v=1:a=1[outv][outa]');
      maps = '-map "[outv]" -map "[outa]" -c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k';
    } else {
      filter.write('[v0][v1]concat=n=2:v=1:a=0[outv]');
      maps = '-map "[outv]" -an -c:v libx264 -preset ultrafast -crf 23';
    }

    final command =
        '-i "$videoA" -i "$videoB" -filter_complex "${filter.toString()}" $maps -y "$outputPath"';

    Loggers.info('[VideoMerge] Running FFmpeg merge');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      Loggers.success('[VideoMerge] Merge successful: $outputPath');
      return outputPath;
    } else {
      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] FFmpeg failed: $logs');
      return null;
    }
  }

  // ─── F2: Merge with transition (xfade) ───

  Future<String?> mergeTwoWithTransition({
    required String videoA,
    required String videoB,
    required String outputPath,
    required VideoTransition transition,
    double transitionDuration = 0.5,
  }) async {
    if (transition == VideoTransition.none) {
      return mergeTwo(videoA: videoA, videoB: videoB, outputPath: outputPath);
    }

    try {
      // Get duration of first video to calculate xfade offset
      final probeSess = await FFmpegKit.execute(
          '-i "$videoA" -f null -');
      final probeLog = await probeSess.getLogsAsString();
      final durationMatch =
          RegExp(r'Duration: (\d+):(\d+):(\d+)\.(\d+)').firstMatch(probeLog ?? '');

      double videoADuration = 5.0; // fallback
      if (durationMatch != null) {
        videoADuration = int.parse(durationMatch.group(1)!) * 3600 +
            int.parse(durationMatch.group(2)!) * 60 +
            int.parse(durationMatch.group(3)!) +
            int.parse(durationMatch.group(4)!) / 100;
      }

      final offset = (videoADuration - transitionDuration).clamp(0.1, 9999.0);

      final filter = StringBuffer();
      filter.write(
          '[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
          'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v0];');
      filter.write(
          '[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
          'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v1];');
      filter.write(
          '[v0][v1]xfade=transition=${transition.ffmpegName}:'
          'duration=$transitionDuration:offset=$offset[outv]');

      // Audio crossfade
      filter.write(';[0:a][1:a]acrossfade=d=$transitionDuration:c1=tri:c2=tri[outa]');

      final command =
          '-i "$videoA" -i "$videoB" -filter_complex "${filter.toString()}" '
          '-map "[outv]" -map "[outa]" '
          '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -y "$outputPath"';

      Loggers.info('[VideoMerge] Running xfade merge (${transition.ffmpegName})');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Loggers.success('[VideoMerge] Transition merge successful');
        return outputPath;
      }

      // Fallback: try without audio crossfade
      Loggers.warning('[VideoMerge] Retrying transition without audio crossfade');
      final filter2 = StringBuffer();
      filter2.write(
          '[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
          'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v0];');
      filter2.write(
          '[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
          'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v1];');
      filter2.write(
          '[v0][v1]xfade=transition=${transition.ffmpegName}:'
          'duration=$transitionDuration:offset=$offset[outv]');

      final cmd2 =
          '-i "$videoA" -i "$videoB" -filter_complex "${filter2.toString()}" '
          '-map "[outv]" -an '
          '-c:v libx264 -preset ultrafast -crf 23 -y "$outputPath"';

      final s2 = await FFmpegKit.execute(cmd2);
      final rc2 = await s2.getReturnCode();
      if (ReturnCode.isSuccess(rc2)) return outputPath;

      final logs = await s2.getLogsAsString();
      Loggers.error('[VideoMerge] Transition merge failed: $logs');
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] Transition merge error: $e');
      return null;
    }
  }

  // ─── F5: Speed Ramp ───

  Future<String?> applySpeedRamp({
    required String inputPath,
    required String outputPath,
    required List<Map<String, dynamic>> segments,
    required double totalDuration,
  }) async {
    try {
      // Build setpts expression for variable speed
      final pts = StringBuffer("setpts='");
      bool first = true;

      for (final seg in segments) {
        final start = (seg['startFrac'] as double) * totalDuration;
        final end = (seg['endFrac'] as double) * totalDuration;
        final speed = seg['speed'] as double;

        if (!first) {
          pts.write('+');
        }
        pts.write('if(between(T,$start,$end),(T-$start)/${speed.toStringAsFixed(2)},0)');
        first = false;
      }
      pts.write("'");

      // Build atempo chain for audio
      String atempoFilter = '';
      if (segments.length == 1) {
        atempoFilter = _buildAtempoChain(segments.first['speed'] as double);
      }

      String command;
      if (atempoFilter.isNotEmpty) {
        command =
            '-i "$inputPath" -filter_complex '
            '"[0:v]${pts.toString()}[outv];[0:a]$atempoFilter[outa]" '
            '-map "[outv]" -map "[outa]" '
            '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -y "$outputPath"';
      } else {
        // For multi-segment, apply uniform average speed to audio
        final avgSpeed = segments.fold<double>(0, (s, seg) =>
                s + (seg['speed'] as double) * ((seg['endFrac'] as double) - (seg['startFrac'] as double))) /
            segments.fold<double>(0, (s, seg) =>
                s + ((seg['endFrac'] as double) - (seg['startFrac'] as double)));
        final audioChain = _buildAtempoChain(avgSpeed);

        command =
            '-i "$inputPath" -filter_complex '
            '"[0:v]${pts.toString()}[outv];[0:a]$audioChain[outa]" '
            '-map "[outv]" -map "[outa]" '
            '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -y "$outputPath"';
      }

      Loggers.info('[VideoMerge] Applying speed ramp');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Loggers.success('[VideoMerge] Speed ramp applied');
        return outputPath;
      }

      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] Speed ramp failed: $logs');
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] Speed ramp error: $e');
      return null;
    }
  }

  String _buildAtempoChain(double speed) {
    // atempo only supports 0.5 to 100.0; chain for extreme values
    final chain = <String>[];
    double remaining = speed.clamp(0.25, 4.0);
    while (remaining < 0.5) {
      chain.add('atempo=0.5');
      remaining *= 2;
    }
    while (remaining > 2.0) {
      chain.add('atempo=2.0');
      remaining /= 2;
    }
    chain.add('atempo=${remaining.toStringAsFixed(3)}');
    return chain.join(',');
  }

  // ─── F7: Mix sound effects at timestamps ───

  Future<String?> mixSoundEffects({
    required String inputPath,
    required String outputPath,
    required List<Map<String, dynamic>> effects,
  }) async {
    if (effects.isEmpty) return inputPath;

    try {
      final inputs = StringBuffer('-i "$inputPath" ');
      final filter = StringBuffer();

      for (int i = 0; i < effects.length; i++) {
        final asset = effects[i]['asset'] as String;
        inputs.write('-i "$asset" ');

        final timestampMs = effects[i]['timestampMs'] as int;
        filter.write('[${i + 1}:a]adelay=$timestampMs|$timestampMs[s$i];');
      }

      // Mix all audio streams together
      filter.write('[0:a]');
      for (int i = 0; i < effects.length; i++) {
        filter.write('[s$i]');
      }
      filter.write('amix=inputs=${effects.length + 1}:duration=first:dropout_transition=2[outa]');

      final command =
          '${inputs.toString()}-filter_complex "${filter.toString()}" '
          '-map 0:v -map "[outa]" '
          '-c:v copy -c:a aac -b:a 128k -y "$outputPath"';

      Loggers.info('[VideoMerge] Mixing ${effects.length} sound effects');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Loggers.success('[VideoMerge] Sound effects mixed');
        return outputPath;
      }

      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] Sound effects failed: $logs');
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] Sound effects error: $e');
      return null;
    }
  }

  // ─── F8: Apply audio effect ───

  Future<String?> applyAudioEffect({
    required String inputPath,
    required String outputPath,
    required String ffmpegFilter,
  }) async {
    if (ffmpegFilter.isEmpty) return inputPath;

    try {
      final command =
          '-i "$inputPath" -af "$ffmpegFilter" '
          '-c:v copy -c:a aac -b:a 128k -y "$outputPath"';

      Loggers.info('[VideoMerge] Applying audio effect');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Loggers.success('[VideoMerge] Audio effect applied');
        return outputPath;
      }

      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] Audio effect failed: $logs');
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] Audio effect error: $e');
      return null;
    }
  }

  // ─── F10: Video Stabilization ───

  Future<String?> stabilizeVideo({
    required String inputPath,
    required String outputPath,
  }) async {
    try {
      final command =
          '-threads 0 -i "$inputPath" -vf "deshake=rx=32:ry=32:edge=1:blocksize=8:contrast=125" '
          '-c:a copy -c:v libx264 -preset ultrafast -crf 23 -threads 0 -y "$outputPath"';

      Loggers.info('[VideoMerge] Stabilizing video');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Loggers.success('[VideoMerge] Stabilization complete');
        return outputPath;
      }

      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] Stabilization failed: $logs');
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] Stabilization error: $e');
      return null;
    }
  }

  // ─── F13: Video Blend Overlay ───

  Future<String?> applyBlendOverlay({
    required String mainPath,
    required String overlayPath,
    required String outputPath,
    required String blendMode,
    double opacity = 0.5,
  }) async {
    try {
      final command =
          '-i "$mainPath" -i "$overlayPath" '
          '-filter_complex '
          '"[1:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920[ov];'
          '[0:v][ov]blend=all_mode=$blendMode:all_opacity=$opacity[outv]" '
          '-map "[outv]" -map 0:a? '
          '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -threads 0 -shortest -y "$outputPath"';

      Loggers.info('[VideoMerge] Applying blend mode: $blendMode');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Loggers.success('[VideoMerge] Blend overlay applied');
        return outputPath;
      }

      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] Blend overlay failed: $logs');
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] Blend overlay error: $e');
      return null;
    }
  }

  // ─── F9: Picture-in-Picture Overlay ───

  Future<String?> applyPiPOverlay({
    required String mainPath,
    required String pipPath,
    required String outputPath,
    String position = 'bottomRight',
  }) async {
    try {
      // Position mapping
      String overlay;
      switch (position) {
        case 'topLeft':
          overlay = 'overlay=30:30';
          break;
        case 'topRight':
          overlay = 'overlay=W-w-30:30';
          break;
        case 'bottomLeft':
          overlay = 'overlay=30:H-h-30';
          break;
        default: // bottomRight
          overlay = 'overlay=W-w-30:H-h-30';
          break;
      }

      final command =
          '-i "$mainPath" -i "$pipPath" '
          '-filter_complex '
          '"[1:v]scale=270:-1,crop=270:270[pip];'
          '[0:v][pip]$overlay:shortest=1[outv]" '
          '-map "[outv]" -map 0:a? '
          '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -threads 0 -y "$outputPath"';

      Loggers.info('[VideoMerge] Applying PiP overlay ($position)');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Loggers.success('[VideoMerge] PiP overlay applied');
        return outputPath;
      }

      final logs = await session.getLogsAsString();
      Loggers.error('[VideoMerge] PiP overlay failed: $logs');
      return null;
    } catch (e) {
      Loggers.error('[VideoMerge] PiP overlay error: $e');
      return null;
    }
  }

  // ─── F1: Image Slideshow (Segment-based, fast) ───

  static const _slideW = 1080;
  static const _slideH = 1920;
  static const _slideFps = 25;

  /// Creates a slideshow by encoding each image as a separate video segment
  /// then concatenating with stream copy (no re-encoding at join step).
  /// This is 5-10x faster than the filter_complex/xfade approach.
  Future<String?> createSlideshow({
    required List<String> imagePaths,
    required List<int> durations,
    required String outputPath,
    VideoTransition transition = VideoTransition.fade,
    bool kenBurns = false,
    double transitionDuration = 0.5,
  }) async {
    if (imagePaths.isEmpty) return null;

    try {
      final tempDir = outputPath.substring(0, outputPath.lastIndexOf('/'));
      final segmentPaths = <String>[];
      final sw = Stopwatch()..start();

      // Step 1: Create individual video segments
      for (int i = 0; i < imagePaths.length; i++) {
        final segPath = '$tempDir/slide_seg_$i.mp4';
        final dur = durations[i];

        // Full HD 1080x1920 with lanczos scaling for crisp images.
        // CRF 15 = high quality, -tune stillimage for still-image encoding.
        // flags=lanczos ensures high-quality downscaling from source images.
        final command =
            '-y -loop 1 -framerate $_slideFps -i "${imagePaths[i]}" '
            '-vf "scale=$_slideW:$_slideH:force_original_aspect_ratio=increase'
            ':flags=lanczos,crop=$_slideW:$_slideH,setsar=1,format=yuv420p" '
            '-t $dur -c:v libx264 -preset medium -tune stillimage -crf 15 '
            '-pix_fmt yuv420p -an "$segPath"';

        Loggers.info('[Slideshow] Encoding segment $i (${dur}s)...');
        final session = await FFmpegKit.execute(command);
        final rc = await session.getReturnCode();

        if (!ReturnCode.isSuccess(rc)) {
          final logs = await session.getLogsAsString();
          Loggers.error('[Slideshow] Segment $i failed: $logs');
          return null;
        }
        segmentPaths.add(segPath);
      }

      Loggers.info('[Slideshow] All ${segmentPaths.length} segments encoded in ${sw.elapsedMilliseconds}ms');

      // Step 2: Write concat file
      final concatFile = File('$tempDir/slide_concat.txt');
      final concatContent = segmentPaths
          .map((p) => "file '${p.replaceAll("'", "'\\''")}'")
          .join('\n');
      await concatFile.writeAsString(concatContent);

      // Step 3: Concat with stream copy (instant, no re-encoding)
      final concatCommand =
          '-y -f concat -safe 0 -i "${concatFile.path}" '
          '-c copy -movflags +faststart "$outputPath"';

      Loggers.info('[Slideshow] Concatenating segments...');
      final concatSession = await FFmpegKit.execute(concatCommand);
      final concatRc = await concatSession.getReturnCode();

      if (!ReturnCode.isSuccess(concatRc)) {
        final logs = await concatSession.getLogsAsString();
        Loggers.error('[Slideshow] Concat failed: $logs');
        return null;
      }

      sw.stop();
      Loggers.success('[Slideshow] Done in ${sw.elapsedMilliseconds}ms');

      // Cleanup temp files
      for (final seg in segmentPaths) {
        try { await File(seg).delete(); } catch (_) {}
      }
      try { await concatFile.delete(); } catch (_) {}

      return outputPath;
    } catch (e) {
      Loggers.error('[Slideshow] Error: $e');
      return null;
    }
  }

  // ─── Utility: Get video duration ───

  Future<double> getVideoDuration(String path) async {
    try {
      final session = await FFmpegKit.execute('-i "$path" -f null -');
      final log = await session.getLogsAsString();
      final match = RegExp(r'Duration: (\d+):(\d+):(\d+)\.(\d+)')
          .firstMatch(log ?? '');
      if (match != null) {
        return int.parse(match.group(1)!) * 3600 +
            int.parse(match.group(2)!) * 60 +
            int.parse(match.group(3)!) +
            int.parse(match.group(4)!) / 100;
      }
    } catch (e) {
      Loggers.error('[VideoMerge] Duration probe error: $e');
    }
    return 0;
  }
}
