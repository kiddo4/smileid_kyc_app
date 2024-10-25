import 'package:flutter/material.dart';
import 'package:smile_id/smile_id.dart';
import 'package:smile_id/smileid_messages.g.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Ready';
  bool _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   initPlatformState();
  // }

  // Future<void> initPlatformState() async {
  //   if (!mounted) return;
  //   try {
  //     SmileID.initialize(
  //       useSandbox: true, // Using sandbox for testing
  //     );
  //     setState(() {
  //       _status = 'Initialized successfully';
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _status = 'Initialization failed: $e';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmileID KYC Demo'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Status: $_status',
                style: TextStyle(
                  color: _status.contains('failed') ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                enhancedKycAsyncButton(),
            ],
          ),
        ),
      ),
    );
  }

    Widget enhancedKycAsyncButton() {
    return ElevatedButton(
      child: const Text("Enhanced KYC (Async)"),
      onPressed: () async {
        setState(() {
          _isLoading = true;
          _status = 'Starting KYC process...';
        });

        try {
          // SmileID.initialize(
          // //   useSandbox: true,
          // );
          var userId = "1234";

          // First step: Authentication
          setState(() {
            _status = 'Authenticating...';
          });

          final authResponse = await SmileID.api.authenticate(
            FlutterAuthenticationRequest(
              jobType: FlutterJobType.enhancedKyc,
              userId: userId,
            ),
          );

          // Debug: Print the auth response to console
          print('Authentication Response: $authResponse');

          setState(() {
            _status = 'Authentication successful, starting KYC...';
          });

          // Second step: KYC
          final kycResponse = await SmileID.api.doEnhancedKycAsync(
            FlutterEnhancedKycRequest(
              country: "NG",
              idType: "BVN",
              idNumber: "00000000001",
              bankCode: "044", // Example bank code
              callbackUrl: "https://somedummyurl.com/demo",
              partnerParams: FlutterPartnerParams(
                jobType: FlutterJobType.enhancedKyc,
                jobId: userId,
                userId: userId,
              ),
              timestamp: authResponse!.timestamp,
              signature: authResponse.signature,
            ),
          );

          // Debug: Print the KYC response to console
          print('KYC Response: $kycResponse');

          setState(() {
            _status =
                'KYC process completed successfully!\nJob ID: ${kycResponse}';
            _isLoading = false;
          });

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: Text(
                  'KYC completed successfully!\nJob ID: ${kycResponse}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } catch (error) {
          // Debug: Print the error to console
          print('Error: $error');

          setState(() {
            _status = 'Error: $error';
            _isLoading = false;
          });

          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('KYC process failed:\n$error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  }

