import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic>? metrics;
  final Widget? child;
  const ResultCard({required this.title, this.metrics, this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          if (metrics != null) ...metrics!.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text('${e.key.toUpperCase()}: ${e.value}'),
          )),
          if (child != null) child!,
        ]),
      ),
    );
  }
}
