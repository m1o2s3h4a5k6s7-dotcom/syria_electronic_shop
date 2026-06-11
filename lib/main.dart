import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'product_grid.dart';
import 'add_product.dart';
import 'dart:html' as html;

void main() => runApp(const SyriaShopApp());

class SyriaShopApp extends StatelessWidget {
  const SyriaShopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.orange),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _idx = 0;
  List<Map<String, dynamic>> _prods = [];
  final List<Map<String, dynamic>> _favs = [];
  List<String> _notifs = [];
  Map<String, String> _mq = {
    'text': '🔥 عروض البرق حية الآن من أسواق سوريا الكبرى ⚡',
    'textColor': '0xFFFFE100',
    'bgColor': '0xFF1A252F',
  };
  List<Map<String, String>> _bans = [
    {
      'img': 'https://picsum.photos',
      't': '🔥 تخفيضات تيمو البرق الكبرى حسم 70%',
    },
    {'img': 'https://picsum.photos', 't': '🚗 سوق السيارات الأقوى في سوريا'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _requestFirstTimePermission();
  }

  Future<void> _requestFirstTimePermission() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool('perm_granted') == null) {
      html.window.navigator
          .getUserMedia(video: true)
          .then((stream) {
            p.setBool('perm_granted', true);
            stream.getTracks().forEach((track) => track.stop());
          })
          .catchError((_) {});
    }
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final String? d = p.getString('p_sy');
    final String? b = p.getString('b_sy');
    final String? n = p.getString('n_sy');
    final String? m = p.getString('m_sy');
    setState(() {
      if (d != null) _prods = List<Map<String, dynamic>>.from(json.decode(d));
      if (b != null) _bans = List<Map<String, String>>.from(json.decode(b));
      if (n != null) _notifs = List<String>.from(json.decode(n));
      if (m != null) _mq = Map<String, String>.from(json.decode(m));
    });
  }

  Future<void> _addP(Map<String, dynamic> n) async {
    final p = await SharedPreferences.getInstance();
    n['is_pinned'] = false;
    n['is_deal'] = false;
    setState(() {
      _prods.add(n);
      _notifs.insert(0, "🔔 مادة جديدة: ${n['title']} بقسم ${n['category']}");
      _idx = 0;
    });
    await p.setString('p_sy', json.encode(_prods));
    await p.setString('n_sy', json.encode(_notifs));
  }

  Future<void> _toggleDeal(int i) async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _prods[i]['is_deal'] = !(_prods[i]['is_deal'] ?? false);
      if (_prods[i]['is_deal'] == true) {
        _notifs.insert(0, "📉 حسم خاص على: ${_prods[i]['title']}");
      }
    });
    await p.setString('p_sy', json.encode(_prods));
    await p.setString('n_sy', json.encode(_notifs));
  }

  Future<void> _pin(int i) async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _prods[i]['is_pinned'] = !(_prods[i]['is_pinned'] ?? false);
      if (_prods[i]['is_pinned'] == true) {
        var item = _prods.removeAt(i);
        _prods.insert(0, item);
      }
    });
    await p.setString('p_sy', json.encode(_prods));
  }

  Future<void> _del(int i) async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _prods.removeAt(i);
    });
    await p.setString('p_sy', json.encode(_prods));
  }

  Future<void> _delBanner(int i) async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _bans.removeAt(i);
    });
    await p.setString('b_sy', json.encode(_bans));
  }

  Future<void> _addB(String t, List<String> imgs) async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      for (var img in imgs) {
        _bans.insert(0, {'img': img, 't': t});
      }
    });
    await p.setString('b_sy', json.encode(_bans));
  }

  Future<void> _updateMq(String txt, String tc, String bg) async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _mq = {'text': txt, 'textColor': tc, 'bgColor': bg};
    });
    await p.setString('m_sy', json.encode(_mq));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProductGridScreen(
        localProducts: _prods,
        favorites: _favs,
        adminBanners: _bans,
        marqueeSettings: _mq,
        onToggleFav: (item) {
          setState(() {
            if (_favs.any((f) => f['title'] == item['title'])) {
              _favs.removeWhere((f) => f['title'] == item['title']);
            } else {
              _favs.add(item);
            }
          });
        },
      ),
      ProductGridScreen(
        localProducts: _prods,
        favorites: _favs,
        adminBanners: _bans,
        marqueeSettings: _mq,
        onToggleFav: (item) {},
        showOnlyDeals: true,
      ),
      Scaffold(
        body: _favs.isEmpty
            ? const Center(child: Text('المفضلة فارغة ❤️'))
            : ProductGridScreen(
                localProducts: _favs,
                favorites: _favs,
                adminBanners: _bans,
                marqueeSettings: _mq,
                onToggleFav: (item) {},
              ),
      ),
      Scaffold(
        body: _notifs.isEmpty
            ? const Center(child: Text('🔔 لا توجد تنبيهات حالياً'))
            : ListView.builder(
                itemCount: _notifs.length,
                itemBuilder: (c, i) => Card(
                  margin: const EdgeInsets.all(4),
                  child: ListTile(
                    leading: const Icon(Icons.flash_on, color: Colors.orange),
                    title: Text(
                      _notifs[i],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
      ),
      AddProductScreen(onProductAdded: _addP),
      AdminPanelScreen(
        localProducts: _prods,
        adminBanners: _bans,
        onDeleteLocal: _del,
        onDeleteBanner: _delBanner,
        onTogglePin: _pin,
        onToggleDeal: _toggleDeal,
        onAddBannersFromStudio: _addB,
        onSaveMarquee: _updateMq,
        currentMarquee: _mq,
      ),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'متجر تيمو سوريا الإلكتروني',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          backgroundColor: const Color(0xFF1A252F),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.security,
                color: Colors.orangeAccent,
                size: 18,
              ),
              onPressed: () => setState(() => _idx = 5),
            ),
          ],
        ),
        body: screens[_idx],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _idx > 4 ? 0 : _idx,
          onTap: (i) => setState(() => _idx = i),
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department),
              label: 'العروض',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'الجرس',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart),
              label: 'أنا بائع',
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  final List<Map<String, dynamic>> localProducts;
  final List<Map<String, String>> adminBanners;
  final Function(int) onDeleteLocal;
  final Function(int) onDeleteBanner;
  final Function(int) onTogglePin;
  final Function(int) onToggleDeal;
  final Function(String, List<String>) onAddBannersFromStudio;
  final Function(String, String, String) onSaveMarquee;
  final Map<String, String> currentMarquee;
  const AdminPanelScreen({
    super.key,
    required this.localProducts,
    required this.adminBanners,
    required this.onDeleteLocal,
    required this.onDeleteBanner,
    required this.onTogglePin,
    required this.onToggleDeal,
    required this.onAddBannersFromStudio,
    required this.onSaveMarquee,
    required this.currentMarquee,
  });
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _auth = false;
  final _pass = TextEditingController();
  final _bt = TextEditingController();
  List<String> _bannerImgs = [];
  final _mqText = TextEditingController();
  final String _selTxtCol = '0xFFFFE100';
  final String _selBgCol = '0xFF1A252F';
  @override
  void initState() {
    super.initState();
    _mqText.text = widget.currentMarquee['text'] ?? '';
  }

  void _pickMultiBanners() {
    final html.FileUploadInputElement up = html.FileUploadInputElement();
    up.accept = 'image/jpeg,image/png,image/webp';
    up.setAttribute('multiple', 'true');
    up.click();
    up.onChange.listen((e) {
      if (up.files!.isNotEmpty) {
        setState(() => _bannerImgs.clear());
        int currentIndex = 0;
        void readNextFile() {
          if (currentIndex >= up.files!.length) return;
          final r = html.FileReader();
          r.readAsDataUrl(up.files![currentIndex]);
          r.onLoadEnd.listen((e) {
            setState(() {
              _bannerImgs.add(r.result as String);
            });
            currentIndex++;
            readNextFile();
          });
        }

        readNextFile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 50, color: Colors.orange),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'الرمز السري'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_pass.text == "SyriaAdmin2026") {
                  setState(() => _auth = true);
                }
              },
              child: const Text('دخول'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          TextField(
            controller: _mqText,
            decoration: const InputDecoration(labelText: 'نص الإعلان الزاحف'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onSaveMarquee(_mqText.text, _selTxtCol, _selBgCol);
            },
            child: const Text('حفظ النص الزاحف'),
          ),
          const Divider(color: Colors.orange),
          ElevatedButton(
            onPressed: _pickMultiBanners,
            child: const Text('📸 حدد صور الإعلانات المجمعة معاً دفعة واحدة'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_bannerImgs.isNotEmpty) {
                widget.onAddBannersFromStudio(
                  _bt.text.isEmpty ? 'إعلان مميز' : _bt.text,
                  _bannerImgs,
                );
                _bt.clear();
                setState(() {
                  _bannerImgs = [];
                });
              }
            },
            child: const Text('نشر البانرات حياً في الرأس'),
          ),
          const Divider(color: Colors.orange),
          const Text(
            '📺 إدارة الإعلانات الحالية البانر:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          ...List.generate(
            widget.adminBanners.length,
            (i) => Card(
              child: ListTile(
                title: Text(widget.adminBanners[i]['t'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => widget.onDeleteBanner(i),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.orange),
          const Text(
            '🎛️ فرز وتثبيت وتحويل السلع العروض:',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          ...List.generate(widget.localProducts.length, (i) {
            final item = widget.localProducts[i];
            final pin = item['is_pinned'] ?? false;
            final deal = item['is_deal'] ?? false;
            return Card(
              child: ListTile(
                title: Text(item['title'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        deal
                            ? Icons.local_fire_department
                            : Icons.local_fire_department_outlined,
                        color: deal ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => widget.onToggleDeal(i),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.push_pin,
                        color: pin ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () => widget.onTogglePin(i),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => widget.onDeleteLocal(i),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
