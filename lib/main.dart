import 'package:flutter/material.dart';
import 'add_product.dart';

void main() {
  runApp(const SyriaStoreApp());
}

class SyriaStoreApp extends StatelessWidget {
  const SyriaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متجر سوريا الإلكتروني',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _allProducts = [];

  void _addNewProduct(Map<String, dynamic> product) {
    setState(() {
      _allProducts.insert(0, product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProductsGridScreen(products: _allProducts),
      AddProductScreen(onProductAdded: _addNewProduct),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏪 متجر سوريا الإلكتروني',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A252F),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: const Color(0xFF2C3E50),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'العروض الحية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'أنا بائع',
          ),
        ],
      ),
    );
  }
}

class ProductsGridScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const ProductsGridScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          '🛍️ لا توجد عروض منشورة حالياً.\nكن أول من ينشر سلعة في قسم بائع!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF999999)),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  p['image'] ?? 'https://picsum.photos',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] ?? 'سلعة غير مسمى',
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '🏪 ${p['shop_name']}',
                      maxLines: 1,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p['price']} ل.س',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
