import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';

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
  void initState() {
    super.initState();
    // 🎯 الحل السحري والذكي: فحص المتصفح الداخلي لـ AppCreator24 وإجبار الهاتف على الانتقال لمتصفح كروم الحقيقي
    _forceOpenInExternalBrowser();
  }

  void _forceOpenInExternalBrowser() {
    final String userAgent = html.window.navigator.userAgent.toLowerCase();
    // كشف ما إذا كان المستخدم يتصفح من داخل تطبيق WebView المقفل الخاص بـ AppCreator24
    if (userAgent.contains('wv') ||
        userAgent.contains('android') && !userAgent.contains('chrome')) {
      // إجبار الهاتف على فتح الرابط الحالي في متصفح خارجي نقي يدعم الصور المتعددة
      html.window.location.href =
          "intent://syria-electronic-shop.vercel.app#Intent;scheme=https;package=com.android.chrome;end";
    }
  }

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

  // دالة التقاط باقة الصور معاً دفعة واحدة بصلاحيات المتصفح الكاملة
  // دالة متطورة ومحقونة لحل مشكلة متصفح AppCreator24 الداخلي وإجباره على التحديد المتعدد من الاستوديو
  void _pickBulkImagesFromStudio() {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/jpeg,image/png,image/webp';
    input.multiple = true; // تفعيل صريح ومباشر للتحديد المفتوح المتعدد

    input.click();

    input.onChange.listen((e) {
      if (input.files != null && input.files!.isNotEmpty) {
        setState(
          () => _albumImages.clear(),
        ); // تنظيف الألبوم لاستقبال الصور الجديدة معاً

        final int totalFiles = input.files!.length;
        for (int i = 0; i < totalFiles; i++) {
          final file = input.files![i];

          // الكود السحري: تحويل الملف إلى رابط كائن مؤقت (Blob URL) لتخطي حظر أمان AppCreator24 فوراً
          final String blobUrl = html.Url.createObjectUrlFromBlob(file);

          setState(() {
            _albumImages.add(
              blobUrl,
            ); // حقن الصورة داخل قائمة المعاينة المفتوحة
          });
        }
      }
    });
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
              initialValue: _cat,
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
              decoration: const InputDecoration(labelText: 'السعر النهائي'),
            ),
            TextFormField(
              controller: _merchantPhone,
              decoration: const InputDecoration(labelText: 'رقم الموبايل'),
            ),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'العنوان بالتفصيل'),
            ),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'ملاحظات اختيارية'),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _pickBulkImagesFromStudio,
              icon: const Icon(Icons.collections, color: Colors.white),
              label: const Text(
                '📸 حدد كافة صور البضاعة معاً من الاستوديو',
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
                          child: Image.network(
                            _albumImages[i],
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
