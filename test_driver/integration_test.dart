import 'dart:io';
import 'dart:convert';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    responseDataCallback: (data) async {
      final names = (data?['screenshots'] as List? ?? [])
          .map((s) => s['screenshotName'])
          .toList();
      if (names.isNotEmpty) {
        await File(
          'build/capture-${names.first}-${names.last}.json',
        ).writeAsString(jsonEncode({'passed': true, 'screenshots': names}));
      }
    },
    onScreenshot: (name, bytes, [args]) async {
      final file = File('docs/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
