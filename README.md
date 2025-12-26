<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Flutter Spinners
[![pub package](https://img.shields.io/pub/v/flutter_spinners.svg)](https://pub.dev/packages/flutter_spinners)

A collection of beautiful, customizable loading spinners for flutter applications, leveraging [CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html).


## 📦 Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_spinners: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## ✨ Import

```dart
import 'package:flutter_spinners/flutter_spinners.dart';
```

## 🧭 Usage

```dart
WavyDotsIndicator(
  color: Colors.white,
  size: 60,
  duration: const Duration(seconds: 2)
),
```

## 🎨 Customization
All spinners support customization through common parameters:
```dart
SteppedDotsLoader(
   color: Colors.purple,           // Change the color
   size: 50.0,                     // Adjust the size (if supported)
   duration: Duration(seconds: 2), // Control animation speed
)
```

### Parameters

| Parameter      | Type     | Description                                                        |
|----------------|----------|--------------------------------------------------------------------|
| `color`        | Color    | The color of the spinner (required)                                |
| `duration`     | Duration | Animation cycle duration (optional, varies by spinner)             |
| `size`         | double   | Size of the spinner in logical pixels (optional, where applicable) |
| `borderRadius` | double   | Corner radius of the bars (only available for bar-based spinners)  |

## 🌀 Available Spinners
### Dot Spinners
- CornerDotsIndicator
- FlippingDotsIndicator
- GridDotsShimmerIndicator
- PulseDotsIndicator
- QuadDotSwapIndicator
- ShadowDotsIndicator
- SingleStepLoader
- SteppedDotsLoader
- SwappingDotsIndicator
- WavyDotsIndicator

### Bar Spinners
- BarWaveIndicator
- DancingBarsIndicator
- DoubleRowBarsIndicator
- FlippingBarsIndicator
- GrowingBarWaveIndicator
- HorizontalShutterBarsIndicator
- ShrinkSwapBarsIndicator
- SinkingBarsIndicator
- StretchBarsIndicator
- VerticalShutterBarsIndicator

### Square
- FlippingSquareIndicator
- FlippingSquaresGridIndicator
- FoldingSquareIndicator
- PulsatingSquareIndicator
- ShimmeringSquareGridIndicator
- SquareWaveGridIndicator

### Lines
- SlidingSquareLineIndicator
- SquareLineIndicator
- SquareLineLoopIndicator

## 📸 Demo
<img src="docs/assets/screenshot.gif" alt="Flutter Spinners demo preview" width="360"/>

## 🤝 Contributing
Contributions are very welcome! 🎉  
Whether it’s a new spinner, a bug fix, or a documentation improvement, every bit helps.

## ⭐ Show Your Support

If you find this package useful, please consider giving it a star on GitHub and a like on pub.dev!

Built with ❤️ for the Flutter community.
