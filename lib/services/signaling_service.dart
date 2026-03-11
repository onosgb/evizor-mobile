import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import 'storage_service.dart';

/// Service for handling real-time signaling via WebSocket
class SignalingService {
  static final SignalingService _instance = SignalingService._internal();
  io.Socket? _socket;
  final StorageService _storageService = StorageService();

  // Callbacks
  Function(Map<String, dynamic>)? onIncomingCall;
  Function(Map<String, dynamic>)? onCallProgress;
  Function(Map<String, dynamic>)? onAppointmentAttended;

  factory SignalingService() {
    return _instance;
  }

  SignalingService._internal();

  /// Initialize and connect to the signaling gateway
  Future<void> connect() async {
    final token = await _storageService.getAccessToken();
    if (token == null) {
      log('SignalingService: No access token found. Cannot connect.');
      return;
    }

    if (_socket != null && _socket!.connected) {
      log('SignalingService: Already connected.');
      return;
    }

    log('SignalingService: Connecting to ${AppConfig.socketBaseUrl}');

    _socket = io.io(
      AppConfig.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      log('SignalingService: Connected');
      _socket!.emit('register');
    });

    _socket!.on('registered', (data) {
      log('SignalingService: Registered as ${data['role']}');
    });

    _socket!.on('appointment:progress', (data) {
      log('SignalingService: Appointment progress: $data');
      if (onCallProgress != null) {
        onCallProgress!(data);
      }
    });

    _socket!.on('consultation:incoming', (data) {
      log('SignalingService: Incoming consultation: $data');
      if (onIncomingCall != null) {
        onIncomingCall!(data);
      }
    });

    _socket!.on('appointment:attended', (data) {
      log('SignalingService: Appointment attended: $data');
      if (onAppointmentAttended != null) {
        onAppointmentAttended!(data);
      }
    });

    _socket!.onDisconnect((_) => log('SignalingService: Disconnected'));

    _socket!.onError((err) => log('SignalingService: Error: $err'));

    _socket!.connect();
  }

  /// Disconnect from the signaling gateway
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Join a specific room (optional, handled by register usually)
  void joinRoom(String roomName) {
    _socket?.emit('join', roomName);
  }

  bool get isConnected => _socket?.connected ?? false;
}
