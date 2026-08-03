import 'dart:convert';
import 'dart:io';

void main() async {
  final wsUrl = 'ws://127.0.0.1:57472/BkbHh6j2X9E=/ws';
  print('Connecting to $wsUrl...');
  try {
    final socket = await WebSocket.connect(wsUrl);
    print('Connected!');
    
    // Request VM info
    final getVMRequest = {
      'jsonrpc': '2.0',
      'id': '1',
      'method': 'getVM',
      'params': {},
    };
    socket.add(jsonEncode(getVMRequest));
    
    // Listen for response
    await for (final message in socket) {
      final data = jsonDecode(message as String);
      print('Received: ${jsonEncode(data)}');
      break;
    }
    
    // Request main isolate's views
    final getViewsRequest = {
      'jsonrpc': '2.0',
      'id': '2',
      'method': 'ext.flutter.activeViewId', // or getViews
      'params': {},
    };
    socket.add(jsonEncode(getViewsRequest));
    
    socket.add(jsonEncode({
      'jsonrpc': '2.0',
      'id': '3',
      'method': 'getViews',
      'params': {},
    }));

    var count = 0;
    await for (final message in socket) {
      final data = jsonDecode(message as String);
      print('Received: ${jsonEncode(data)}');
      count++;
      if (count >= 2) break;
    }

    await socket.close();
  } catch (e) {
    print('Error: $e');
  }
}
