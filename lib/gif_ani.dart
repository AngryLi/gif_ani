library gif_ani;

import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

class GifController extends AnimationController {
  ///gif有多少个帧
  final int frameCount;

  GifController({
    @required this.frameCount,
    @required TickerProvider vSync,
    double value,
    Duration duration,
    String debugLabel,
    double lowerBound,
    double upperBound,
    AnimationBehavior animationBehavior,
  }) : super(
          value: value,
          duration: duration,
          debugLabel: debugLabel,
          lowerBound: lowerBound ?? 0.0,
          upperBound: upperBound ?? 1.0,
          animationBehavior: animationBehavior ?? AnimationBehavior.normal,
          vsync: vSync,
        );

  void runAni() {
    this.forward(from: 0.0);
  }

  void setFrame([int index = 0]) {
    double target = math.max(math.min(index, frameCount - 1), 0) / this.frameCount;
    this.animateTo(target, duration: Duration());
  }
}

class GifAnimation extends StatefulWidget {
  GifAnimation({
    @required this.image,
    @required this.controller,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gapLessPlayback = false,
  });

  final GifController controller;
  final ImageProvider image;
  final double width;
  final double height;
  final Color color;
  final BlendMode colorBlendMode;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect centerSlice;
  final bool matchTextDirection;
  final bool gapLessPlayback;
  final String semanticLabel;
  final bool excludeFromSemantics;

  @override
  State<StatefulWidget> createState() {
    return _AnimatedImageState();
  }
}

class _AnimatedImageState extends State<GifAnimation> {
  Tween<double> _tween;
  List<ImageInfo> _infos;

//  int _curIndex = 0;
  final currentIndex = ValueNotifier<int>(0);

  ImageInfo get _imageInfo => _infos == null ? null : _infos[currentIndex.value];

  @override
  void initState() {
    super.initState();
    _tween = Tween<double>(begin: 0.0, end: (widget.controller.frameCount - 1) * 1.0);
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_listener);
  }

  @override
  void didUpdateWidget(GifAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
  }

  void _listener() {
    int _idx = _tween.evaluate(widget.controller) ~/ 1;
    currentIndex.value = math.min(widget.controller.frameCount - 1, _idx);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_infos == null) {
      preloadImage(
        provider: widget.image,
        context: context,
        frameCount: widget.controller.frameCount,
      ).then((_list) {
        _infos = _list;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentIndex,
      builder: (context, value, _) {
        final child = RawImage(
          image: _imageInfo?.image,
          width: widget.width,
          height: widget.height,
          scale: _imageInfo?.scale ?? 1.0,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,
          fit: widget.fit,
          alignment: widget.alignment,
          repeat: widget.repeat,
          centerSlice: widget.centerSlice,
          matchTextDirection: widget.matchTextDirection,
        );
        if (widget.excludeFromSemantics) return child;
        return Semantics(
          container: widget.semanticLabel != null,
          image: true,
          label: widget.semanticLabel == null ? '' : widget.semanticLabel,
          child: child,
        );
      },
    );
  }

  Future<List<ImageInfo>> preloadImage({
    @required ImageProvider provider,
    @required BuildContext context,
    int frameCount: 1,
    Size size,
    ImageErrorListener onError,
  }) {
    final config = createLocalImageConfiguration(context, size: size);
    final completer = Completer<List<ImageInfo>>();
    final stream = provider.resolve(config);
    List<ImageInfo> ret = [];
    ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo image, bool sync) {
        ret.add(image);
        if (ret.length == frameCount) {
          completer.complete(ret);
          stream.removeListener(listener);
        }
      },
      onError: (dynamic exception, StackTrace stackTrace) {
        completer.complete();
        stream.removeListener(listener);
        if (onError != null) {
          onError(exception, stackTrace);
        } else {
          FlutterError.reportError(FlutterErrorDetails(
            context: ErrorDescription('image failed to precache'),
            library: 'image resource service',
            exception: exception,
            stack: stackTrace,
            silent: true,
          ));
        }
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
