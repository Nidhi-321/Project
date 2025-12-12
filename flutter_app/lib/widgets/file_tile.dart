import 'package:flutter/material.dart';
import 'dart:io';

class FileTile extends StatelessWidget {
  final File file;
  const FileTile({required this.file, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = file.path.split('/').last;
    return ListTile(
      leading: Container(width: 56, height: 56, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file, fit: BoxFit.cover))),
      title: Text(name, overflow: TextOverflow.ellipsis),
      subtitle: Text('${(file.lengthSync() / 1024).toStringAsFixed(1)} KB'),
    );
  }
}
