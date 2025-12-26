import 'package:example/types/spinner_category.dart';
import 'package:flutter/material.dart';

class SpinnerItem {
  final String title;
  final SpinnerCategory category;
  final Widget spinner;

  SpinnerItem({
    required this.title,
    required this.category,
    required this.spinner,
  });
}
