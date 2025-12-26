import 'package:flutter/material.dart';

class HorizontalChips extends StatefulWidget {
  final List<String> chips;
  final ValueChanged<String?>? onChanged;
  final int? initialSelectedIndex;

  const HorizontalChips({
    super.key,
    required this.chips,
    this.onChanged,
    this.initialSelectedIndex,
  });

  @override
  State<HorizontalChips> createState() => _HorizontalChipsState();
}

class _HorizontalChipsState extends State<HorizontalChips> {
  String? selectedChip;
  final ScrollController _controller = ScrollController();

  bool _isScrollable = false;
  bool _fadeLeft = false;
  bool _fadeRight = false;

  @override
  void initState() {
    super.initState();

    // Set default selected chip
    final index = widget.initialSelectedIndex;
    if (index != null && index >= 0 && index < widget.chips.length) {
      selectedChip = widget.chips[index];
      // Call onChanged after first frame to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged?.call(selectedChip);
      });
    }

    _controller.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  void _updateFades() {
    if (!mounted || !_controller.hasClients) return;

    final position = _controller.position;
    final max = position.maxScrollExtent;

    final scrollable = max > 0;
    final fadeLeft = scrollable && position.pixels > 0;
    final fadeRight = scrollable && position.pixels < max;

    // Only call setState if values actually changed
    if (scrollable != _isScrollable ||
        fadeLeft != _fadeLeft ||
        fadeRight != _fadeRight) {
      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isScrollable = scrollable;
            _fadeLeft = fadeLeft;
            _fadeRight = fadeRight;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChipSelected(String label) {
    final newValue = selectedChip == label ? null : label;

    setState(() {
      selectedChip = newValue;
    });

    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    Widget list = ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: widget.chips.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final label = widget.chips[index];
        final isSelected = selectedChip == label;

        return ChoiceChip(
          label: Text(label),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          selected: isSelected,
          onSelected: (_) => _onChipSelected(label),
        );
      },
    );

    if (_isScrollable) {
      list = ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _fadeLeft ? Colors.transparent : Colors.black,
              Colors.black,
              Colors.black,
              _fadeRight ? Colors.transparent : Colors.black,
            ],
            stops: const [0.0, 0.08, 0.92, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: list,
      );
    }

    return SizedBox(height: 50, child: list);
  }
}
