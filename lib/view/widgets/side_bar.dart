import 'dart:io';
import 'dart:typed_data';

import 'package:ezbooking_admin/core/utils/dialogs.dart';
import 'package:ezbooking_admin/core/utils/image_helper.dart';
import 'package:ezbooking_admin/providers/statistics/statistic_provider.dart';
import 'package:ezbooking_admin/view/page/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class Sidebar extends StatefulWidget {
  int selectedIndex;
  final Function(int) onTabChange;

  Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  State<Sidebar> createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 3000),
      curve: Curves.ease,
      child: Container(
        color: const Color(0xFF1F2937), // Dark background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo and Brand
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageHelper.loadAssetImage(
                    'assets/images/logo.png', // Add your logo image
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ez Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Menu Items
            _buildMenuItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              isActive: widget.selectedIndex == 0,
              onTap: () => widget.onTabChange(0),
            ),
            _buildMenuItem(
              icon: Icons.seventeen_mp_outlined,
              title: 'Management',
              isActive: widget.selectedIndex == 1,
              hasSubMenu: true,
              onTap: () {
                widget.onTabChange(1);
              },
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              isActive: widget.selectedIndex == 2,
              onTap: () {
                DialogUtils.showConfirmationDialog(
                  context: context,
                  size: MediaQuery.of(context).size,
                  title: "Are you sure you want to logout?",
                  textCancelButton: "No",
                  textAcceptButton: "Yes",
                  acceptPressed: () async {
                    DialogUtils.showLoadingDialog(context);
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminLoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                );
              },
            ),

            const Spacer(),
            //
            // // Bottom Summary Report Button
            // GestureDetector(
            //   onTap: () async {},
            //   child: Padding(
            //     padding: const EdgeInsets.all(20),
            //     child: Container(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //       decoration: BoxDecoration(
            //         color: const Color(0xFF059669), // Green color
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       child: const Row(
            //         children: [
            //           Icon(
            //             Icons.summarize,
            //             color: Colors.white,
            //             size: 20,
            //           ),
            //           SizedBox(width: 12),
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 'Get summary',
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //               ),
            //               Text(
            //                 'Report now',
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: 12,
            //                 ),
            //               ),
            //             ],
            //           ),
            //           Spacer(),
            //           Icon(
            //             Icons.arrow_forward,
            //             color: Colors.white,
            //             size: 20,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // Footer
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'EZ Booking Admin',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2024 All rights reserved',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    bool hasSubMenu = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? const Color(0xFF059669) : Colors.transparent,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: hasSubMenu
            ? Icon(
                isActive ? Icons.arrow_drop_down_outlined : Icons.arrow_right,
                color: Colors.white70,
              )
            : null,
      ),
    );
  }
}

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({
    super.key,
    required this.pdf,
  });

  final Uint8List pdf;

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  late StatisticProvider statisticProvider;

  @override
  void initState() {
    statisticProvider = Provider.of<StatisticProvider>(context, listen: false);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   statisticProvider.fetchStatistics();
    // });
    super.initState();
    initPDF();
  }

  initPDF() async {
    // Option 1: Save PDF to device
    final file = await generateAndSavePdf();
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved: ${file.path}')),
      );
    }

    // Option 2: Preview PDF
    final pdf = await generatePdfDocument();
    // await previewPdf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('PDF Preview')),
      body: PdfPreview(
        build: (format) => widget.pdf,
      ),
    );
  }

  // Generate and save PDF
  Future<File?> generateAndSavePdf() async {
    try {
      // Create PDF document
      final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

      // Add pages to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => _buildPdfContent(),
        ),
      );

      // Get the documents directory
      // final directory = await getApplicationDocumentsDirectory();

      // Create a unique filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('/statistics_report_$timestamp.pdf');

      // Save the PDF
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  // Generate PDF content
  List<pw.Widget> _buildPdfContent() {
    // Calculate summary metrics
    // final totalRevenue = _calculateTotalRevenue();
    // final totalTicketsSold = _calculateTotalTicketsSold();
    // final eventCounts = _calculateEventCounts();
    // final revenueByEvent = _calculateRevenueByEvent();

    return [
      // Title
      pw.Header(
        level: 0,
        child: pw.Text(
          'Event Statistics Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),

      // Overall Summary
      pw.Paragraph(
        text:
            'Report Generated: By EzBooking - ${DateFormat("dd-MM-yyyy hh:mm").format(
          DateTime.now().toUtc().add(
                const Duration(hours: 7),
              ),
        )}',
      ),

      pw.Paragraph(
        text: 'Total Revenue: \$',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),

      pw.Paragraph(
        text: 'Total Tickets Sold: ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),

      // Event Distribution
      pw.Header(
        level: 1,
        child: pw.Text('Ticket Sales by Event'),
      ),
      pw.Table.fromTextArray(
        context: null,
        data: [
          ['Event', 'Tickets Sold'],
        ],
      ),

      // Revenue by Event
      pw.Header(
        level: 1,
        child: pw.Text('Revenue by Event'),
      ),
      pw.Table.fromTextArray(
        context: null,
        data: [
          ['Event', 'Revenue'],
        ],
      ),

      // Detailed Statistics
      pw.Header(
        level: 1,
        child: pw.Text('Detailed Statistics'),
      ),
      pw.Table.fromTextArray(
        context: null,
        data: [
          ['Event', 'Tickets', 'Revenue', 'Date'],
        ],
      ),
    ];
  }

  // Generate PDF Document (used for preview and saving)
  Future<Uint8List> generatePdfDocument() async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => _buildPdfContent(),
      ),
    );

    return pdf.save();
  }
}
