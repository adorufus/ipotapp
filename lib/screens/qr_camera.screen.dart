import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/components/app_scaffold.dart';
import 'package:ipotapp/utils/color_utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'controllers/qr_scan.controller.dart';
import 'providers/qr_scan.provider.dart';

class QrCameraScreen extends ConsumerStatefulWidget {
  const QrCameraScreen({super.key});

  @override
  ConsumerState<QrCameraScreen> createState() => _QrCameraScreenState();
}

class _QrCameraScreenState extends ConsumerState<QrCameraScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    // qr_code_scanner recommends handling camera pause/resume on hot reload.
    if (Platform.isAndroid) {
      ref.read(qrScanControllerProvider.notifier).pause();
    }
    ref.read(qrScanControllerProvider.notifier).resume();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrScanControllerProvider);

    ref.listen<QrScanState>(qrScanControllerProvider, (previous, next) {
      if (next.isError && next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      // Once we have a QR code, close this screen and return it.
      if (previous?.qrCode == null && next.qrCode != null) {
        Navigator.of(context).pop(next.qrCode);
      }
    });

    return AppScaffold(
      title: 'Scan QR Code',
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          tooltip: 'Toggle flash',
          onPressed: () {
            ref.read(qrScanControllerProvider.notifier).toggleFlash();
          },
          icon: const Icon(Icons.flash_on, color: AppColors.neutral),
        ),
        IconButton(
          tooltip: 'Info',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Info coming soon')),
            );
          },
          icon: const Icon(Icons.info_outline, color: AppColors.neutral),
        ),
      ],
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: ref
                .read(qrScanControllerProvider.notifier)
                .onViewCreated,
            onPermissionSet: (ctrl, granted) {
              ref
                  .read(qrScanControllerProvider.notifier)
                  .onPermissionSet(granted);
            },
            overlay: QrScannerOverlayShape(
              borderColor: AppColors.secondary,
              borderRadius: 12,
              borderLength: 28,
              borderWidth: 6,
              cutOutSize: 260,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.isScanning
                              ? 'Point your camera at the QR code.'
                              : 'Tap the camera to start scanning.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.secondary,
                        ),
                        onPressed: () {
                          ref.read(qrScanControllerProvider.notifier).resume();
                        },
                        child: const Text('Scan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
