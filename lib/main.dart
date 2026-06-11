// 🏪 مَتْجَر سُورْيَا الإلِكْترُونِي - الجزء الأول من ملف main.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'add_product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { 
    await Firebase.initializeApp(); 
  } catch(_) {}
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
        useMaterial3: true,
        primaryColor: const Color(0xFF1E293B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1E293B),
          secondary: const Color(0xFFFF6B00),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
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

  void _uploadProductToFirebase(Map<String, dynamic> product) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        ...product,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const ProductsCatalogScreen(isAdminView: false),
      AddProductScreen(onProductAdded: _uploadProductToFirebase),
      const AdminPanelScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, color: Color(0xFFFF6B00), size: 24),
            SizedBox(width: 8),
            Text('مَتْجَر سُورْيَا الإلِكْترُونِي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 4,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFF6B00),
        unselectedItemColor: const Color(0xFF64748B),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'العروض الحية'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), label: 'أنا بائع'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'الإدارة'),
        ],
      ),
    );
  }
}
// 🌐 مَتْجَر سُورْيَا الإلِكْترُونِي - الجزء الثاني والأخير من ملف main.dart
class ProductsCatalogScreen extends StatelessWidget {
  final bool isAdminView;
  const ProductsCatalogScreen({super.key, required this.isAdminView});

  void _openWhatsApp(String phone, String title) async {
    final cleanPhone = phone.replaceAll(' ', '').replaceAll('+', '');
    final url = "https://wa.me{Uri.encodeComponent('مرحباً، أنا مهتم بشراء سلعة: $title من متجر سوريا.')}";
    if (await canLaunchUrl(Uri.parse(url))) { 
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); 
    }
  }

  void _makeCall(String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) { 
      await launchUrl(Uri.parse(url)); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('🛍️ لا توجد عروض منشورة حالياً.', style: TextStyle(color: Color(0xFF64748B))),
          );
        }

        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.64,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final docId = docs[index].id;
            final p = docs[index].data() as Map<String, dynamic>;
            final String title = p['title'] ?? 'سلعة مميزة';
            final String shopName = p['shop_name'] ?? 'تاجر';
            final String price = p['price'] ?? 'غير محدد';
            final String phone = p['phone'] ?? '';
            final String image = p['image'] ?? 'https://picsum.photos';
            final String location = p['location'] ?? 'سوريا';

            return Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: image.startsWith('data:image')
                              ? Image.memory(base64Decode(image.split(',').last), fit: BoxFit.cover)
                              : Image.network(image, fit: BoxFit.cover),
                        ),
                        if (isAdminView)
                          Positioned(
                            top: 6, left: 6,
                            child: IconButton(
                              icon: const CircleAvatar(backgroundColor: Colors.red, radius: 16, child: Icon(Icons.delete_sweep, color: Colors.white, size: 18)),
                              onPressed: () => FirebaseFirestore.instance.collection('products').doc(docId).delete(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                        Text('🏪 $shopName', maxLines: 1, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                        Text('📍 $location', maxLines: 1, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        const SizedBox(height: 4),
                        Text('$price ل.س', style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _openWhatsApp(phone, title),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), padding: EdgeInsets.zero),
                                child: const Text('واتساب', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            CircleAvatar(
                              radius: 16, backgroundColor: const Color(0xFF1E293B),
                              child: IconButton(
                                icon: const Icon(Icons.phone, size: 14, color: Colors.white),
                                onPressed: () => _makeCall(phone),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isAuthorized = false;
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded, size: 80, color: Color(0xFF1E293B)),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'رمز أمان المدير (123456)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text == '123456') {
                  setState(() => _isAuthorized = true);
                }
              },
              child: const Text('دخول'),
            ),
          ],
        ),
      );
    }
    return const Scaffold(body: ProductsCatalogScreen(isAdminView: true));
  }
}
