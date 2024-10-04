import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'order_details_screen.dart'; // Import the order details screen
import '../../global.dart'; // Import global variables like userID and API_BASE_URL

class OrdersListScreen extends StatefulWidget {
  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  // Function to fetch the user's orders
  Future<void> fetchOrders() async {
    final String apiUrl = "${API_BASE_URL}/orders/byuser/$globalUserId"; // Fetch orders by user ID
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body); // Assuming API returns a list of orders in 'data'
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Fetch orders when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark or light
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Orders",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black, // Adjust text color
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white, // Adjust AppBar background
        elevation: 0, // Flat design, no shadow
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black, // Adjust icon color
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
        child: Text(
          "You have no orders",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87, // Text color adapts to theme
          ),
        ),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Card with margin
            color: isDarkMode ? Colors.grey[800] : Colors.white, // Card background based on theme
            child: ListTile(
              leading: Icon(
                Icons.shopping_cart,
                color: isDarkMode ? Colors.white : Colors.black, // Icon color based on theme
              ),
              title: Text(
                "Order ID: ${order['id']}",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Text color adapts to theme
                  fontWeight: FontWeight.bold, // Make the Order ID stand out
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product: ${order['product']['name']}",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87, // Subtle text color for subtitle
                    ),
                  ),
                  Text(
                    "Quantity: ${order['product_qty']}",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    "Status: ${order['order_status']}",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    "Total Price: \$${order['order_price']}",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.greenAccent : Colors.green,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward,
                color: isDarkMode ? Colors.white : Colors.black, // Arrow icon adapts to theme
              ),
              onTap: () {
                // Navigate to OrderDetailsScreen when an order is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(
                      orderId: order['id'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
