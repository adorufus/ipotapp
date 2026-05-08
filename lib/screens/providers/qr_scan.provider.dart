import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/screens/controllers/qr_scan.controller.dart';

final qrScanControllerProvider =
    NotifierProvider.autoDispose<QrScanController, QrScanState>(
      QrScanController.new,
    );
