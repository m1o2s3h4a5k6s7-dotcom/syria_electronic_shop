import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

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

  // ألبوم متوافق مع الموبايل والويب لحمل باقة الصور معاً دفعة واحدة
  List<String> _albumImages = [];
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

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
    'عقارات',
  ];

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

  // 🎯 الحل السحري النهائي: استدعاء الألبوم بصيغة الموبايل النقية المتوافقة مع تجميع الـ APK
  Future<void> _pickBulkImagesFromStudio() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() => _albumImages.clear());
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          // تحويل فوري لكتل الصور البرمية لتخزينها محلياً وبثبات كامل
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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              '🏪 مركز تجار متجر سوريا - نظام الألبوم المفتوح الصريح',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A252F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _cat,
              decoration: const InputDecoration(
                labelText: 'فئة السلعة الجديدة',
                border: OutlineInputBorder(),
              ),
              items: _cats
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _cat = v!),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'اسم المادة'),
            ),
            TextFormField(
              controller: _shop,
              decoration: const InputDecoration(labelText: 'المحل / التاجر'),
            ),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'السعر النهائي ל.ס'),
            ),
            TextFormField(
              controller: _merchantPhone,
              decoration: const InputDecoration(labelText: 'رقم الموبايل'),
            ),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(
                labelText: 'العنوان بالتفصيل داخل سوريا',
              ),
            ),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'ملاحظات وضمانات اختيارية',
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _pickBulkImagesFromStudio,
              icon: const Icon(Icons.collections, color: Colors.white),
              label: const Text(
                '📸 افتح الاستوديو وحدد باقة الصور معاً بضغطة واحدة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 5),

            if (_albumImages.isNotEmpty)
              Text(
                '✅ تم تأمين باقة الألبوم: ${_albumImages.length} صورة مجمعة للسلعة',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),

            if (_albumImages.isNotEmpty)
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _albumImages.length,
                  itemBuilder: (c, i) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 75,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.memory(
                            base64Decode(_albumImages[i].split(',').last),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _albumImages.removeAt(i)),
                          child: const CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 15),

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
                              : _notes.text,
                        };

                        widget.onProductAdded(p);

                        try {
                          final msg =
                              "مادة جديدة ⚡:\nالاسم: ${_title.text}\nالمحل: ${_shop.text}\nالسعر: ${_price.text}";
                          await http
                              .get(
                                Uri.parse(
                                  'https://allorigins.win{Uri.encodeComponent("https://telegram.org")}',
                                ),
                              )
                              .timeout(const Duration(seconds: 2));
                        } catch (_) {}

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
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'نشر العرض وتحديث الإشعارات فوراً',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
