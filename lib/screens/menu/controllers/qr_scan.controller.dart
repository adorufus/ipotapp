import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:ipotapp/screens/menu/ipot_table_qr.dart';

const Object _errorMessageUnset = Object();

/// Set on [QrScanState.errorMessage] when the scanned payload is not
/// `ipot://table/{tableId}`. UI maps this to [AppLocalizations.invalidTableQr].
const String kInvalidTableQrSnackKey = '__invalid_table_qr__';

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
    Object? errorMessage = _errorMessageUnset,
    bool? isSuccess,
    String? successMessage,
  }) {
    return QrScanState(
      isScanning: isScanning ?? this.isScanning,
      qrCode: qrCode ?? this.qrCode,
      isError: isError ?? this.isError,
      errorMessage: identical(errorMessage, _errorMessageUnset)
          ? this.errorMessage
          : errorMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class QrScanController extends AutoDisposeNotifier<QrScanState> {
  StreamSubscription<Barcode>? _subscription;
  QRViewController? _controller;
  bool _isResuming = false;
  bool _handlingInvalidQr = false;
  bool _disposed = false;

  @override
  QrScanState build() {
    _disposed = false;
    ref.onDispose(() async {
      _disposed = true;
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
        if (_handlingInvalidQr) return;

        final code = barcode.code;
        if (code == null || code.isEmpty) return;

        if (state.qrCode != null) return;

        if (!isValidIpotTableQr(code)) {
          await _rejectInvalidQr();
          return;
        }

        state = state.copyWith(
          isScanning: false,
          qrCode: code,
          isError: false,
          errorMessage: null,
        );
        await _controller?.pauseCamera();
      });
    } catch (e) {
      state = state.copyWith(isError: true, errorMessage: e.toString());
    }
  }

  Future<void> _rejectInvalidQr() async {
    _handlingInvalidQr = true;
    try {
      await _controller?.pauseCamera();
      state = state.copyWith(
        isScanning: false,
        isError: true,
        errorMessage: kInvalidTableQrSnackKey,
      );
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (_disposed) return;
      state = state.copyWith(
        isScanning: true,
        isError: false,
        errorMessage: null,
      );
      await _controller?.resumeCamera();
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      _handlingInvalidQr = false;
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

  /// Temporary helper for development until we have a full table connection flow.
  void bypassWithTableId(String tableId) {
    final fakeQr = 'ipot://table/$tableId';
    state = state.copyWith(
      isScanning: false,
      qrCode: fakeQr,
      isError: false,
      errorMessage: null,
      isSuccess: true,
      successMessage: 'Connected to Table $tableId',
    );
  }
}
