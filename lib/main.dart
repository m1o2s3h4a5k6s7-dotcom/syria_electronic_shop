import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🛡️ حزام الأمان الفيدرالي لفتح التطبيق بثبات أسطوري ومنع الكراش فوراً
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase connection bypassed safely: $e");
  }
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
            secondary: const Color(0xFFFF6B00)),
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
  String _activeCatFilter = 'الكل';
  void _uploadProductToFirebase(Map<String, dynamic> product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .add({...product, 'timestamp': FieldValue.serverTimestamp()});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProductsCatalogScreen(
          isAdminView: false,
          currentFilter: _activeCatFilter,
          onFilterChanged: (v) => setState(() => _activeCatFilter = v)),
      AddProductScreen(onProductAdded: _uploadProductToFirebase),
      const AdminPanelScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title:
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.storefront, color: Color(0xFFFF6B00)),
          SizedBox(width: 8),
          Text('مَتْجَر سُورْيَا الإلِكْترُونِي',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18))
        ]),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'العروض الحية'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded), label: 'أنا بائع'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined), label: 'الإدارة')
        ],
      ),
    );
  }
}

class ProductsCatalogScreen extends StatelessWidget {
  final bool isAdminView;
  final String currentFilter;
  final Function(String) onFilterChanged;
  const ProductsCatalogScreen(
      {super.key,
      required this.isAdminView,
      required this.currentFilter,
      required this.onFilterChanged});

  void _openWhatsApp(BuildContext c, String phone, String title) async {
    final clean = phone.replaceAll(' ', '').replaceAll('+', '');
    final url =
        "https://wa.me{Uri.encodeComponent('مرحباً، أنا مهتم بشراء سلعة: $title من متجر سوريا.')}";
    if (await canLaunchUrl(Uri.parse(url)))
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _makeCall(String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final cats = [
      'الكل',
      'تجارة الحبوب بكافة أنواعها',
      'خضار وفواكه',
      'سيارات',
      'دراجات نارية',
      'مكياجات وعطورات',
      'ألبسة رجالية',
      'ألبسة نسائية',
      'أحذية',
      'مواد غذائية',
      'عقارات'
    ];
    return Column(
      children: [
        if (!isAdminView)
          Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length,
                  itemBuilder: (c, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                          label: Text(cats[i]),
                          selected: currentFilter == cats[i],
                          onSelected: (s) => onFilterChanged(cats[i]),
                          selectedColor: const Color(0xFFFF6B00),
                          labelStyle: TextStyle(
                              color: currentFilter == cats[i]
                                  ? Colors.white
                                  : const Color(0xFF1E293B)))))),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return const Center(
                    child: Text('🛍️ لا توجد عروض منشورة حالياً.',
                        style: TextStyle(color: Color(0xFF64748B))));
              var docs = snapshot.data!.docs;
              if (currentFilter != 'الكل' && !isAdminView) {
                docs = docs
                    .where(
                        (d) => (d.data() as Map)['category'] == currentFilter)
                    .toList();
              }
              if (docs.isEmpty)
                return const Center(
                    child: Text('🛍️ لا توجد عروض في هذه الفئة حالياً.',
                        style: TextStyle(color: Color(0xFF64748B))));
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.62),
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
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => ProductDetailScreen(product: p))),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: Stack(children: [
                            Positioned.fill(
                                child: image.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(image.split(',').last),
                                        fit: BoxFit.cover)
                                    : Image.network(image, fit: BoxFit.cover)),
                            Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(children: [
                                      Text(shopName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10)),
                                      const SizedBox(width: 3),
                                      const Icon(Icons.verified,
                                          color: Colors.amber, size: 12)
                                    ]))),
                            if (isAdminView)
                              Positioned(
                                  top: 5,
                                  left: 5,
                                  child: IconButton(
                                      icon: const CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 14,
                                          child: Icon(Icons.delete_sweep,
                                              color: Colors.white, size: 16)),
                                      onPressed: () => FirebaseFirestore
                                          .instance
                                          .collection('products')
                                          .doc(docId)
                                          .delete()))
                          ])),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF1E293B))),
                                  Text('📍 $location',
                                      maxLines: 1,
                                      style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 10)),
                                  const SizedBox(height: 2),
                                  Text('$price ل.س',
                                      style: const TextStyle(
                                          color: Color(0xFFFF6B00),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Expanded(
                                        child: ElevatedButton(
                                            onPressed: () => _openWhatsApp(
                                                context, phone, title),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF25D366),
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 28)),
                                            child: const Text('واتساب',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)))),
                                    const SizedBox(width: 4),
                                    CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            const Color(0xFF1E293B),
                                        child: IconButton(
                                            icon: const Icon(Icons.phone,
                                                size: 12, color: Colors.white),
                                            onPressed: () => _makeCall(phone)))
                                  ])
                                ]),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    final List album = product['album'] ?? [];
    final String title = product['title'] ?? 'سلعة مميزة';
    final String shopName = product['shop_name'] ?? 'تاجر';
    final String price = product['price'] ?? 'غير محدد';
    final String phone = product['phone'] ?? '';
    final String location = product['location'] ?? 'سوريا';
    final String notes = product['notes'] ?? 'نخب أول مكفول.';
    return Scaffold(
      appBar: AppBar(
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          backgroundColor: const Color(0xFF1E293B),
          iconTheme: const IconThemeData(color: Colors.white)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (album.isNotEmpty)
            Container(
                height: 220,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: album.length,
                    itemBuilder: (c, i) => Container(
                        margin: const EdgeInsets.only(left: 10),
                        width: 280,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: album[i].toString().startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(
                                        album[i].toString().split(',').last),
                                    fit: BoxFit.cover)
                                : Image.network(album[i].toString(),
                                    fit: BoxFit.cover))))),
          const SizedBox(height: 16),
          Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(shopName,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B))),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              color: Colors.amber, size: 16)
                        ]),
                        const Divider(),
                        Text('💰 السعر: $price ل.س',
                            style: const TextStyle(
                                color: Color(0xFFFF6B00),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 6),
                        Text('📍 العنوان: $location',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        Text('📞 رقم التواصل: $phone',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF64748B)))
                      ]))),
          const SizedBox(height: 12),
          const Text('📝 ملاحظات وضمانات المادة:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Text(notes,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF334155), height: 1.4)))
        ],
      ),
    );
  }
}
// 📸 مَتْجَر سُورْيَا الإلِكْترُونِي - القسم الفرعي ج والأخير (3 من 3) في الـ VS Code

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _auth = false;
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!_auth) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded,
                size: 70, color: Color(0xFF1E293B)),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'رمز أمان المدير (123456)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (_pass.text == '123456') setState(() => _auth = true);
              },
              child: const Text('دخول'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
        body: ProductsCatalogScreen(
            isAdminView: true, currentFilter: 'الكل', onFilterChanged: (v) {}));
  }
}

class AddProductScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onProductAdded;
  const AddProductScreen({super.key, required this.onProductAdded});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _shop = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();
  final _merchantPhone = TextEditingController();
  final _notes = TextEditingController();

  String _cat = 'تجارة الحبوب بكافة أنواعها';
  List<String> _albumImages = [];
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _title.dispose();
    _shop.dispose();
    _price.dispose();
    _location.dispose();
    _merchantPhone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickBulkImagesFromStudio() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() => _albumImages.clear());
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          String base64Image = "data:image/png;base64,${base64Encode(bytes)}";
          setState(() {
            _albumImages.add(base64Image);
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _cats = const [
      'تجارة الحبوب بكافة أنواعها',
      'خضار وفواكه',
      'سيارات',
      'دراجات نارية',
      'مكياجات وعطورات',
      'ألبسة رجالية',
      'ألبسة نسائية',
      'أحذية',
      'مواد غذائية',
      'عقارات'
    ];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text('🏪 مركز تجار متجر سوريا',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _cat,
              decoration: const InputDecoration(
                  labelText: 'فئة السلعة', border: OutlineInputBorder()),
              items: _cats
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _cat = v!),
            ),
            TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'اسم المادة')),
            TextFormField(
                controller: _shop,
                decoration: const InputDecoration(labelText: 'المحل / التاجر')),
            TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'السعر ل.س')),
            TextFormField(
                controller: _merchantPhone,
                decoration: const InputDecoration(labelText: 'رقم الموبايل')),
            TextFormField(
                controller: _location,
                decoration:
                    const InputDecoration(labelText: 'العنوان داخل سوريا')),
            TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                    labelText: 'ملاحظات وضمانات اختيارية')),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickBulkImagesFromStudio,
              icon: const Icon(Icons.collections, color: Colors.white),
              label: const Text('📸 حدد باقة الصور معاً من الاستوديو',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(height: 10),
            if (_albumImages.isNotEmpty)
              Text(
                  '✅ تم تأمين باقة الألبوم: ${_albumImages.length} صورة مجمعة للسلعة',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                  textAlign: TextAlign.center),
            const SizedBox(height: 10),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _loading = true);
                        final mainPic = _albumImages.isNotEmpty
                            ? _albumImages.first
                            : 'https://picsum.photos';
                        final p = {
                          'title': _title.text,
                          'shop_name': _shop.text,
                          'price': _price.text,
                          'phone': _merchantPhone.text,
                          'location': _location.text,
                          'category': _cat,
                          'image': mainPic,
                          'album': _albumImages,
                          'images_json': json.encode(_albumImages),
                          'notes': _notes.text.isEmpty
                              ? 'نخب أول مكفول.'
                              : _notes.text
                        };
                        widget.onProductAdded(p);
                        _title.clear();
                        _shop.clear();
                        _price.clear();
                        _location.clear();
                        _merchantPhone.clear();
                        _notes.clear();
                        setState(() {
                          _albumImages = [];
                          _loading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text('نشر العرض الموثق فوراً',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}
