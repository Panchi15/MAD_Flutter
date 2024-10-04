import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../login.dart';
import 'OrderFormScreen.dart';
import 'productDetailScreen.dart';
import 'orders_list_screen.dart';
import 'profile_screen.dart';
import 'customizations_screen.dart';
import '../../global.dart';

class CustomerDashboard extends StatefulWidget {
  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;
  bool _isDarkMode = false; // Track if dark mode is enabled

  static List<Widget> _screens = <Widget>[
    CustomerDashboardContent(),
    OrdersListScreen(),
    ProfileScreen(),
    CustomizationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery
        .of(context)
        .orientation;

    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFA8E7EB),
        // Light theme background color
        cardColor: Colors.white, // Light theme card color
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF1A1A1A),
        // Dark theme background color
        cardColor: Colors.grey[800], // Dark theme card color
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Customer Dashboard"),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.brightness_3 : Icons.wb_sunny),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _logout(context);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            _screens[_selectedIndex],
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
                child: Icon(Icons.shopping_cart),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
        bottomNavigationBar: orientation == Orientation.portrait
            ? BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Customizations',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.orange,
          selectedItemColor: Colors.blueAccent,
          backgroundColor: Colors.orange,
          onTap: _onItemTapped,
        )
            : null,
      ),
    );
  }
}

void _logout(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
  );
}

class CustomerDashboardContent extends StatefulWidget {
  @override
  _CustomerDashboardContentState createState() =>
      _CustomerDashboardContentState();
}

