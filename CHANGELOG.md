# Changelog

## v0.0.1

Initial release of **flutter_spinners**.

### Features
- Added a collection of customizable loading spinners built with `CustomPainter`
- Dot spinners:
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
- Bar spinners:
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
- Square spinners:
    - FlippingSquareIndicator
    - FlippingSquaresGridIndicator
    - FoldingSquareIndicator
    - PulsatingSquareIndicator
    - ShimmeringSquareGridIndicator
    - SquareWaveGridIndicator
- Line spinners:
    - SlidingSquareLineIndicator
    - SquareLineIndicator
    - SquareLineLoopIndicator

### API
- Common parameters: `color`, `size`, `duration`
- Optional `borderRadius` for bar-based spinners

## v0.0.2

Minor Refactoring of codebase

- Formatted source code to pass static analysis.
- Added screenshots

## v0.0.3

Updated README

- Fixed missing screenshot fom readme

## v0.0.4

Updated Screenshot

- Fixed screenshot not rendering in readme

## v0.0.5

Updated Demo

- Fixed issue with wrong background color in web version
- Added max-width constrains in demo to avoid stretching of layout