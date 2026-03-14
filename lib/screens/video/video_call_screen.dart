import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtimekit_core/realtimekit_core.dart';
import 'dart:async';
import 'dart:convert';
import '../../utils/app_routes.dart';
import '../../providers/call_provider.dart';
import '../../providers/appointment_provider.dart';
import 'in_call_chat_screen.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen>
    with TickerProviderStateMixin
    implements RtkMeetingRoomEventListener, RtkParticipantsEventListener {
  RealtimekitClient? _meeting;
  bool _isReady = false;
  bool _pageLoaded = false;
  String? _error;

  final List<ChatMessage> _chatMessages = [];
  RtkChatEventListener? _chatListener;
  Timer? _chatPollTimer;

  /// Unread chat count: when user opens chat, we set _chatReadCount = length so badge shows 0 until new messages arrive.
  int _chatReadCount = 0;
  DateTime? _callStartedAt;
  Timer? _callDurationTimer;

  /// 30s connection timeout; cleared when we join successfully or hit another error.
  Timer? _connectionTimeoutTimer;

  /// Fallback: first remote we got from onParticipantJoin in case joined list lags.
  RtkRemoteParticipant? _firstRemoteFromCallback;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  static const String _logTag = '[VideoCall]';

  int get _chatUnreadCount =>
      (_chatMessages.length - _chatReadCount).clamp(0, 999);

  String _formatCallDuration() {
    if (_callStartedAt == null) return '00:00';
    final elapsed = DateTime.now().difference(_callStartedAt!);
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    debugPrint('$_logTag initState');

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Pulse animation for the avatar ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('$_logTag postFrameCallback: calling _initializeRealtimeKit');
      _initializeRealtimeKit();
    });
  }

  @override
  void dispose() {
    if (_meeting != null) {
      try {
        _meeting!.removeParticipantsEventListener(this);
        _meeting!.removeMeetingRoomEventListener(this);
        if (_chatListener != null) {
          _meeting!.removeChatEventListener(_chatListener!);
        }
        _meeting!.leaveRoom(
          onSuccess: () {
            _meeting!.cleanAllNativeListeners();
          },
          onError: (error) {
            _meeting!.cleanAllNativeListeners();
          },
        );
      } catch (e) {
        debugPrint("Error during meeting cleanup: $e");
      }
    }
    _chatPollTimer?.cancel();
    _callDurationTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    ref.read(callProvider.notifier).clear();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  RealtimeKit Listeners
  // ─────────────────────────────────────────────────────────

  @override
  void onMeetingInitStarted() {
    debugPrint('$_logTag onMeetingInitStarted');
  }

  @override
  void onMeetingInitCompleted() {
    debugPrint('$_logTag onMeetingInitCompleted → calling joinRoom()');
    _meeting?.joinRoom(
      onSuccess: () {
        debugPrint(
          '$_logTag [MOBILE] joinRoom onSuccess — we are joining the room',
        );
      },
      onError: (error) {
        debugPrint('$_logTag joinRoom onError: $error');
        if (mounted) {
          setState(() {
            _error = 'Failed to join meeting room: ${error.toString()}';
          });
        }
      },
    );
  }

  @override
  void onMeetingInitFailed(MeetingError error) {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    // Log all available fields so we can see if this is auth / network / server.
    debugPrint('$_logTag onMeetingInitFailed ─────────────────');
    debugPrint('$_logTag   error.runtimeType: ${error.runtimeType}');
    debugPrint('$_logTag   error.toString():  ${error.toString()}');
    try {
      // MeetingError may expose .message / .code depending on SDK version.
      final dynamic e = error;
      if ((e as dynamic).message != null) {
        debugPrint('$_logTag   error.message: ${e.message}');
      }
    } catch (_) {}
    debugPrint('$_logTag ─────────────────────────────────────');
    if (mounted) {
      setState(() {
        _pageLoaded = true;
        _error =
            'Failed to initialize meeting.\n\n'
            'Details: ${error.toString()}\n\n'
            'Common causes:\n'
            '• Weak or no internet connection\n'
            '• Session token expired (go back and re-accept the call)\n'
            '• WebRTC blocked on your current network\n\n'
            'Tap Try Again or switch to a different network.';
      });
    }
  }

  @override
  void onMeetingRoomJoinStarted() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    debugPrint('$_logTag onMeetingRoomJoinStarted | _pageLoaded=true');
    if (mounted) {
      setState(() {
        // Ensure we hide the pre-join spinner when we actually start joining.
        _pageLoaded = true;
      });
    }
  }

  @override
  void onMeetingRoomJoinCompleted() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    debugPrint(
      '$_logTag [MOBILE] onMeetingRoomJoinCompleted — we have joined the room',
    );
    if (mounted) {
      setState(() {
        _isReady = true;
        _pageLoaded = true;
        _callStartedAt = DateTime.now();
      });
      _callDurationTimer?.cancel();
      _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      _bindChatListener();
      // SDK may populate participants asynchronously; force rebuilds to pick up joined/active
      for (final delayMs in [100, 300, 600, 1000]) {
        Future.delayed(Duration(milliseconds: delayMs), () {
          if (mounted && _meeting != null) setState(() {});
        });
      }
    }
  }

  @override
  void onMeetingRoomJoinFailed(MeetingError error) {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
    debugPrint(
      '$_logTag onMeetingRoomJoinFailed: $error | _pageLoaded=true, _error set',
    );
    if (mounted) {
      setState(() {
        _pageLoaded = true;
        _error = 'Failed to join meeting: ${error.toString()}';
      });
    }
  }

  @override
  void onMeetingEnded() {
    debugPrint('$_logTag onMeetingEnded → go home');
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  void onMeetingRoomLeaveStarted() {
    debugPrint('$_logTag onMeetingRoomLeaveStarted');
  }

  @override
  void onMeetingRoomLeaveCompleted() {
    debugPrint('$_logTag onMeetingRoomLeaveCompleted → cleanup & go home');
    if (mounted) {
      _meeting?.removeMeetingRoomEventListener(this);
      _meeting?.removeParticipantsEventListener(this);
      _meeting?.cleanAllNativeListeners();
      context.go(AppRoutes.home);
    }
  }

  @override
  void onActiveTabUpdate(ActiveTab? tab) {}

  @override
  void onSocketConnectionUpdate(SocketConnectionState connection) {
    debugPrint('$_logTag onSocketConnectionUpdate: $connection');
  }

  @override
  void onParticipantJoin(RtkRemoteParticipant participant) {
    debugPrint(
      '$_logTag [MOBILE] Someone joined the room: ${participant.name} (id=${participant.id})',
    );
    if (mounted) {
      setState(() {
        if (_firstRemoteFromCallback == null) {
          _firstRemoteFromCallback = participant;
        }
      });
    }
  }

  @override
  void onParticipantLeave(RtkRemoteParticipant participant) {
    debugPrint('$_logTag onParticipantLeave: ${participant.id}');
    if (mounted) {
      setState(() {
        if (_firstRemoteFromCallback?.id == participant.id) {
          _firstRemoteFromCallback = null;
        }
      });
    }
  }

  @override
  void onActiveParticipantsChanged(List<RtkRemoteParticipant> active) {
    if (mounted) setState(() {});
  }

  @override
  void onActiveSpeakerChanged(RtkRemoteParticipant? participant) {}

  @override
  void onAudioUpdate(RtkRemoteParticipant participant, bool isEnabled) {
    if (mounted) setState(() {});
  }

  @override
  void onVideoUpdate(RtkRemoteParticipant participant, bool isEnabled) {
    if (mounted) setState(() {});
  }

  @override
  void onNewBroadcastMessage(String type, Map<String, dynamic> payload) {}

  @override
  void onParticipantPinned(RtkRemoteParticipant participant) {}

  @override
  void onParticipantUnpinned(RtkRemoteParticipant participant) {}

  @override
  void onScreenShareUpdate(RtkRemoteParticipant participant, bool isEnabled) {
    if (mounted) setState(() {});
  }

  @override
  void onUpdate(RtkParticipants participants) {
    if (mounted) setState(() {});
  }

  Future<void> _initializeRealtimeKit() async {
    debugPrint('$_logTag _initializeRealtimeKit start');

    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;

    // Clean up any previous (failed) meeting client before creating a new one.
    if (_meeting != null) {
      try {
        _meeting!.removeMeetingRoomEventListener(this);
        _meeting!.removeParticipantsEventListener(this);
        if (_chatListener != null) {
          _meeting!.removeChatEventListener(_chatListener!);
          _chatListener = null;
        }
        _meeting!.cleanAllNativeListeners();
      } catch (e) {
        debugPrint('$_logTag _initializeRealtimeKit cleanup error: $e');
      }
      _meeting = null;
    }

    final callState = ref.read(callProvider);
    final token = callState.dyteToken;

    if (token == null || token.isEmpty) {
      debugPrint('$_logTag _initializeRealtimeKit: no token → _error set');
      setState(() {
        _error = 'Session token not found.\nPlease try again.';
      });
      return;
    }
    debugPrint(
      '$_logTag _initializeRealtimeKit: token present (length=${token.length}), creating meeting & calling init()',
    );

    // Log meeting ID from token so you can compare with web (must be same meeting)
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
        while (payload.length % 4 != 0) payload += '=';
        final decoded = utf8.decode(base64Url.decode(payload));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        final meetingId = json['meetingId'] ?? json['meeting_id'];
        if (meetingId != null) {
          debugPrint('$_logTag [MOBILE] Token meeting ID: $meetingId');
        }
      }
    } catch (_) {}

    try {
      final meeting = RealtimekitClient();
      _meeting = meeting;
      // Register both listeners BEFORE init() to avoid race conditions where
      // participant/room events fire during or immediately after init.
      meeting.addMeetingRoomEventListener(this);
      meeting.addParticipantsEventListener(this);

      final meetingInfo = RtkMeetingInfo(
        authToken: token,
        baseDomain: 'realtime.cloudflare.com',
      );

      meeting.init(meetingInfo);
      debugPrint(
        '$_logTag _initializeRealtimeKit: meeting.init() called, 30s timeout scheduled',
      );

      // Fallback guard: avoid stuck spinner if SDK events are delayed/unreceived.
      // Cancel this timer when we join successfully or hit init/join failure.
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = Timer(const Duration(seconds: 30), () {
        if (mounted && !_pageLoaded && _error == null) {
          debugPrint(
            '$_logTag 30s timeout fired → _pageLoaded=true, _error set (connection timeout)',
          );
          setState(() {
            _pageLoaded = true;
            _error =
                'Connecting is taking longer than expected.\n'
                'Please check you you internet connection.\n'
                'Then tap Try Again.';
          });
        }
      });
    } catch (e) {
      debugPrint('$_logTag _initializeRealtimeKit catch: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to set up video call.\n${e.toString()}';
        });
      }
    }
  }

  void _bindChatListener() {
    final meeting = _meeting;
    if (meeting == null || _chatListener != null) return;

    _chatListener = _VideoCallChatEventListener(
      onLatest: (messages) {
        debugPrint(
          '$_logTag [MOBILE] onChatUpdates: ${messages.length} messages (full list)',
        );
        for (var i = 0; i < messages.length; i++) {
          final msg = messages[i];
          final preview = msg is TextMessage ? msg.message : msg.toString();
          debugPrint(
            '$_logTag   msg[$i] userId=${msg.userId} preview=${preview.length > 40 ? "${preview.substring(0, 40)}..." : preview}',
          );
        }
        if (!mounted) return;
        setState(() {
          _chatMessages
            ..clear()
            ..addAll(messages);
        });
      },
      onNew: (message) {
        final preview = message is TextMessage
            ? message.message
            : message.toString();
        debugPrint(
          '$_logTag [MOBILE] onNewChatMessage received userId=${message.userId} preview=$preview',
        );
        if (!mounted) return;
        setState(() {
          _chatMessages.add(message);
        });
      },
    );

    meeting.addChatEventListener(_chatListener!);
    final existing = meeting.chat.messages;
    if (existing.isNotEmpty) {
      debugPrint(
        '$_logTag [MOBILE] chat bind: synced ${existing.length} existing messages',
      );
      setState(() {
        _chatMessages
          ..clear()
          ..addAll(existing);
      });
    } else {
      debugPrint('$_logTag [MOBILE] chat listener bound');
    }

    // Fallback: Doc says "meeting.chat.messages list is automatically updated" when
    // a message is received; if SDK does not call onChatUpdates/onNewChatMessage on
    // Flutter, polling this list still shows messages from web.
    _chatPollTimer?.cancel();
    _chatPollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      final m = _meeting;
      if (m == null || !mounted) return;
      final latest = m.chat.messages;
      if (latest.length != _chatMessages.length) {
        debugPrint(
          '$_logTag [MOBILE] poll sync: ${latest.length} messages (was ${_chatMessages.length})',
        );
        if (latest.isNotEmpty) {
          final first = latest.first;
          final last = latest.last;
          final firstPreview = first is TextMessage
              ? first.message
              : first.toString();
          final lastPreview = last is TextMessage
              ? last.message
              : last.toString();
          debugPrint('$_logTag   first: $firstPreview');
          debugPrint('$_logTag   last: $lastPreview');
        }
        if (mounted) {
          setState(() {
            _chatMessages
              ..clear()
              ..addAll(latest);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildErrorScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF08081A),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (_isReady && _meeting != null) _buildCoreCallUI(),

          if (!_pageLoaded) _buildLoadingScreen(),
        ],
      ),
    );
  }

  /// Minimal call UI using only realtimekit_core VideoView (lighter than UI kit, can reduce lag).
  Widget _buildCoreCallUI() {
    final m = _meeting!;
    final joined = m.participants.joined;
    final active = m.participants.active;
    // Prefer active (participants to display); then joined; then callback fallback.
    final firstRemote = active.isNotEmpty
        ? active.first
        : joined.isNotEmpty
        ? joined.first
        : _firstRemoteFromCallback;

    // Doctor info from latest appointment (current call)
    final appointment = ref.watch(latestAppointmentProvider).valueOrNull;
    final doctorName = (appointment?.doctorName.isNotEmpty == true)
        ? appointment!.doctorName
        : (firstRemote?.name.isNotEmpty == true ? firstRemote!.name : null);
    final displayName = doctorName ?? 'Waiting for participant';
    final subtitle = appointment?.doctorSpecialty ?? 'General Physician';

    debugPrint(
      '$_logTag _buildCoreCallUI: joined=${joined.length} active=${active.length} firstRemote=${firstRemote != null}',
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen remote video (or placeholder) — use Positioned.fill so VideoView gets valid size
        Positioned.fill(
          child: firstRemote != null
              ? firstRemote.videoEnabled
                    ? VideoView(
                        key: ValueKey('remote-${firstRemote.id}'),
                        meetingParticipant: firstRemote,
                      )
                    : _buildRemotePlaceholder(firstRemote)
              : Container(
                  color: const Color(0xFF12122A),
                  child: Center(
                    child: Text(
                      displayName == 'Waiting for participant'
                          ? 'Waiting for doctor to join…'
                          : 'Waiting for $displayName to join…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
        ),
        // Top section: call timer (left), participant avatar + name + subtitle (center), PiP (top-right, no overlap)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Call timer badge (top-left)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatCallDuration(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Center: large avatar + name + subtitle (no PiP here)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Large circular avatar with gradient
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF6C47FF), Color(0xFF8B6CF7)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6C47FF,
                                ).withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child:
                              displayName != 'Waiting for participant' &&
                                  displayName.isNotEmpty
                              ? ClipOval(
                                  child: Center(
                                    child: Text(
                                      displayName
                                          .trim()
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 44,
                                  color: Colors.white70,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // PiP self-view at top-right, not overlapping doctor
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 64,
                      height: 86,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const VideoView(
                            meetingParticipant: null,
                            isSelfParticipant: true,
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(
                              Icons.videocam,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bottom controls — order: Mic | Video | End Call | Chat (with badge)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(
                  icon: m.localUser.audioEnabled ? Icons.mic : Icons.mic_off,
                  label: m.localUser.audioEnabled ? 'Mute' : 'Unmute',
                  onPressed: () {
                    if (m.localUser.audioEnabled) {
                      m.localUser.disableAudio(
                        onResult: (e) {
                          if (mounted) setState(() {});
                        },
                      );
                    } else {
                      m.localUser.enableAudio(
                        onResult: (e) {
                          if (mounted) setState(() {});
                        },
                      );
                    }
                  },
                ),
                _controlButton(
                  icon: m.localUser.videoEnabled
                      ? Icons.videocam
                      : Icons.videocam_off,
                  label: m.localUser.videoEnabled ? 'Video off' : 'Video on',
                  onPressed: () {
                    if (m.localUser.videoEnabled) {
                      m.localUser.disableVideo(
                        onResult: (e) {
                          if (mounted) setState(() {});
                        },
                      );
                    } else {
                      m.localUser.enableVideo(
                        onResult: (e) {
                          if (mounted) setState(() {});
                        },
                      );
                    }
                  },
                ),
                _controlButton(
                  icon: Icons.call_end_rounded,
                  label: 'Leave',
                  onPressed: () {
                    _meeting?.leaveRoom(onSuccess: () {}, onError: (_) {});
                  },
                  backgroundColor: Colors.red,
                ),
                _controlButton(
                  icon: Icons.chat,
                  label: 'Chat',
                  onPressed: () {
                    if (!mounted || _meeting == null) return;
                    _bindChatListener();
                    final chatDoctorName =
                        appointment?.doctorName.isNotEmpty == true
                        ? appointment!.doctorName
                        : (active.isNotEmpty
                              ? active.first.name
                              : joined.isNotEmpty
                              ? joined.first.name
                              : _firstRemoteFromCallback?.name);
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute<void>(
                            builder: (_) => InCallChatScreen(
                              meeting: _meeting,
                              doctorName: chatDoctorName,
                            ),
                          ),
                        )
                        .then((_) {
                          if (mounted) {
                            setState(() {
                              _chatReadCount = _chatMessages.length;
                            });
                          }
                        });
                  },
                  badgeCount: _chatUnreadCount,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemotePlaceholder(RtkRemoteParticipant participant) {
    return Container(
      color: const Color(0xFF12122A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C47FF).withValues(alpha: 0.3),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 56,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              participant.name.isNotEmpty ? participant.name : 'Participant',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Camera off',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    int? badgeCount,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  constraints: const BoxConstraints(minWidth: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A27C2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  LOADING SCREEN
  // ─────────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF08081A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6C47FF).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6C47FF), Color(0xFF2BBCF7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6C47FF,
                            ).withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: CircleAvatar(
                          backgroundColor: Color(0xFF12122A),
                          child: Icon(
                            Icons.person_rounded,
                            size: 52,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Joining Call...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Setting up your video session',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Use Wi‑Fi for a more reliable connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Connecting to call...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DotLoadingIndicator(),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white38,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.white12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ERROR SCREEN
  // ─────────────────────────────────────────────────────────
  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF08081A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.signal_wifi_connected_no_internet_4_rounded,
                    color: Colors.redAccent,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Connection Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _pageLoaded = false;
                      });
                      _initializeRealtimeKit();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C47FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Dashboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: const BorderSide(color: Colors.white12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoCallChatEventListener extends RtkChatEventListener {
  final void Function(List<ChatMessage>) onLatest;
  final void Function(ChatMessage) onNew;

  _VideoCallChatEventListener({required this.onLatest, required this.onNew});

  /// Doc: onChatUpdates receives the full list of all chat messages in the meeting.
  @override
  void onChatUpdates(List<ChatMessage> messages) {
    onLatest(messages);
  }

  /// Doc: onNewChatMessage is called for each new message (optional; meeting.chat.messages is also updated).
  @override
  void onNewChatMessage(ChatMessage message) {
    onNew(message);
  }
}

class _DotLoadingIndicator extends StatefulWidget {
  @override
  State<_DotLoadingIndicator> createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<_DotLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index / 3;
            final t = ((_controller.value - delay) % 1.0 + 1.0) % 1.0;
            final scale = 0.5 + 0.5 * (1 - (t * 2 - 1).abs().clamp(0, 1));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(
                      const Color(0xFF6C47FF),
                      const Color(0xFF2BBCF7),
                      index / 2,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
