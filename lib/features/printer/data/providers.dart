import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../../../../core/models/bill.dart';
import 'package:permission_handler/permission_handler.dart';

final printerProvider = StateNotifierProvider<PrinterNotifier, AsyncValue<void>>((ref) {
  return PrinterNotifier();
});

class PrinterNotifier extends StateNotifier<AsyncValue<void>> {
  PrinterNotifier() : super(const AsyncValue.data(null));

  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  bool _isPrinting = false;

  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isPrinting => _isPrinting;
  bool get isConnected => _connectedDevice != null;

  Future<void> startScan() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      _isScanning = true;
      state = const AsyncValue.loading();
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        state = AsyncValue.data(null);
      });
      state = const AsyncValue.data(null);
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
    state = const AsyncValue.data(null);
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
      _connectedDevice = null;
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> printBill(Bill bill, String shopName) async {
    if (_connectedDevice == null) return;

    _isPrinting = true;
    state = const AsyncValue.loading();
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      final bytes = Uint8List.fromList(
        generator.text(shopName) +
            generator.hr() +
            generator.text('Bill ${bill.id.substring(0, 8)}') +
            generator.text('Total: ${bill.total.toString()}'),
      );
      final services = await _connectedDevice!.discoverServices();
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.properties.write) {
            await char.write(bytes, withoutResponse: true);
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isPrinting = false;
    }
  }
}