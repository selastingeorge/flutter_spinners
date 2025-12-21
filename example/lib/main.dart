import 'package:example/models/spinner_item.dart';
import 'package:example/themes/generic.dart';
import 'package:example/types/spinner_category.dart';
import 'package:example/widgets/horizontal_chips.dart';
import 'package:example/widgets/spinner_grid_item.dart';
import 'package:example/widgets/terminal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinners/flutter_spinners.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Spinners Demo', theme: genericTheme, home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SpinnerCategory? selectedCategory;
  late final List<String> chips = ['All', ...SpinnerCategory.values.map((e) => e.label)];
  final List<SpinnerItem> allSpinners = [
    SpinnerItem(
      title: 'Stepped Dots',
      category: SpinnerCategory.dots,
      spinner: SteppedDotsLoader(color: Colors.white),
    ),
    SpinnerItem(
      title: 'Single Step Dots',
      category: SpinnerCategory.dots,
      spinner: SingleStepLoader(color: Colors.white),
    ),
    SpinnerItem(
      title: 'Wavy Dots',
      category: SpinnerCategory.dots,
      spinner: WavyDotsIndicator(color: Colors.white),
    ),
    SpinnerItem(
      title: 'Shadow Dots',
      category: SpinnerCategory.dots,
      spinner: ShadowDotsIndicator(color: Colors.white),
    ),
    SpinnerItem(
      title: 'Pulse Dots',
      category: SpinnerCategory.dots,
      spinner: PulseDotsIndicator(color: Colors.white),
    ),
    SpinnerItem(
      title: 'Flipping Dots',
      category: SpinnerCategory.dots,
      spinner: FlippingDotsIndicator(color: Colors.white),
    ),
    SpinnerItem(
      title: 'Swapping Dots',
      category: SpinnerCategory.dots,
      spinner: SwappingDotsIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
    SpinnerItem(
      title: 'Corner Dots',
      category: SpinnerCategory.dots,
      spinner: CornerDotsIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
    SpinnerItem(
      title: 'Quad Dots Swap',
      category: SpinnerCategory.dots,
      spinner: QuadDotSwapIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Dots Grid Shimmer',
      category: SpinnerCategory.dots,
      spinner: GridDotsShimmerIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Bar Wave',
      category: SpinnerCategory.bars,
      spinner: BarWaveIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Flipping Bars',
      category: SpinnerCategory.bars,
      spinner: FlippingBarsIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Dancing Bars',
      category: SpinnerCategory.bars,
      spinner: DancingBarsIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Growing Bar Wave',
      category: SpinnerCategory.bars,
      spinner: GrowingBarWaveIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Double Row Bars',
      category: SpinnerCategory.bars,
      spinner: DoubleRowBarsIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Shrink & Swap Bars',
      category: SpinnerCategory.bars,
      spinner: ShrinkSwapBarsIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Stretch Bars',
      category: SpinnerCategory.bars,
      spinner: StretchBarsIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Vertical Shutter Bars',
      category: SpinnerCategory.bars,
      spinner: VerticalShutterBarsIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
    SpinnerItem(
      title: 'Horizontal Shutter Bars',
      category: SpinnerCategory.bars,
      spinner: HorizontalShutterBarsIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
    SpinnerItem(
      title: 'Sinking Bars',
      category: SpinnerCategory.bars,
      spinner: SinkingBarsIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
    SpinnerItem(
      title: 'Flipping Square',
      category: SpinnerCategory.square,
      spinner: FlippingSquareIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Flipping Squares Grid',
      category: SpinnerCategory.square,
      spinner: FlippingSquaresGridIndicator(color: Colors.white, duration: const Duration(seconds: 3)),
    ),
    SpinnerItem(
      title: 'Folding Square',
      category: SpinnerCategory.square,
      spinner: FoldingSquareIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
    SpinnerItem(
      title: 'Pulsating Square',
      category: SpinnerCategory.square,
      spinner: PulsatingSquareIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Squares Wave',
      category: SpinnerCategory.square,
      spinner: SquareWaveGridIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Shimmering Square Grid',
      category: SpinnerCategory.square,
      spinner: ShimmeringSquareGridIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Square Line',
      category: SpinnerCategory.lines,
      spinner: SquareLineIndicator(color: Colors.white, duration: const Duration(seconds: 1)),
    ),
    SpinnerItem(
      title: 'Square Line Loop',
      category: SpinnerCategory.lines,
      spinner: SquareLineLoopIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
    SpinnerItem(
      title: 'Sliding Square Line',
      category: SpinnerCategory.lines,
      spinner: SlidingSquareLineIndicator(color: Colors.white, duration: const Duration(seconds: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<SpinnerItem> filteredSpinners = selectedCategory == null
        ? allSpinners
        : allSpinners.where((e) => e.category == selectedCategory).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      "Flutter Spinners",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: "Inter",
                        fontVariations: [FontVariation('wght', 600)],
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Beautiful, customizable loading spinners \nfor Flutter apps",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF7d8f8f)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: const Text("Version: 1.0.0", style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(height: 15),
                    const Terminal(
                      title: "Install",
                      command: "\$ flutter pub add flutter_spinners",
                      tooltip: "Paste this command on your terminal to install flutter spinner",
                    ),
                    const SizedBox(height: 10),

                    HorizontalChips(
                      chips: chips,
                      initialSelectedIndex: 0,
                      onChanged: (label) {
                        setState(() {
                          selectedCategory = label == 'All' ? null : SpinnerCategory.fromLabel(label!);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = filteredSpinners[index];
                  return SpinnerGridItem(
                    title: item.title,
                    category: item.category.label,
                    spinner: item.spinner,
                  );
                }, childCount: filteredSpinners.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 160,
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
