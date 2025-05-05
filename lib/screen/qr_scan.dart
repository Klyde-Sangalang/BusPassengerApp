import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/bus_model.dart';
import '../notifier/auth_notifier.dart';
import '../notifier/bus_notifier.dart';

class QrScanScreen extends HookConsumerWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buses = ref.watch(busDataProvider);
    final user = ref.watch(authNotifierProvider);

    useEffect(() {
      ref.read(busDataProvider.notifier).loadBuses();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: MobileScanner(
          controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
          ),
          onDetect: (capture) async {
            final List<Barcode> barcodes = capture.barcodes;
            final Uint8List? image = capture.image;
            final rawValues =
                barcodes.map((barcode) => barcode.rawValue).join();

            final busId = rawValues.trim(); // busId from QR

            final bus = buses.firstWhere(
              (bus) => bus.userId == busId,
              orElse: () => Bus(
                userId: '',
                firstName: '',
                lastName: '',
                busNumber: '',
                email: '',
                destinations: [],
                passengerNames: [],
              ),
            );

            if (bus.passengerNames.contains(user?.uid)) {
              ref
                  .read(busDataProvider.notifier)
                  .removePassenger(busId, user!.uid);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'You left the bus',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              Navigator.of(context).pop();
            } else {
              ref.read(busDataProvider.notifier).addPassenger(busId, user!.uid);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'You entered the bus',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              Navigator.of(context).pop();
            }
          }),
    );
  }
}
