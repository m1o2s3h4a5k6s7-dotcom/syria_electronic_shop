import 'package:flutter/material.dart';
import 'dart:convert';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex =
      1; // عداد محلي لتتبع رقم الصورة المعروضة حالياً عند التقليب

  @override
  Widget build(BuildContext context) {
    final String mainImg = (widget.product['image'] ?? '').toString();
    List<String> fullAlbum = [mainImg];

    try {
      // فحص مزدوج ذكي يقرأ المصفوفة الحية مباشرة أو يفكك النصوص المخزنة القادمة من السيرفر
      if (widget.product['album'] != null && widget.product['album'] is List) {
        fullAlbum = List<String>.from(widget.product['album']);
      } else if (widget.product['images_json'] != null) {
        final List<dynamic> decoded = json.decode(
          widget.product['images_json'],
        );
        fullAlbum = List<String>.from(decoded);
      }
    } catch (_) {
      fullAlbum = mainImg.isNotEmpty ? [mainImg] : ['https://picsum.photos'];
    }

    if (fullAlbum.isEmpty && mainImg.isNotEmpty) {
      fullAlbum = [mainImg];
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product['title'] ?? 'تفاصيل السلعة'),
          backgroundColor: const Color(
            0xFF1A252F,
          ), // ألوان هادئة ومحترفة للواجهة الأساسية
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          children: [
            // منطقة عرض وتقليب باقة الصور المفتوحة غير المحدودة للسلعة
            SizedBox(
              height: 270,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: fullAlbum.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex =
                            index +
                            1; // تحديث العداد الديناميكي عفوياً عند السحب
                      });
                    },
                    itemBuilder: (context, idx) {
                      final img = fullAlbum[idx];
                      return img.startsWith('data:image')
                          ? Image.memory(
                              base64Decode(img.split(',').last),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.network(
                              img,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            );
                    },
                  ),

                  // 👈 فقاعة رقمية عائمة لحساب وعرض موضع الصورة بدقة من إجمالي العدد المفتوح (مثال: صورة 3 من 8)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: Colors.orange,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'صورة $_currentImageIndex من ${fullAlbum.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text(
                '👈 مرر يميناً ويساراً لاستكشاف ألبوم البضاعة كاملاً 👉',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // السعر باللون البرتقالي الفاقع لجذب الانتباه وزيادة الرغبة في طلب السلعة
                  Text(
                    '${widget.product['price'] ?? '0'} ل.س',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),

                  Text(
                    '🏪 التاجر: ${widget.product['shop_name'] ?? 'عام'} — 📍 الموقع: ${widget.product['location'] ?? 'سوريا'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(),

                  const Text(
                    '📝 تفاصيل وضمانات العرض المطروح:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      widget.product['notes'] ??
                          'لا توجد مواصفات إضافية تم إدراجها.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // زر اتصال فوري تفاعلي بلون أخضر مريح لتأكيد طلبات الشراء الفورية
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'رقم اتصال التاجر السريع: ${widget.product['phone']}',
                            ),
                            backgroundColor: const Color(0xFF1A252F),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text(
                        'اتصل واطلب فوراً من المحل: ${widget.product['phone']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
