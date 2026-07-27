// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class NativeWebImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const NativeWebImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  State<NativeWebImage> createState() => _NativeWebImageState();
}

class _NativeWebImageState extends State<NativeWebImage> {
  late final String _viewType;
  late final html.DivElement _root;
  late final html.ImageElement _image;

  @override
  void initState() {
    super.initState();
    _viewType = 'taploop-native-image-${DateTime.now().microsecondsSinceEpoch}';
    _root = html.DivElement();
    _image = html.ImageElement();
    _configureElements();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (_) => _root);
  }

  @override
  void didUpdateWidget(NativeWebImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fit != widget.fit ||
        oldWidget.shape != widget.shape ||
        oldWidget.borderRadius != widget.borderRadius ||
        oldWidget.backgroundColor != widget.backgroundColor) {
      _configureElements();
    }
  }

  void _configureElements() {
    final radius = widget.shape == BoxShape.circle
        ? '9999px'
        : '${widget.borderRadius?.topLeft.x ?? 0}px';
    _root.children.clear();
    _root
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.overflow = 'hidden'
      ..style.borderRadius = radius
      ..style.backgroundColor = widget.backgroundColor == null
          ? 'transparent'
          : _cssColor(widget.backgroundColor!)
      ..style.pointerEvents = 'none';

    _image
      ..src = widget.imageUrl
      ..alt = ''
      ..draggable = false;
    _image.style
      ..width = '100%'
      ..height = '100%'
      ..display = 'block'
      ..objectFit = _cssObjectFit(widget.fit)
      ..borderRadius = radius
      ..backgroundColor = 'transparent';
    _image.onError.first.then((_) {
      if (!mounted) return;
      _image.remove();
    });

    _root.children.add(_image);
  }

  String _cssObjectFit(BoxFit fit) {
    return switch (fit) {
      BoxFit.contain => 'contain',
      BoxFit.fill => 'fill',
      BoxFit.none => 'none',
      BoxFit.scaleDown => 'scale-down',
      _ => 'cover',
    };
  }

  String _cssColor(Color color) {
    final value = color.toARGB32();
    final a = ((value >> 24) & 0xFF) / 255;
    final r = (value >> 16) & 0xFF;
    final g = (value >> 8) & 0xFF;
    final b = value & 0xFF;
    return 'rgba($r, $g, $b, $a)';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
