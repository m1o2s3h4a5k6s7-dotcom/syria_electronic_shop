import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'product_detail.dart';

class ProductGridScreen extends StatefulWidget {
  final List<Map<String, dynamic>> localProducts;
  final List<Map<String, dynamic>> favorites;
  final List<Map<String, String>> adminBanners;
  final Map<String, String> marqueeSettings;
  final Function(Map<String, dynamic>) onToggleFav;
  final bool showOnlyDeals;

  const ProductGridScreen({
    super.key,
    required this.localProducts,
    required this.favorites,
    required this.adminBanners,
    required this.marqueeSettings,
    required this.onToggleFav,
    this.showOnlyDeals = false,
  });

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  String _q = '';
  String _cat = 'الكل';
  final _pC = PageController();
  int _bI = 0;
  late Timer _t;
  late ScrollController _sC;

  final List<String> _cats = const [
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
    'عقارات',
  ];

  @override
  void initState() {
    super.initState();
    _sC = ScrollController();
    _t = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && widget.adminBanners.isNotEmpty) {
        _bI = (_bI + 1) % widget.adminBanners.length;
        _pC.animateToPage(
          _bI,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      if (mounted && _sC.hasClients) {
        double max = _sC.position.maxScrollExtent;
        double cur = _sC.offset;
        _sC.animateTo(
          cur >= max ? 0 : cur + 40,
          duration: const Duration(milliseconds: 800),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _t.cancel();
    _pC.dispose();
    _sC.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _getData() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://allorigins.win{Uri.encodeComponent("https://telegram.org")}',
        ),
      );
      if (res.statusCode == 200) {
        final inner = json.decode(json.decode(res.body)['contents'] ?? '{}');
        final List<dynamic> updates = inner['result'] ?? [];
        List<dynamic> serverList = [];
        for (var u in updates) {
          if (u['message'] != null && u['message']['text'] != null) {
            String txt = u['message']['text'];
            if (txt.contains("مادة جديدة")) {
              String t = _f(txt, "الاسم:");
              String imgLink = _f(txt, "الصورة:");
              if (t.isNotEmpty) {
                serverList.add({
                  'title': t,
                  'shop_name': _f(txt, "المحل:"),
                  'price': _f(txt, "السعر:"),
                  'phone': _f(txt, "الهاتف:"),
                  'location': _f(txt, "العنوان:"),
                  'category': _f(txt, "القسم:"),
                  'is_deal': txt.contains("حسم") || t.length % 2 == 0,
                  'image': imgLink.isEmpty ? 'https://picsum.photos' : imgLink,
                  'images_json': _f(txt, "ألبوم:"),
                  'notes': _f(txt, "الملاحظات:"),
                });
              }
            }
          }
        }
        return [...widget.localProducts, ...serverList];
      }
    } catch (_) {}
    return widget.localProducts;
  }

  String _f(String t, String k) {
    try {
      if (!t.contains(k)) return "";
      int s = t.indexOf(k) + k.length;
      int e = t.indexOf('\n', s);
      return t.substring(s, e == -1 ? t.length : e).trim();
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Color(
      int.parse(widget.marqueeSettings['textColor'] ?? '0xFFFFE100'),
    );
    final bg = Color(
      int.parse(widget.marqueeSettings['bgColor'] ?? '0xFF1A252F'),
    );
    return Column(
      children: [
        if (!widget.showOnlyDeals && widget.adminBanners.isNotEmpty)
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 145,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pC,
                  itemCount: widget.adminBanners.length,
                  onPageChanged: (v) => setState(() => _bI = v),
                  itemBuilder: (context, index) {
                    final b = widget.adminBanners[index];
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: b['img']!.startsWith('data:image')
                                  ? Image.memory(
                                      base64Decode(b['img']!.split(',').last),
                                    ).image
                                  : NetworkImage(b['img']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.65),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 18,
                          right: 12,
                          left: 12,
                          child: Text(
                            b['t']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.adminBanners.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: _bI == i ? 12 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _bI == i ? Colors.orange : Colors.white70,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        Container(
          width: double.infinity,
          height: 28,
          color: bg,
          child: ListView(
            controller: _sC,
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 15,
                ),
                child: Text(
                  widget.marqueeSettings['text'] ?? '',
                  style: TextStyle(
                    color: tc,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: widget.showOnlyDeals
              ? Colors.redAccent
              : const Color(0xFFFFE100),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.showOnlyDeals ? Icons.local_fire_department : Icons.bolt,
                color: Colors.deepOrange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                widget.showOnlyDeals
                    ? 'قسم العروض الصارخة لقطة! 📉'
                    : 'تخفيضات البرق حية بسوريا ⚡',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (!widget.showOnlyDeals) ...[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  hintText: 'ابحث بنمط تيمو السريع...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DropdownButtonFormField<String>(
              initialValue: _cat,
              decoration: const InputDecoration(
                labelText: 'تصفح بحسب خانة المنتج',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
              items: _cats
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _cat = v!),
            ),
          ),
        ],
        const SizedBox(height: 4),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _getData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: 4,
                  itemBuilder: (c, i) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.blur_linear,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                );
              }
              var list = snapshot.data!;
              if (widget.showOnlyDeals) {
                list = list.where((item) => item['is_deal'] == true).toList();
              }
              final filtered = list
                  .where(
                    (item) =>
                        item['title'].toString().toLowerCase().contains(
                          _q.toLowerCase(),
                        ) &&
                        (_cat == 'الكل' || item['category'] == _cat),
                  )
                  .toList();
              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد عروض 🔍',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final isFav = widget.favorites.any(
                    (f) => f['title'] == item['title'],
                  );
                  final currentPhone = (item['phone'] ?? '0912345678')
                      .toString()
                      .replaceAll(RegExp(r'\s+'), '');
                  final String imgUrl = (item['image'] ?? '').toString();
                  final isPinned = item['is_pinned'] ?? false;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ProductDetailScreen(
                          product: item,
                        ), // 👈 قمنا بتغيير item: إلى product:
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: isPinned
                            ? Border.all(color: Colors.orange, width: 1.5)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: imgUrl.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(imgUrl.split(',').last),
                                        height: 95,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          height: 95,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Image.network(
                                        imgUrl,
                                        height: 95,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          height: 95,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.85,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                    onPressed: () => widget.onToggleFav(item),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['title'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    item['shop_name'] ?? '',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    item['price'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    item['location'] ?? '',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2ECC71),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Text(
                                      'التفاصيل والطلب',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
