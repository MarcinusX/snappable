library snappable;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as image;

class Snappable extends StatefulWidget {
  /// Widget to be snapped
  final Widget child;

  /// Direction and range of snap effect
  /// (Where and how far will particles go)
  final Offset offset;

  /// Duration of whole snap animation
  final Duration duration;

  /// How much can particle be randomized,
  /// For example if [offset] is (100, 100) and [randomDislocationOffset] is (10,10),
  /// Each layer can be moved to maximum between 90 and 110.
  final Offset randomDislocationOffset;

  /// Number of layers of images,
  /// The more of them the better effect but the more heavy it is for CPU
  final int numberOfBuckets;

  /// Quick helper to snap widgets when touched
  /// If true wraps the widget in [GestureDetector] and starts [snap] when tapped
  /// Defaults to false
  final bool snapOnTap;

  /// Function that gets called when snap ends
  final VoidCallback? onSnapped;

  const Snappable({
    Key? key,
    required this.child,
    this.offset = const Offset(64, -32),
    this.duration = const Duration(milliseconds: 5000),
    this.randomDislocationOffset = const Offset(64, 32),
    this.numberOfBuckets = 16,
    this.snapOnTap = false,
    this.onSnapped,
  }) : super(key: key);

  @override
  SnappableState createState() => SnappableState();
}

class SnappableState extends State<Snappable>
    with SingleTickerProviderStateMixin {
  static const double _singleLayerAnimationLength = 0.6;
  static const double _lastLayerAnimationStart =
      1 - _singleLayerAnimationLength;

  bool get isGone => _animationController.isCompleted;

  /// Main snap effect controller
  late AnimationController _animationController;

  /// Key to get image of a [widget.child]
  GlobalKey _globalKey = GlobalKey();

  /// Layers of image
  List<Uint8List>? _layers;

  /// Values from -1 to 1 to dislocate the layers a bit
  late List<double> _randoms;

  /// Size of child widget
  Size? size;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.onSnapped != null) {
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onSnapped!();
      });
    }
    _prepareRandoms();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.snapOnTap ? () => isGone ? reset() : snap() : null,
      child: Stack(
        children: <Widget>[
          ..._generateWidgetsFromImages(),
          AnimatedBuilder(
            animation: _animationController,
            builder: (_, Widget? child) {
              return _animationController.isDismissed
                  ? child!
                  : const SizedBox.shrink();
            },
            child: RepaintBoundary(
              key: _globalKey,
              child: widget.child,
            ),
          )
        ],
      ),
    );
  }

  /// I am... INEVITABLE      ~Thanos
  Future<void> snap() async {
    //get image from child
    final fullImage = await _getImageFromWidget();
    if (fullImage == null) return;

    //create an image for every bucket
    List<image.Image> _images = List<image.Image>.generate(
      widget.numberOfBuckets,
      (i) => image.Image(
        width: fullImage.width,
        height: fullImage.height,
        numChannels: 4,
      ),
    );

    //for every line of pixels
    for (int y = 0; y < fullImage.height; y++) {
      //generate weight list of probabilities determining
      //to which bucket should given pixels go
      List<int> weights = List.generate(
        widget.numberOfBuckets,
        (bucket) => _gauss(
          y / fullImage.height,
          bucket / widget.numberOfBuckets,
        ),
      );
      int sumOfWeights = weights.fold(0, (sum, el) => sum + el);

      //for every pixel in a line
      for (int x = 0; x < fullImage.width; x++) {
        //get the pixel from fullImage
        image.Pixel pixel = fullImage.getPixel(x, y);
        //choose a bucket for a pixel
        int imageIndex = _pickABucket(weights, sumOfWeights);
        //set the pixel from chosen bucket
        _images[imageIndex].setPixel(x, y, pixel);
      }
    }

    _layers = await compute<List<image.Image>, List<Uint8List>>(
        _encodeImages, _images);

    _prepareRandoms();
    setState(() {});

    //give a short delay to draw images
    await Future.delayed(Duration(milliseconds: 100));

    //start the snap!
    _animationController.forward();
  }

  /// I am... IRON MAN   ~Tony Stark
  void reset() {
    setState(() {
      _layers = null;
      _animationController.reset();
    });
  }

  Iterable<Widget> _generateWidgetsFromImages() {
    if (_layers == null) return [];
    return _layers!.map(_imageToWidget);
  }

  Widget _imageToWidget(Uint8List layer) {
    //get layer's index in the list
    //This is invoked in build() and _layers aren't null here.
    int index = _layers!.indexOf(layer);

    //based on index, calculate when this layer should start and end
    double animationStart =
        (index / _layers!.length) * _lastLayerAnimationStart;
    double animationEnd = animationStart + _singleLayerAnimationLength;

    //create interval animation using only part of whole animation
    CurvedAnimation animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        animationStart,
        animationEnd,
        curve: Curves.easeOut,
      ),
    );

    Offset randomOffset = widget.randomDislocationOffset.scale(
      _randoms[index],
      _randoms[index],
    );

    Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.offset + randomOffset,
    ).animate(animation);

    return AnimatedBuilder(
      animation: _animationController,
      child: Image.memory(layer),
      builder: (context, child) {
        return Transform.translate(
          offset: offsetAnimation.value,
          child: Opacity(
            opacity: math.cos(animation.value * math.pi / 2),
            child: child,
          ),
        );
      },
    );
  }

  /// Returns index of a randomly chosen bucket
  int _pickABucket(List<int> weights, int sumOfWeights) {
    int rnd = math.Random().nextInt(sumOfWeights);
    int chosenImage = 0;
    for (int i = 0; i < widget.numberOfBuckets; i++) {
      if (rnd < weights[i]) {
        chosenImage = i;
        break;
      }
      rnd -= weights[i];
    }
    return chosenImage;
  }

  /// Gets an Image from a [child] and caches [size] for later us
  Future<image.Image?> _getImageFromWidget() async {
    RenderObject? rObj = _globalKey.currentContext?.findRenderObject();
    RenderRepaintBoundary? boundary = rObj as RenderRepaintBoundary?;
    //cache image for later
    size = boundary?.size;
    if (boundary == null) return null;

    ui.Image img = await boundary.toImage();
    ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData?.buffer.asUint8List();
    if (pngBytes == null) return null;

    return image.decodeImage(pngBytes);
  }

  int _gauss(double center, double value) =>
      (1000 * math.exp(-(math.pow((value - center), 2) / 0.14))).round();

  /// Prepare random dislocations and set state
  void _prepareRandoms() {
    _randoms = List.generate(
      widget.numberOfBuckets,
      (i) => (math.Random().nextDouble() - 0.5) * 2,
    );
  }
}

/// This is slow! Run it in separate isolate
List<Uint8List> _encodeImages(List<image.Image> images) {
  return images.map((img) => Uint8List.fromList(image.encodePng(img))).toList();
}
