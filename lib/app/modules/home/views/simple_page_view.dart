import 'package:flutter/material.dart';

import '../../../widgets/app_page_scaffold.dart';

class SimplePageView extends StatelessWidget {
  const SimplePageView({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
