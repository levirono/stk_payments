import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String consumerKey = 'x6mAXfpoZAJ27VBMoZbQnWf5sVBGL8woMf8xAGFEu1hA6Sgj';
const String consumerSecret = 'd6fD7MGAqbs4hGlng0hW8dSUEMcfKn905QiOHgg8zBFXsq3lr1RIRuAFt3qR0RZ8';
const String baseUrl = 'https://sandbox.safaricom.co.ke';

class StkPushPage extends StatefulWidget {
  @override
  _StkPushPageState createState() => _StkPushPageState();
}

class _StkPushPageState extends State<StkPushPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String _resultMessage = '';

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

  Future<void> initiateSTKPush(String phoneNumber, String amount) async {
    setState(() {
      _isLoading = true;
      _resultMessage = '';
    });

    try {
      String accessToken = await getAccessToken();
      
      String timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
      String password = base64Encode(utf8.encode('174379bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919$timestamp'));

      Map<String, dynamic> body = {
        "BusinessShortCode": "174379",
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": phoneNumber,
        "PartyB": "174379",
        "PhoneNumber": phoneNumber,
        "CallBackURL": "https://mydomain.com/path",
        "AccountReference": "PayEase",
        "TransactionDesc": "Payment of X" 
      };

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          _resultMessage = 'STK Push initiated successfully. Please check your phone.';
        });
      } else {
        setState(() {
          _resultMessage = 'Failed to initiate STK Push: ${response.body}';
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STK Push'),
        backgroundColor: Colors.green[600],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          initiateSTKPush(
                            _phoneNumberController.text,
                            _amountController.text,
                          );
                        }
                      },
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Initiate STK Push'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
              ),
              SizedBox(height: 24),
              if (_resultMessage.isNotEmpty)
                Text(
                  _resultMessage,
                  style: TextStyle(
                    color: _resultMessage.contains('successfully')
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
}