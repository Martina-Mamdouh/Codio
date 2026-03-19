import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains("'Cairo'") || content.contains('"Cairo"')) {
      final original = content;
      // Regex to remove fontFamily: 'Cairo' and any surrounding commas/spacing
      content = content.replaceAll(RegExp(r"fontFamily:\s*['""]Cairo['""]\s*,?"), '');
      if (content != original) {
        file.writeAsStringSync(content);
        print('Updated \${file.path}');
      }
    }
  }
}
