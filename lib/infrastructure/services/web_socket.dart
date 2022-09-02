import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';

WebSocketUtility socketUtility = WebSocketUtility();

class WebSocketUtility extends ChangeNotifier {
  late WebSocket webSocketChannel;
  late WebSocketChannel webWebSocketChannel;
  bool _isConnected = false;
  int tries = 0;
  ObserverList<Function> listeners = ObserverList<Function>();
  static final WebSocketUtility socketUtility = WebSocketUtility._internal();

  factory WebSocketUtility() {
    return socketUtility;
  }

  WebSocketUtility._internal();

  initCommunication(String url) async {
    try {
      if (kIsWeb) {
        webWebSocketChannel = WebSocketChannel.connect(Uri.parse(url));
        _isConnected = true;
        webWebSocketChannel.stream.listen((event) {
          listenToWebSocket(event);
        });
      } else {
        await WebSocket.connect(url).then((value) {
          if (value.readyState == 1) {
            _isConnected = true;
            webSocketChannel = value;
            value.listen(listenToWebSocket);
          }
        });
      }
    } catch (ex) {
      FLog.debug(text: ex.toString());
    }
  }

  @override
  addListener(Function listener) {
    listeners.add(listener);
  }

  @override
  removeListener(Function listener) {
    listeners.remove(listener);
  }

  close() async {
    try {
      if (kIsWeb) {
        if (_isConnected) {
          await webWebSocketChannel.sink.close();
        }
      } else {
        if (_isConnected) {
          await webSocketChannel.close();
        }
      }
      listeners = ObserverList<Function>();
    } catch (e) {
      FLog.debug(text: e.toString());
    }
  }

  void listenToWebSocket(message) {
    for (var listener in listeners) {
      listener(message);
    }
  }
}
