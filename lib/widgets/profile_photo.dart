import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/profile_photo_service.dart';

typedef ProfilePhotoBuilder = Widget Function(Widget avatar, Color? glowColor);

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    super.key,
    required this.username,
    required this.size,
    required this.placeholder,
    this.builder,
  });

  final String username;
  final double size;
  final Widget placeholder;
  final ProfilePhotoBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<AppProvider?, bool>(
      (provider) => provider?.showProfilePhotos ?? false,
    );
    if (!enabled || !Platform.isAndroid) {
      return builder?.call(placeholder, null) ?? placeholder;
    }

    return _LoadedProfilePhoto(
      key: ValueKey(username),
      username: username,
      size: size,
      placeholder: placeholder,
      builder: builder,
    );
  }
}

class _LoadedProfilePhoto extends StatefulWidget {
  const _LoadedProfilePhoto({
    super.key,
    required this.username,
    required this.size,
    required this.placeholder,
    this.builder,
  });

  final String username;
  final double size;
  final Widget placeholder;
  final ProfilePhotoBuilder? builder;

  @override
  State<_LoadedProfilePhoto> createState() => _LoadedProfilePhotoState();
}

class _LoadedProfilePhotoState extends State<_LoadedProfilePhoto> {
  static final _colors = Expando<Color>();
  static final _samples = Expando<Future<Color?>>();
  Timer? _delay;
  Uint8List? _image;
  Color? _glowColor;

  @override
  void initState() {
    super.initState();
    final photos = ProfilePhotoService.instance;
    _image = photos.cachedPhoto(widget.username);
    if (_image case final Uint8List image) {
      _loadGlow(image);
      return;
    }

    // Ignore briefly mounted cards during a fling.
    _delay = Timer(const Duration(milliseconds: 250), () async {
      final image = await photos.load(widget.username, isNeeded: () => mounted);
      if (mounted && image != null) {
        setState(() => _image = image);
        _loadGlow(image);
      }
    });
  }

  void _loadGlow(Uint8List image) {
    if (widget.builder == null) return;
    _glowColor = _colors[image];
    if (_glowColor != null) return;
    final sample = _samples[image] ??= samplePhotoGlow(image).then((color) {
      if (color != null) _colors[image] = color;
      return color;
    });
    unawaited(
      sample.then((color) {
        if (mounted && color != null) setState(() => _glowColor = color);
      }),
    );
  }

  @override
  void dispose() {
    _delay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    Widget wrap(Widget avatar, Color? color) =>
        widget.builder?.call(avatar, color) ?? avatar;
    if (image == null) return wrap(widget.placeholder, null);

    return Image.memory(
      image,
      width: widget.size,
      height: widget.size,
      cacheWidth: (widget.size * MediaQuery.devicePixelRatioOf(context)).ceil(),
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      frameBuilder: (_, child, frame, _) => frame == null
          ? wrap(widget.placeholder, null)
          : wrap(ClipOval(child: child), _glowColor),
      errorBuilder: (_, _, _) => wrap(widget.placeholder, null),
    );
  }
}

@visibleForTesting
Future<Color?> samplePhotoGlow(Uint8List photo) async {
  const size = 16;
  ui.Codec? codec;
  ui.Image? image;
  try {
    codec = await ui.instantiateImageCodec(
      photo,
      targetWidth: size,
      targetHeight: size,
    );
    image = (await codec.getNextFrame()).image;
    final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (pixels == null) return null;

    final hues = List<double>.filled(12, 0);
    final colors = List<HSVColor?>.filled(12, null);
    var brightness = 0.0;
    var count = 0;
    for (var offset = 0; offset < pixels.lengthInBytes; offset += 4) {
      if (pixels.getUint8(offset + 3) < 224) continue;
      final color = HSVColor.fromColor(
        Color.fromARGB(
          255,
          pixels.getUint8(offset),
          pixels.getUint8(offset + 1),
          pixels.getUint8(offset + 2),
        ),
      );
      brightness += color.value;
      count++;
      if (color.saturation < 0.2 || color.value < 0.15) continue;

      final bucket = color.hue ~/ 30 % hues.length;
      hues[bucket] += color.saturation * color.value;
      final current = colors[bucket];
      if (current == null ||
          color.saturation * color.value > current.saturation * current.value) {
        colors[bucket] = color;
      }
    }
    if (count == 0) return null;
    var dominant = 0;
    for (var i = 1; i < hues.length; i++) {
      if (hues[i] > hues[dominant]) dominant = i;
    }
    return (colors[dominant] ?? HSVColor.fromAHSV(1, 0, 0, brightness / count))
        .toColor();
  } on Exception {
    return null;
  } finally {
    image?.dispose();
    codec?.dispose();
  }
}
