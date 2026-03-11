import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_service.dart';

typedef RealtimeEventHandler = void Function(Map<String, dynamic> event);

class RealtimeService {
  RealtimeService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _stopped = false;
  int _attempt = 0;

  String _wsUrl() {
    final serverRoot = ApiService.baseUrl.replaceAll('/api/v1', '');
    final wsRoot = serverRoot.replaceFirst(RegExp(r'^http'), 'ws').replaceAll(RegExp(r'/$'), '');
    return '$wsRoot/ws';
  }

  void start({required RealtimeEventHandler onEvent}) {
    _stopped = false;
    _connect(onEvent: onEvent);
  }

  void stop() {
    _stopped = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _scheduleReconnect({required RealtimeEventHandler onEvent}) {
    if (_stopped) return;
    _reconnectTimer?.cancel();
    final delayMs = (500 * (1 << (_attempt.clamp(0, 6)))).clamp(500, 10000);
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      _attempt += 1;
      _connect(onEvent: onEvent);
    });
  }

  void _connect({required RealtimeEventHandler onEvent}) {
    if (_stopped) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl()));
    } catch (_) {
      _scheduleReconnect(onEvent: onEvent);
      return;
    }

    _attempt = 0;
    _sub?.cancel();
    _sub = _channel!.stream.listen(
      (data) {
        try {
          final decoded = json.decode(data as String);
          if (decoded is Map<String, dynamic>) {
            onEvent(decoded);
          }
        } catch (_) {
          // ignore malformed events
        }
      },
      onError: (_) => _scheduleReconnect(onEvent: onEvent),
      onDone: () => _scheduleReconnect(onEvent: onEvent),
      cancelOnError: true,
    );
  }
}

