import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String key = "xnd_development_cHGpi5KngZnfzU0FMqhaoxElD7qe5ujiuOgA2ac313wpZOvPIeFujQNiSlTQZKt";
  double totalStorageGB = 0.00;

  void _confirmPurchase(int price, double gb) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Confirm Subscription'),
        message: Text('Add ${gb.toStringAsFixed(0)} GB to your Gigafy Cloud for ₱$price?'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _processTransaction(price, gb);
            },
            child: const Text('Confirm Purchase'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _processTransaction(int price, double gb) async {
    // Show loading dialog
    showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const CupertinoAlertDialog(
            content: Column(
              children: [
                SizedBox(height: 10),
                CupertinoActivityIndicator(radius: 15),
                SizedBox(height: 15),
                Text("Connecting to Secure Gateway...", style: TextStyle(fontSize: 14)),
              ],
            ),
          );
        });

    final url = "https://api.xendit.co/v2/invoices";
    String auth = ' Basic ' + base64Encode(utf8.encode(key));

    try {
      // Create Invoice via Xendit API
      final response = await http.post(Uri.parse(url),
          headers: {"Authorization": auth, "Content-Type": "application/json"},
          body: jsonEncode({
            "external_id": "gigafy_${DateTime.now().millisecondsSinceEpoch}",
            "amount": price,
            "description": "${gb.toStringAsFixed(0)} GB Gigafy Storage"
          }));

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (data["invoice_url"] != null) {
        // Navigate to Webview for payment
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => PaymentPage(url: data["invoice_url"])));

        // Start polling for payment success
        _pollPaymentStatus(data["id"], auth, gb);
      } else {
        debugPrint("Error creating invoice: ${response.body}");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close dialog on error
      debugPrint("Transaction Error: $e");
    }
  }



  Future<void> _pollPaymentStatus(String id, String auth, double gb) async {
    // Check status every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final url = "https://api.xendit.co/v2/invoices/" + id;
      try {
        final response = await http.get(Uri.parse(url), headers: {"Authorization": auth});
        final data = jsonDecode(response.body);

        if (data["status"] == "PAID") {
          timer.cancel();

          if (mounted) {
            setState(() {
              totalStorageGB += gb;
            });

            // Close the WebView Page
            if (Navigator.canPop(context)) Navigator.pop(context);

            // Show Success Dialog
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: const Text("Storage Expanded"),
                  content: Text(
                      "You now have ${totalStorageGB.toStringAsFixed(0)} GB total storage."),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text("Done"),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                );
              },
            );
          }
        } else if (data["status"] == "EXPIRED") {
          timer.cancel();
        }
      } catch (e) {
        timer.cancel();
        debugPrint("Polling Error: $e");
      }
    });
  }

  Widget _buildPlanCard(double gb, int price, Color accent) {
    return GestureDetector(
      onTap: () => _confirmPurchase(price, gb),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondarySystemGroupedBackground, context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
            border: Border.all(color: accent.withOpacity(0.15), width: 1.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(CupertinoIcons.layers_alt_fill, color: accent, size: 24),
            ),
            const Spacer(),
            Text(
              '${gb.toStringAsFixed(0)} GB',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
            ),
            const SizedBox(height: 6),
            Text(
              '₱$price',
              style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context),
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text("Gigafy"),
            backgroundColor: Color(0x00000000),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 290,
                      width: 290,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.secondarySystemGroupedBackground,
                              context),
                          boxShadow: [
                            BoxShadow(
                                color: CupertinoColors.activeBlue.withOpacity(0.12),
                                blurRadius: 40,
                                spreadRadius: 2)
                          ]),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 230,
                            height: 230,
                            child: CustomPaint(
                              painter: StorageRingPainter(
                                percentage: 0.85, // Visual demo
                                color: CupertinoColors.activeBlue,
                                backgroundColor: CupertinoColors.systemGrey6.resolveFrom(context),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                totalStorageGB.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -3.0,
                                    height: 1),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "GB AVAILABLE",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    "Upgrade Capacity",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPlanCard(15, 249, CupertinoColors.activeBlue),
                        _buildPlanCard(50, 449, CupertinoColors.systemIndigo),
                        _buildPlanCard(100, 649, CupertinoColors.systemOrange),
                        _buildPlanCard(200, 849, CupertinoColors.systemPink),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondarySystemGroupedBackground,
                          context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.checkmark_shield_fill,
                              color: CupertinoColors.systemGreen),
                        ),
                        const SizedBox(width: 15),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Status: Active",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Your files are encrypted.",
                                style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StorageRingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  StorageRingPainter({required this.percentage, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const strokeWidth = 24.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PaymentPage extends StatefulWidget {
  final String url;
  const PaymentPage({super.key, required this.url});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
            middle: Text("Secure Payment")
        ),
        child: WebViewWidget(controller: controller));
  }
}