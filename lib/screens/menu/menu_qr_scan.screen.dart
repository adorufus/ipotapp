import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ipotapp/components/app_button.dart';
import 'package:ipotapp/l10n/app_localizations.dart';
import 'package:ipotapp/utils/color_utils.dart';

import 'qr_camera.screen.dart';
import 'widgets/qr_scan_widgets.dart';
import 'providers/qr_scan.provider.dart';

/// Menu tab body (used inside [AppShellScreen] [IndexedStack]).
class QrScanTab extends ConsumerWidget {
  const QrScanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(child: HeroBackground()),
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 50.h),
                            Text(
                              l10n.readyToOrder,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                height: 38 / 30,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 32),
                            GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.scanTableInstruction,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 24 / 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.mutedOnLight,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const QrPlaceholder(),
                                    const SizedBox(height: 24),
                                    AppButton(
                                      label: l10n.scanToOrder,
                                      leading: const Icon(
                                        Icons.photo_camera_outlined,
                                      ),
                                      height: 56,
                                      shape: const StadiumBorder(),
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        height: 26 / 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder<void>(
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => const QrCameraScreen(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    AppButton(
                                      label: l10n.bypassQrTableT001,
                                      leading: const Icon(Icons.bolt_outlined),
                                      height: 52,
                                      shape: const StadiumBorder(),
                                      variant: AppButtonVariant.outlined,
                                      onPressed: () {
                                        ref
                                            .read(
                                              qrScanControllerProvider.notifier,
                                            )
                                            .bypassWithTableId('T001');
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const PulseDot(),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.activeTableConnection,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 16 / 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
        ],
      ),
    );
  }
}
