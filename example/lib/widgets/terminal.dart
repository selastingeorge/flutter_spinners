import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Terminal extends StatelessWidget {
  final String title;
  final String command;
  final String tooltip;
  const Terminal({super.key, required this.title, required this.command, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                // macOS window buttons
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5F57), // red
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFBD2E), // yellow
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF28C840), // green
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: "Inter",
                    fontVariations: [FontVariation('wght', 400)],
                  ),
                ),

                const Spacer(),

                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 20),
                  enableTapToDismiss: true,
                  preferBelow: true,
                  richMessage: WidgetSpan(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(tooltip, style: const TextStyle(fontFamily: "Inter", fontSize: 12)),
                    ),
                  ),
                  child: SvgPicture.asset(
                    "assets/images/info.svg",
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withAlpha(10)),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Text(command, style: TextStyle(fontSize: 13, height: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
