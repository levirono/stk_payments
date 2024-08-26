import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String consumerKey = 'x6mAXfpoZAJ27VBMoZbQnWf5sVBGL8woMf8xAGFEu1hA6Sgj';
const String consumerSecret = 'd6fD7MGAqbs4hGlng0hW8dSUEMcfKn905QiOHgg8zBFXsq3lr1RIRuAFt3qR0RZ8';
const String baseUrl = 'https://sandbox.safaricom.co.ke';


class BulkPaymentsPage extends StatefulWidget {
  @override
  _BulkPaymentsPageState createState() => _BulkPaymentsPageState();
}

class _BulkPaymentsPageState extends State<BulkPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, TextEditingController>> _payments = [];
  bool _isLoading = false;
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _addPayment();
  }

  void _addPayment() {
    setState(() {
      _payments.add({
        'phone': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removePayment(int index) {
    setState(() {
      _payments.removeAt(index);
    });
  }

  Future<void> _processBulkPayments() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _resultMessage = '';
      });

      try {
        String accessToken = await getAccessToken();
        List<Future> paymentFutures = [];

        for (var payment in _payments) {
          paymentFutures.add(
            sendB2CPayment(
              payment['phone']!.text,
              payment['amount']!.text,
              accessToken,
            ),
          );
        }

        List results = await Future.wait(paymentFutures);
        int successCount = results.where((result) => result == true).length;

        setState(() {
          _resultMessage = 'Processed ${results.length} payments. $successCount successful.';
        });
      } catch (e) {
        setState(() {
          _resultMessage = 'An error occurred: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> getAccessToken() async {
    String credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    
    final response = await http.get(
      Uri.parse('$baseUrl/oauth/v1/generate?grant_type=client_credentials'),
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    } else {
      throw Exception('Failed to get access token');
    }
  }

  Future<bool> sendB2CPayment(String phoneNumber, String amount, String accessToken) async {
    final String initiatorName = 'YOUR_INITIATOR_NAME';
    final String securityCredential = 'YOUR_SECURITY_CREDENTIAL';
    final String commandID = 'work payment';
    final String partyA = 'YOUR_SHORTCODE';
    final String partyB = phoneNumber;
    final String remarks = 'Bulk payment';
    final String queueTimeOutURL = 'https://your-domain.com/timeout';
    final String resultURL = 'https://your-domain.com/result';
    final String occassion = '';

    Map<String, dynamic> body = {
      "InitiatorName": initiatorName,
      "SecurityCredential": securityCredential,
      "CommandID": commandID,
      "Amount": amount,
      "PartyA": partyA,
      "PartyB": partyB,
      "Remarks": remarks,
      "QueueTimeOutURL": queueTimeOutURL,
      "ResultURL": resultURL,
      "Occassion": occassion
    };

    final response = await http.post(
      Uri.parse('$baseUrl/mpesa/b2c/v1/paymentrequest'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['ResponseCode'] == '0';
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bulk Payments'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    return _buildPaymentInput(index);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addPayment,
                child: Text('Add Payment'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _processBulkPayments,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Process Bulk Payments'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
              ),
              SizedBox(height: 16),
              if (_resultMessage.isNotEmpty)
                Text(
                  _resultMessage,
                  style: TextStyle(
                    color: _resultMessage.contains('successful')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInput(int index) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _payments[index]['phone'],
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _payments[index]['amount'],
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removePayment(index),
            ),
          ],
        ),
      ),
    );
  }
}

