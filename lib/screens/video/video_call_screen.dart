import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtimekit_core/realtimekit_core.dart';
import '../../utils/app_routes.dart';
import '../../providers/call_provider.dart';

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

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  static const String _logTag = '[VideoCall]';

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
        debugPrint('$_logTag joinRoom onSuccess (room join in progress)');
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
    debugPrint('$_logTag onMeetingInitFailed: $error | _pageLoaded=true, _error set');
    if (mounted) {
      setState(() {
        _pageLoaded = true;
        _error = 'Failed to initialize meeting: ${error.toString()}';
      });
    }
  }

  @override
  void onMeetingRoomJoinStarted() {
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
    debugPrint('$_logTag onMeetingRoomJoinCompleted | _isReady=true, _pageLoaded=true');
    if (mounted) {
      setState(() {
        _isReady = true;
        _pageLoaded = true;
      });
    }
  }

  @override
  void onMeetingRoomJoinFailed(MeetingError error) {
    debugPrint('$_logTag onMeetingRoomJoinFailed: $error | _pageLoaded=true, _error set');
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
    debugPrint('$_logTag onParticipantJoin: ${participant.name} (${participant.id})');
    if (mounted) setState(() {});
  }

  @override
  void onParticipantLeave(RtkRemoteParticipant participant) {
    debugPrint('$_logTag onParticipantLeave: ${participant.id}');
    if (mounted) setState(() {});
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
    final callState = ref.read(callProvider);
    final token = callState.dyteToken;

    if (token == null || token.isEmpty) {
      debugPrint('$_logTag _initializeRealtimeKit: no token → _error set');
      setState(() {
        _error = 'Session token not found.\nPlease try again.';
      });
      return;
    }
    debugPrint('$_logTag _initializeRealtimeKit: token present (length=${token.length}), creating meeting & calling init()');

    try {
      final meeting = RealtimekitClient();
      _meeting = meeting;
      meeting.addMeetingRoomEventListener(this);

      final meetingInfo = RtkMeetingInfo(
        authToken: token,
        baseDomain: 'realtime.cloudflare.com',
      );

      meeting.init(meetingInfo);
      meeting.addParticipantsEventListener(this);
      debugPrint('$_logTag _initializeRealtimeKit: meeting.init() called, 30s timeout scheduled');

      // Fallback guard: avoid stuck spinner if SDK events are delayed/unreceived.
      // Often caused by network (e.g. WebRTC blocked on cellular or restrictive Wi‑Fi).
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && !_pageLoaded && _error == null) {
          debugPrint('$_logTag 30s timeout fired → _pageLoaded=true, _error set (connection timeout)');
          setState(() {
            _pageLoaded = true;
            _error =
                'Connecting is taking longer than expected.\n\n'
                'To avoid this:\n'
                '• Use Wi‑Fi instead of mobile data\n'
                '• Turn off VPN if you use one\n'
                '• Move closer to your router\n\n'
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

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildErrorScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF08081A),
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
    final remoteParticipants = m.participants.joined;
    final firstRemote = remoteParticipants.isNotEmpty
        ? remoteParticipants.first
        : null;

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
                      'Waiting for others…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
        ),
        // Self video (pip) — SDK requires meetingParticipant to be null when isSelfParticipant is true
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          width: 120,
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const VideoView(
              meetingParticipant: null,
              isSelfParticipant: true,
            ),
          ),
        ),
        // Bottom controls
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom + 24,
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
            ],
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
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
