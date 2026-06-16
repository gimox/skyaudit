import 'dart:io';

void main() {
  final home = Platform.environment['HOME'];
  if (home == null) {
    print('Error: HOME environment variable is not defined.');
    return;
  }
  
  final filePath = '$home/.pub-cache/hosted/pub.dev/excel-4.0.6/lib/src/parser/parse.dart';
  final file = File(filePath);
  
  if (!file.existsSync()) {
    print('Error: file not found at $filePath');
    return;
  }
  
  String content = file.readAsStringSync();
  
  final target = """
      case 's':
        final sharedString = _excel._sharedStrings
            .value(int.parse(_parseValue(node.findElements('v').first)));
        value = TextCellValue.span(sharedString!.textSpan);
        break;""";
        
  final replacement = """
      case 's':
        final sharedString = _excel._sharedStrings
            .value(int.parse(_parseValue(node.findElements('v').first)));
        value = sharedString != null ? TextCellValue.span(sharedString.textSpan) : TextCellValue('');
        break;""";
        
  if (content.contains(target)) {
    content = content.replaceFirst(target, replacement);
    file.writeAsStringSync(content);
    print('SUCCESS: excel package parse.dart patched successfully!');
  } else if (content.contains(replacement)) {
    print('INFO: excel package parse.dart was already patched.');
  } else {
    print('Error: Target string to patch was not found in parse.dart.');
  }
}
