import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanState {
  final String? qrCode;
  final bool isScanning;
  final bool isError;
  final String? errorMessage;
  final bool isSuccess;
  final String? successMessage;

  const QrScanState({
    this.isScanning = false,
    this.qrCode,
    this.isError = false,
    this.errorMessage,
    this.isSuccess = false,
    this.successMessage,
  });

  QrScanState copyWith({
    bool? isScanning,
    String? qrCode,
    bool? isError,
    String? errorMessage,
    bool? isSuccess,
    String? successMessage,
  }) {
    return QrScanState(
      isScanning: isScanning ?? this.isScanning,
      qrCode: qrCode ?? this.qrCode,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class QrScanController extends AutoDisposeNotifier<QrScanState> {
  StreamSubscription<Barcode>? _subscription;
  QRViewController? _controller;
  bool _isResuming = false;

  @override
  QrScanState build() {
    ref.onDispose(() async {
      await _subscription?.cancel();
      _subscription = null;
      _controller?.dispose();
      _controller = null;
    });

    return const QrScanState();
  }

  void onViewCreated(QRViewController controller) {
    try {
      _controller = controller;
      _subscription?.cancel();
      _subscription = controller.scannedDataStream.listen((barcode) async {
        final code = barcode.code;
        if (code == null || code.isEmpty) return;

        if (state.qrCode != null) return;

        state = state.copyWith(isScanning: false, qrCode: code);
        await _controller?.pauseCamera();
      });
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    }
  }

  void onPermissionSet(bool granted) {
    if (granted) return;
    state = state.copyWith(
      isScanning: false,
      isError: true,
      errorMessage: 'Camera permission denied',
    );
  }

  Future<void> pause() async {
    try {
      await _controller?.pauseCamera();
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    }
  }

  Future<void> resume() async {
    if (_isResuming) return;
    _isResuming = true;
    try {
      if (state.isScanning) return;
      state = state.copyWith(isScanning: true);
      await _controller?.resumeCamera();
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      _isResuming = false;
    }
  }

  Future<void> toggleFlash() async {
    try {
      await _controller?.toggleFlash();
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    }
  }
}
