import 'package:flutter/material.dart';
import 'barcode_scanner_analyze_image.dart';
import 'barcode_scanner_controller.dart';
import 'barcode_scanner_listview.dart';
import 'barcode_scanner_pageview.dart';
import 'barcode_scanner_returning_image.dart';
import 'barcode_scanner_simple.dart';
import 'barcode_scanner_window.dart';
import 'barcode_scanner_zoom.dart';
import 'mobile_scanner_overlay.dart';

class mobile_scanner_example extends StatelessWidget {
  const mobile_scanner_example({super.key});

  Widget _buildItem(BuildContext context, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => page,
              ),
            );
          },
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner Example')),
      body: Center(
        child: ListView(
          children: [
            _buildItem(
              context,
              'MobileScanner Simple',
              const BarcodeScannerSimple(),
            ),
            _buildItem(
              context,
              'MobileScanner with ListView',
              const BarcodeScannerListView(),
            ),
            _buildItem(
              context,
              'MobileScanner with Controller',
              const BarcodeScannerWithController(),
            ),
            _buildItem(
              context,
              'MobileScanner with ScanWindow',
              const BarcodeScannerWithScanWindow(),
            ),
            _buildItem(
              context,
              'MobileScanner with Controller (return image)',
              const BarcodeScannerReturningImage(),
            ),
            _buildItem(
              context,
              'MobileScanner with zoom slider',
              const BarcodeScannerWithZoom(),
            ),
            _buildItem(
              context,
              'MobileScanner with PageView',
              const BarcodeScannerPageView(),
            ),
            _buildItem(
              context,
              'MobileScanner with Overlay',
              const BarcodeScannerWithOverlay(),
            ),
            _buildItem(
              context,
              'Analyze image from file',
              const BarcodeScannerAnalyzeImage(),
            ),
          ],
        ),
      ),
    );
  }
}
