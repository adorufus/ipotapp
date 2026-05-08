import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/qr_scan.provider.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrScanControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Table ${state.qrCode?.split('/').last}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(qrScanControllerProvider.notifier).pause();
        },

        child: Icon(Icons.list_alt),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text('Table ${state.qrCode?.split('/').last}')],
      ),
    );
  }
}
