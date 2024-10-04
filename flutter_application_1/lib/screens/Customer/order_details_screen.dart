import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../global.dart'; // Import global variables like API_BASE_URL

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  OrderDetailsScreen({required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? orderDetails;
  bool isLoading = true;

  // Function to fetch order details by ID
  Future<void> fetchOrderDetails() async {
    final String apiUrl = "${API_BASE_URL}/deliverers/order/${widget.orderId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          orderDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (error) {
      print("Error fetching order details: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black, // Adapt AppBar text color
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white, // Adapt AppBar background
        elevation: 0, // Flat design for AppBar
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black, // Icon color adapts to theme
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orderDetails == null
          ? Center(
        child: Text(
          "Failed to load order details",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87, // Adapt text color
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${orderDetails!['order']['id']}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black, // Adapt text color
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Product: ${orderDetails!['order']['product']['name']}",
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white70 : Colors.black87, // Adapt text color
              ),
            ),
            Text(
              "Quantity: ${orderDetails!['order']['product_qty']}",
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              "Total Price: \$${orderDetails!['order']['order_price']}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.greenAccent : Colors.green, // Highlighted price
              ),
            ),
            Text(
              "Order Status: ${orderDetails!['order']['order_status']}",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Divider(color: isDarkMode ? Colors.grey : Colors.black12), // Divider color based on theme
            Text(
              "Deliverer Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black, // Adapt heading color
              ),
            ),
            SizedBox(height: 10),
            orderDetails!['deliverer'] == null
                ? Text(
              "No deliverer assigned yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.red, // Keep this red for contrast in both modes
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deliverer Name: ${orderDetails!['deliverer']['deliverer_name']}",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                Text(
                  "Delivery Status: ${orderDetails!['deliverer']['delivery_status']}",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                Text(
                  "Delivery Note: ${orderDetails!['deliverer']['delivery_note']}",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(color: isDarkMode ? Colors.grey : Colors.black12),
            Text(
              "Product Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black, // Adapt heading color
              ),
            ),
            SizedBox(height: 10),
            Image.network(
              "http://10.0.2.2:8000/${orderDetails!['order']['product']['image']}",
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              "Product Description: ${orderDetails!['order']['product']['description']}",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              "Category: ${orderDetails!['order']['product']['category_name']}",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              "Item Price: \$${orderDetails!['order']['product']['item_price']}",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
