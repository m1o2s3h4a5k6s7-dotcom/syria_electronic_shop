// 🏪 مَتْجَر سُورْيَا الإلِكْترُونِي - القسم الأول (الجزء 1)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'add_product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // دالة تهيئة الاتصال بسيرفر Firebase Firestore لضمان حفظ السلع للأبد
  try {
    await Firebase.initializeApp();
  } catch (_) {}
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
        primaryColor: const Color(0xFF1E293B), // ألوان فاخرة وعصرية من الآخر
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1E293B),
          secondary: const Color(
            0xFFFF6B00,
          ), // برتقالي نيون مميز للأسعار والأزرار
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

  // دالة ذكية لإرسال بيانات السلعة فوراً إلى قاعدة البيانات لمنع اختفائها عند إغلاق التطبيق
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
      const AdminPanelScreen(), // إضافة لوحة تحكم الإدارة المطلوبة
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, color: Color(0xFFFF6B00), size: 24),
            SizedBox(width: 8),
            Text(
              'مَتْجَر سُورْيَا الإلِكْترُونِي',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 4,
        shadowColor: Colors.black38,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFFF6B00),
          unselectedItemColor: const Color(0xFF64748B),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded, size: 28),
              label: 'العروض الحية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded, size: 28),
              label: 'أنا بائع',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings_rounded, size: 28),
              label: 'الإدارة',
            ),
          ],
        ),
      ),
    );
  }
}

// 🌐 مَتْجَر سُورْيَا الإلِكْترُونِي - القسم الثاني (الجزء 2)
class ProductsCatalogScreen extends StatelessWidget {
  final bool isAdminView;
  const ProductsCatalogScreen({super.key, required this.isAdminView});

  // ميزة راحة الزبائن: فتح واتساب التاجر تلقائياً مع نص السلعة المخصصة
  void _openWhatsApp(String phone, String title) async {
    final cleanPhone = phone.replaceAll(' ', '').replaceAll('+', '');
    final url =
        "https://wa.me{Uri.encodeComponent('مرحباً، أنا مهتم بشراء سلعة: $title من متجر سوريا.')}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // ميزة الاتصال الهاتفي السريع بضغطة زر مباشرة للتجار
  void _makeCall(String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(height: 12),
                Text(
                  '🛍️ لا توجد عروض منشورة حالياً.\nكن أول من ينشر سلعة الآن!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.64,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final docId = docs[index].id;
            final p = docs[index].data() as Map<String, dynamic>;
            final String title = p['title'] ?? 'سلعة مميزة';
            final String shopName = p['shop_name'] ?? 'تاجر غير مسمى';
            final String price = p['price'] ?? 'غير محدد';
            final String phone = p['phone'] ?? '';
            final String image = p['image'] ?? 'https://picsum.photos';
            final String location = p['location'] ?? 'سوريا';

            return Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: image.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(image.split(',').last),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(image, fit: BoxFit.cover),
                        ),
                        // زر الحذف السري المخصص فقط للمدير (أنت) لتنظيف وتعديل السلع
                        if (isAdminView)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: IconButton(
                              icon: const CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 16,
                                child: Icon(
                                  Icons.delete_sweep,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              onPressed: () => FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(docId)
                                  .delete(),
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
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.store,
                              size: 12,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                shopName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$price ل.س',
                          style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openWhatsApp(phone, title),
                                icon: const Icon(
                                  Icons.wechat,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'واتساب',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF1E293B),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.white,
                                ),
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

// 🔐 مَتْجَر سُورْيَا الإلِكْترُونِي - القسم الثالث والأخير (الجزء 3)
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isAuthorized = false;
  final _passwordController = TextEditingController();

  void _checkPassword() {
    // 🔐 رمز أمان دخول لوحة التحكم الخاص بك هو: 123456 (يمكنك تعديله من هنا في أي وقت)
    if (_passwordController.text == '123456') {
      setState(() => _isAuthorized = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ رمز الأمان غير صحيح، حاول مجدداً!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_person_rounded,
              size: 80,
              color: Color(0xFF1E293B),
            ),
            const SizedBox(height: 16),
            const Text(
              '🔐 لوحة تحكم الإدارة المحمية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'الرجاء إدخال رمز الأمان للوصول لصلاحية حذف وإدارة السلع المخالفة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'رمز أمان المدير',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_rounded),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'دخول لوحة التحكم',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: Colors.black87),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '🛠️ وضع المدير نشط: يمكنك الآن الضغط على أيقونة الحذف الحمراء فوق أي سلة سلع لإزالتها فوراً من خوادم السحاب.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: ProductsCatalogScreen(isAdminView: true)),
        ],
      ),
    );
  }
}
