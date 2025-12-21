import 'package:flutter/material.dart';

class SpinnerGridItem extends StatefulWidget {
  final String title;
  final String category;
  final Widget spinner;
  const SpinnerGridItem({super.key, required this.title, required this.spinner, required this.category});

  @override
  State<SpinnerGridItem> createState() => _SpinnerGridItemState();
}

class _SpinnerGridItemState extends State<SpinnerGridItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withAlpha(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Center(child: widget.spinner),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
