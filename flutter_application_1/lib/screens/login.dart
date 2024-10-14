import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart'; // Import the connectivity package
import '../global.dart'; // import the global variables
import './Customer/customerDashboard.dart'; // import the CustomerDashboard page
import './Admin/adminDashboard.dart'; // import the AdminDashboard page

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String _connectionStatus = 'Unknown'; // To display the connection status
  late Connectivity _connectivity;
  late Stream<List<
      ConnectivityResult>> _connectivityStream; // Updated to List<ConnectivityResult>

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream =
        _connectivity.onConnectivityChanged; // Correct stream assignment

    // Check the initial connection status
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivityStream.listen((List<ConnectivityResult> resultList) {
      if (resultList.isNotEmpty) {
        // We take the first result as the current network state
        _updateConnectionStatus(resultList.first);
      } else {
        _updateConnectionStatus(
            ConnectivityResult.none); // No connection if the list is empty
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result as ConnectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    String status;
    if (result == ConnectivityResult.mobile) {
      status = 'Mobile Data';
    } else if (result == ConnectivityResult.wifi) {
      status = 'WiFi';
    } else {
      status = 'No Internet Connection';
    }

    setState(() {
      _connectionStatus = status;
    });
  }

  Future<void> loginUser() async {
    if (_connectionStatus == 'No Internet Connection') {
      showSnackbarMessage(
          context, 'Please check your internet connection.', false);
      return;
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    final url =
    Uri.parse('${API_BASE_URL}/login'); // Use the global API base URL

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'email': _email,
        'password': _password,
      }),
    );

    setState(() {
      _isLoading = false; // Hide loading spinner
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String userType = data['user']['user_type'];
      final int userId = data['user']['id'];

      // Store the user_id globally for access across pages
      globalUserId = userId;

      // Show a success message
      showSnackbarMessage(context, "Login successful!", true);

      // Navigate based on user type
      if (userType == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerDashboard()),
        );
      } else if (userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      }
    } else {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Login failed';
      showSnackbarMessage(context, errorMessage, false);
    }
  }

  void showSnackbarMessage(BuildContext context, String message, bool success) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change to white background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0), // Wider padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Center alignment for everything
              children: <Widget>[
                Text(
                  'CustomTeez',
                  style: TextStyle(
                    fontSize: 32, // Slightly larger title
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20), // Space for connection status

                // Display the connection status
                Text(
                  _connectionStatus,
                  style: TextStyle(
                    fontSize: 16,
                    color: _connectionStatus == 'No Internet Connection' ? Colors.red : Colors.green,
                  ),
                ),

                SizedBox(height: 20), // Space between connection status and form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Center text
                    children: <Widget>[
                      Text(
                        'Email',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 8), // Small spacing between label and field
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter email',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                      ),
                      SizedBox(height: 24), // Increased spacing between fields
                      Text(
                        'Password',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFA8E7EB), // Set button color to #A8E7EB
                            padding: EdgeInsets.symmetric(vertical: 18), // Increase padding for button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded button
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginUser();
                            }
                          },
                          child: Text('LOG IN',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white)), // Keep text color white
                        ),

                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: RichText(
                    textAlign: TextAlign.center, // Center the text
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Register now',
                          style: TextStyle(
                            color: Color(0xFF1109F3), // Correct way to use hex color
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
