import 'dart:async';

import 'package:camera/camera.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'package:flutter/material.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';

class LivenessVerificationScreen extends StatefulWidget {
  const LivenessVerificationScreen({super.key});

  @override
  State<LivenessVerificationScreen> createState() =>
      _LivenessVerificationScreenState();
}

class _LivenessVerificationScreenState
    extends State<LivenessVerificationScreen> {
  late final LivenessDetector _detector;
  StreamSubscription<LivenessState>? _subscription;

  String _instruction = 'Initializing camera...';
  bool _isReady = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  Future<void> _startVerification() async {
    setState(() {
      _instruction = 'Initializing camera...';
      _isReady = false;
      _hasFailed = false;
    });

    try {
      _detector = LivenessDetector(
        const LivenessConfig(
          challenges: [
            ChallengeType.smile,
            ChallengeType.blink,
          ],
          enableAntiSpoofing: true,
          challengeTimeout: Duration(seconds: 20),
          sessionTimeout: Duration(minutes: 2),
        ),
      );

      _subscription = _detector.stateStream.listen(_handleState);

      await _detector.initialize();
      await _detector.start();

      if (!mounted) return;

      setState(() {
        _isReady = true;
        _instruction = 'Position your face inside the camera area.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _hasFailed = true;
        _instruction =
            'Unable to start verification. Please check camera permission.';
      });
    }
  }

  void _handleState(LivenessState state) {
    if (!mounted) return;

    switch (state.type) {
      case LivenessStateType.initialized:
        setState(() => _instruction = 'Camera ready. Position your face.');
        break;

      case LivenessStateType.detecting:
        setState(() => _instruction = 'Looking for your face...');
        break;

      case LivenessStateType.noFace:
        setState(() => _instruction = 'No face detected. Move into view.');
        break;

      case LivenessStateType.faceDetected:
      case LivenessStateType.positioning:
        setState(() => _instruction = 'Center your face in the frame.');
        break;

      case LivenessStateType.positioned:
        setState(() => _instruction = 'Hold still. Challenge starting...');
        break;

      case LivenessStateType.challengeInProgress:
        setState(() {
          _instruction =
              state.currentChallenge?.instruction ?? 'Complete the challenge.';
        });
        break;

      case LivenessStateType.challengeCompleted:
        setState(() => _instruction = 'Challenge completed. Keep going...');
        break;

      case LivenessStateType.completed:
        Navigator.pop(context, true);
        break;

      case LivenessStateType.error:
        setState(() {
          _hasFailed = true;
          _instruction =
              state.error?.message ?? 'Verification failed. Try again.';
        });
        break;
    }
  }

  Future<void> _retry() async {
    await _subscription?.cancel();
    await _detector.dispose();
    await _startVerification();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _isReady ? _detector.cameraController : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Access'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: cameraController == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(cameraController),
                    Center(
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      left: 18,
                      right: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _instruction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Icon(
                    _hasFailed
                        ? Icons.error_outline
                        : Icons.verified_user_outlined,
                    color: _hasFailed ? AppColors.expense : AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_hasFailed)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _retry,
                  child: const Text('Try Again'),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}