import 'package:flutter/material.dart';

import 'package:payments_test/payments/bulk_payment.dart';
import 'package:payments_test/payments/stk_push.dart';

const String consumerKey = 'x6mAXfpoZAJ27VBMoZbQnWf5sVBGL8woMf8xAGFEu1hA6Sgj';
const String consumerSecret = 'd6fD7MGAqbs4hGlng0hW8dSUEMcfKn905QiOHgg8zBFXsq3lr1RIRuAFt3qR0RZ8';
const String baseUrl = 'https://sandbox.safaricom.co.ke';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Mpesa Payments', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Text(
                'Choose Payment Option',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOptionButton(
                      context,
                      'Bulk Payments',
                      Icons.group,
                      Colors.blue[700]!,
                      () => _navigateToBulkPayments(context),
                    ),
                    SizedBox(height: 20),
                    _buildOptionButton(
                      context,
                      'STK Push',
                      Icons.phone_android,
                      Colors.green[600]!,
                      () => _navigateToStkPush(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  void _navigateToBulkPayments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BulkPaymentsPage()),
    );
  }

  void _navigateToStkPush(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StkPushPage()),
    );
  }
}