class _CustomerDashboardContentState extends State<CustomerDashboardContent> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  List<dynamic> promotionalProducts = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String apiUrl = "${API_BASE_URL}/products";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body)['data'];
          filteredProducts = products;

          // Filter promotional products
          promotionalProducts = products.where((product) {
            return product['promotion_price'] != null &&
                product['promotion_start'] != null &&
                product['promotion_end'] != null;
          }).toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          return product['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery
        .of(context)
        .orientation;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          // Modern and spacious padding
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.blueGrey.shade50.withOpacity(0.8),
              // Light, modern background with some transparency
              labelText: 'Search Products',
              labelStyle: TextStyle(
                color: Colors.blueGrey.shade700,
                // Modern color for the label text
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(
                  Icons.search, size: 28, color: Colors.blueGrey.shade700),
              // Larger, modern icon
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                // Rounded corners for modern look
                borderSide: BorderSide(
                  color: Colors.blueGrey.shade300, // Softer border color
                  width: 2, // Slightly thicker border for a premium feel
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                // Rounded corners for enabled state
                borderSide: BorderSide(
                  color: Colors.blueGrey.shade300, // Softer border color
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                // Smooth corners when focused
                borderSide: BorderSide(
                  color: Colors.blueGrey.shade700,
                  // Darker color when focused for distinction
                  width: 2,
                ),
              ),
            ),
            onChanged: (query) => updateSearchQuery(query),
          ),
        ),
        // Section for Promotional Products
        if (promotionalProducts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            // Increased padding for modern spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promotions',
                  style: TextStyle(
                    fontSize: 24, // Larger and bold font for title
                    fontWeight: FontWeight.bold,
                    letterSpacing:
                    1.2, // Slight letter spacing for futuristic look
                  ),
                ),
                SizedBox(height: 16), // More spacing
                Container(
                  height: 300, // Increased height to accommodate content
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade900,
                        Colors.blueGrey.shade700
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16), // Rounded edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5), // Subtle shadow for depth
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: promotionalProducts.length,
                    itemBuilder: (context, index) {
                      var product = promotionalProducts[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              16), // Rounded corners for cards
                        ),
                        margin: EdgeInsets.all(12.0),
                        elevation: 5, // Elevation for a more prominent feel
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              // Rounded image corners
                              child: Image.network(
                                "http://10.0.2.2:8000${product['image']}",
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.broken_image,
                                      size: 48, color: Colors.grey);
                                },
                              ),
                            ),
                            SizedBox(height: 8), // Improved spacing
                            Text(
                              product['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                // Slightly bolder name
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Promo: \$${product['promotion_price']}",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Was: \$${product['item_price']}",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                // Line through for old price
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailScreen(
                                          productId: product['id'],
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade700,
                                // Modern dark button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Rounded button
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12), // Better padding
                              ),
                              child: Text(
                                'View',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors
                                        .white), // Clean and modern text style
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // Normal product grid
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredProducts.isEmpty
              ? Center(
            child: Text(
              'No products found.',
              style: TextStyle(
                fontSize: 18, // Larger font for better visibility
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
              orientation == Orientation.portrait ? 1 : 2,
              childAspectRatio: 3, // Keeping the aspect ratio
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              var product = filteredProducts[index];
              return Card(
                margin: EdgeInsets.all(16.0),
                // Added more margin for breathing space
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      16), // Rounded corners for modern look
                ),
                elevation: 5,
                // Slight elevation for a soft shadow effect
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    // Rounded corners on the image
                    child: Image.network(
                      "http://10.0.2.2:8000${product['image']}",
                      width:
                      60, // Increased image size for better visibility
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image,
                            size: 50, color: Colors.grey);
                      },
                    ),
                  ),
                  title: Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Slightly larger text
                    ),
                  ),
                  subtitle: Text(
                    "\$${product['item_price']}",
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      // Modern color for pricing
                      fontSize: 14, // Subtitle font size
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(
                              productId: product['id'],
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

// Cart Screen (Same code as your existing one)
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  double cartTotal = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final String apiUrl =
        "${API_BASE_URL}/cart/user/$globalUserId"; // Replace with dynamic user ID if needed
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          cartItems = json.decode(response.body)['cartItems'];
          cartTotal = calculateCartTotal();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateCartTotal() {
    double total = 0.0;
    for (var item in cartItems) {
      total += item['total_price'];
    }
    return total;
  }

  Future<void> deleteCartItem(int cartId) async {
    final String apiUrl = "${API_BASE_URL}/cart/item/$cartId";
    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((item) => item['id'] == cartId);
          cartTotal = calculateCartTotal();
        });
      } else {
        throw Exception('Failed to delete cart item');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> updateCartQuantity(int cartId, int qty) async {
    final String apiUrl = "${API_BASE_URL}/cart/item/$cartId";
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"product_qty": qty}),
      );
      if (response.statusCode == 200) {
        setState(() {
          var updatedItem = json.decode(response.body)['cartItem'];
          int index = cartItems.indexWhere((item) => item['id'] == cartId);
          if (index != -1) {
            cartItems[index] = updatedItem;
            cartTotal = calculateCartTotal();
          }
        });
      } else {
        throw Exception('Failed to update cart quantity');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> placeOrder() async {
    print("Order placed!");
  }

  Widget build(BuildContext context) {
    var orientation = MediaQuery
        .of(context)
        .orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Center(child: Text('Your Cart is empty'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var cartItem = cartItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFA8E7EB), // New background color
                      borderRadius: BorderRadius.circular(
                          10.0), // Keep rounded corners
                    ),
                    child: ListTile(
                      leading: Image.network(
                        "http://10.0.2.2:8000${cartItem['product_image']}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image);
                        },
                      ),
                      title: Text(cartItem['product_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Price: \$${cartItem['item_price']}"),
                          Row(
                            children: [
                              Text("Qty: "),
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  if (cartItem['product_qty'] > 1) {
                                    updateCartQuantity(cartItem['id'],
                                        cartItem['product_qty'] - 1);
                                  }
                                },
                              ),
                              Text('${cartItem['product_qty']}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  updateCartQuantity(cartItem['id'],
                                      cartItem['product_qty'] + 1);
                                },
                              ),
                            ],
                          ),
                          Text("Total: \$${cartItem['total_price']}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteCartItem(cartItem['id']);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total: \$${cartTotal.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    List<Map<String, dynamic>> orderDetails = cartItems.map((
                        item) {
                      return {
                        'product_id': item['product_id'],
                        'product_name': item['product_name'],
                        'product_qty': item['product_qty'],
                      };
                    }).toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderFormScreen(
                              orderDetails: orderDetails,
                              cartTotal: cartTotal,
                            ),
                      ),
                    );
                  },
                  child: Text("Place Order"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA8E7EB),
                    // Updated button color to match item background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          30.0), // Rounded button shape
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}