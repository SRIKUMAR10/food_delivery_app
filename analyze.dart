import 'dart:io';

void main() async {
  print('Running flutter analyze...');
  final result = await Process.run('flutter', ['analyze']);
  
  final file = File('analyze_output.txt');
  file.writeAsStringSync('STDOUT:\n\${result.stdout}\n\nSTDERR:\n\${result.stderr}');
  
  print('Analysis complete. Results saved to analyze_output.txt');
}
