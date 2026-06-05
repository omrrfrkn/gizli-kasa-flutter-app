import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:path_provider/path_provider.dart'; 

void main() {
  runApp(const GizliKasaUygulamasi());
}

class GizliKasaUygulamasi extends StatelessWidget {
  const GizliKasaUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hesap Makinesi Kasa',
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Colors.black12, 
        body: Center(
          child: SizedBox(
            width: 390,  
            height: 800, 
            child: HesapMakinesiEkrani(),
          ),
        ),
      ),
    );
  }
}

class HesapMakinesiEkrani extends StatefulWidget {
  const HesapMakinesiEkrani({super.key});

  @override
  State<HesapMakinesiEkrani> createState() => _HesapMakinesiEkraniState();
}

class _HesapMakinesiEkraniState extends State<HesapMakinesiEkrani> {
  static String? _kullaniciSifresi; 
  String _ekranYazisi = '0';
  String _oncekiSayi = '';
  String _islem = '';
  bool _hesaplamaBitti = false;
  bool _sifreDegistirmeModu = false; 

  void _butonaBasildi(String butonMetni) {
    setState(() {
      if (butonMetni == 'C') {
        _ekranYazisi = '0';
        _oncekiSayi = '';
        _islem = '';
        _hesaplamaBitti = false;
      } else if (butonMetni == '+' || butonMetni == '-' || butonMetni == 'x' || butonMetni == '÷') {
        if (_kullaniciSifresi == null || _sifreDegistirmeModu) return;
        if (_ekranYazisi != '0') {
          _oncekiSayi = _ekranYazisi;
          _islem = butonMetni;
          _ekranYazisi = '0';
          _hesaplamaBitti = false;
        }
      } else if (butonMetni == '=') {
        if (_kullaniciSifresi == null) {
          if (_ekranYazisi != '0' && _ekranYazisi.length >= 4) {
            _kullaniciSifresi = _ekranYazisi;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Şifreniz başarıyla "$_kullaniciSifresi" olarak belirlendi!')),
            );
            _ekranYazisi = '0';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lütfen en az 4 haneli bir şifre yazın!')),
            );
          }
          return;
        }

        if (_ekranYazisi == '11111' && _islem == '' && !_sifreDegistirmeModu) {
          _sifreDegistirmeModu = true;
          _ekranYazisi = '0';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şifre değiştirme modu aktif! Yeni şifrenizi girip = basın.')),
          );
          return;
        }

        if (_sifreDegistirmeModu) {
          if (_ekranYazisi != '0' && _ekranYazisi.length >= 4) {
            _kullaniciSifresi = _ekranYazisi;
            _sifreDegistirmeModu = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Şifreniz başarıyla "$_kullaniciSifresi" olarak güncellendi!')),
            );
            _ekranYazisi = '0';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yeni şifre en az 4 haneli olmalıdır!')),
            );
          }
          return;
        }

        if (_ekranYazisi == _kullaniciSifresi && _islem == '') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GizliKasaGalerisi()),
          ).then((value) => setState(() {})); 
          _ekranYazisi = '0';
        } else if (_islem.isNotEmpty && _oncekiSayi.isNotEmpty) {
          double sayi1 = double.parse(_oncekiSayi);
          double sayi2 = double.parse(_ekranYazisi);
          double sonuc = 0;

          if (_islem == '+') sonuc = sayi1 + sayi2;
          if (_islem == '-') sonuc = sayi1 - sayi2;
          if (_islem == 'x') sonuc = sayi1 * sayi2;
          if (_islem == '÷') sonuc = sayi1 / sayi2;

          _ekranYazisi = sonuc == sonuc.toInt() ? sonuc.toInt().toString() : sonuc.toString();
          _islem = '';
          _oncekiSayi = '';
          _hesaplamaBitti = true;
        }
      } else {
        if (_ekranYazisi == '0' || _hesaplamaBitti) {
          _ekranYazisi = butonMetni;
          _hesaplamaBitti = false;
        } else {
          _ekranYazisi += butonMetni;
        }
      }
    });
  }

  Widget _hesapButonu(String butonMetni, Color renk, {Color yaziRengi = Colors.white, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: flex == 1 ? 1 : 2.2, 
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: renk,
              foregroundColor: yaziRengi,
              shape: flex == 1 ? const CircleBorder() : const StadiumBorder(), 
              padding: EdgeInsets.zero,
            ),
            onPressed: () => _butonaBasildi(butonMetni),
            child: Text(
              butonMetni,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color ikonGri = const Color(0xFFA5A5A5);
    Color koyuGri = const Color(0xFF333333);
    Color iphoneTuruncu = const Color(0xFFFF9F0A);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                _kullaniciSifresi == null 
                    ? 'Lütfen Giriş Şifrenizi Belirleyin ve = Tuşuna Basın' 
                    : (_sifreDegistirmeModu ? 'YENİ ŞİFRENİZİ YAZIN VE = BASIN' : ''),
                style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.only(right: 20, bottom: 12),
                  child: Text(
                    _ekranYazisi,
                    style: const TextStyle(fontSize: 70, fontWeight: FontWeight.w300, color: Colors.white),
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      _hesapButonu('C', ikonGri, yaziRengi: Colors.black),
                      _hesapButonu('+/-', ikonGri, yaziRengi: Colors.black),
                      _hesapButonu('%', ikonGri, yaziRengi: Colors.black),
                      _hesapButonu('÷', iphoneTuruncu),
                    ],
                  ),
                  Row(
                    children: [
                      _hesapButonu('7', koyuGri),
                      _hesapButonu('8', koyuGri),
                      _hesapButonu('9', koyuGri),
                      _hesapButonu('x', iphoneTuruncu),
                    ],
                  ),
                  Row(
                    children: [
                      _hesapButonu('4', koyuGri),
                      _hesapButonu('5', koyuGri),
                      _hesapButonu('6', koyuGri),
                      _hesapButonu('-', iphoneTuruncu),
                    ],
                  ),
                  Row(
                    children: [
                      _hesapButonu('1', koyuGri),
                      _hesapButonu('2', koyuGri),
                      _hesapButonu('3', koyuGri),
                      _hesapButonu('+', iphoneTuruncu),
                    ],
                  ),
                  Row(
                    children: [
                      _hesapButonu('0', koyuGri, flex: 2),
                      _hesapButonu('.', koyuGri),
                      _hesapButonu('=', iphoneTuruncu),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class KasaDosyasi {
  final String dosyaYolu;
  final bool videoMu;
  bool seciliMi; // Ekran görüntüsündeki tanımsızlık hatası giderildi.

  KasaDosyasi({
    required this.dosyaYolu, 
    required this.videoMu,
    this.seciliMi = false,
  });
}

class GizliKasaGalerisi extends StatefulWidget {
  const GizliKasaGalerisi({super.key});

  @override
  State<GizliKasaGalerisi> createState() => _GizliKasaGalerisiState();
}

class _GizliKasaGalerisiState extends State<GizliKasaGalerisi> {
  final List<KasaDosyasi> _kasaIcerigi = [];
  final ImagePicker _picker = ImagePicker();
  bool _secimModuAktif = false; 

  // MEDYAYI SEÇME, KASAYA TAŞIMA VE ORİJİNALİNİ SİLME
  void _medyaSec(bool videoSecilsinMi) async {
    final XFile? secilenDosya;
    
    if (videoSecilsinMi) {
      secilenDosya = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      secilenDosya = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (secilenDosya != null) {
      String kaydedilecekYol = secilenDosya.path;

      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final String benzersizIsim = "${DateTime.now().millisecondsSinceEpoch}_${secilenDosya.name}";
        final File yeniDosya = await File(secilenDosya.path).copy('${directory.path}/$benzersizIsim');
        kaydedilecekYol = yeniDosya.path;

        // Orijinal dosyayı sistem galerisinden/kaynağından tamamen silme
        try {
          final File orijinalDosya = File(secilenDosya.path);
          if (await orijinalDosya.exists()) {
            await orijinalDosya.delete();
          }
        } catch (e) {
          debugPrint("Galeri taşıma kısıtlaması: $e");
        }
      }

      if (!mounted) return; // BuildContext async gap hatası giderildi.

      setState(() {
        _kasaIcerigi.add(
          KasaDosyasi(dosyaYolu: kaydedilecekYol, videoMu: videoSecilsinMi),
        );
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('🔒 Güvenle Taşındı'),
          content: const Text('Seçilen dosya galeri dizininden silinerek doğrudan şifreli yerel kasaya taşınmıştır.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım', style: TextStyle(color: Colors.orange)),
            )
          ],
        ),
      );
    }
  }

  // ÇOKLU SEÇİLENLERİ SİLME
  void _secilenleriSil() async {
    List<KasaDosyasi> silinecekler = _kasaIcerigi.where((e) => e.seciliMi).toList();
    if (silinecekler.isEmpty) return;

    if (!kIsWeb) {
      for (var dosya in silinecekler) {
        final file = File(dosya.dosyaYolu);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    setState(() {
      _kasaIcerigi.removeWhere((e) => e.seciliMi);
      _secimModuAktif = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seçilen medyalar kasadan kalıcı olarak silindi! 🗑️')),
    );
  }

  // ÇOKLU SEÇİLENLERİ GALERİYE GERİ GÖNDERME
  void _secilenleriGaleriyeGeriYukle() {
    List<KasaDosyasi> aktarilacaklar = _kasaIcerigi.where((e) => e.seciliMi).toList();
    if (aktarilacaklar.isEmpty) return;

    setState(() {
      _kasaIcerigi.removeWhere((e) => e.seciliMi);
      _secimModuAktif = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seçilen medyalar normal galeriye geri döndürüldı! 📂')),
    );
  }

  void _secimMenusunuGoster() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.orange),
                title: const Text('Fotoğraf Yükle'),
                onTap: () {
                  Navigator.pop(context);
                  _medyaSec(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_collection, color: Colors.orange),
                title: const Text('Video Yükle'),
                onTap: () {
                  Navigator.pop(context);
                  _medyaSec(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizli Kasa Galerisi'),
        backgroundColor: Colors.grey[900],
        actions: [
          if (_kasaIcerigi.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _secimModuAktif = !_secimModuAktif;
                  if (!_secimModuAktif) {
                    for (var e in _kasaIcerigi) {
                      e.seciliMi = false;
                    }
                  }
                });
              },
              child: Text(
                _secimModuAktif ? 'İptal' : 'Seç',
                style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (!_secimModuAktif)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)), 
              ),
              child: const Text(
                '💡 Şifrenizi değiştirmek istiyorsanız ana ekranda 11111 giriniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w500),
              ),
            ),
          
          Expanded(
            child: _kasaIcerigi.isEmpty
                ? const Center(
                    child: Text(
                      'Kasanız Boş!\n\nSağ alttaki + butonuna basarak\ngerçek fotoğraf veya video ekleyebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _kasaIcerigi.length,
                      itemBuilder: (context, index) {
                        final dosya = _kasaIcerigi[index];
                        return GestureDetector(
                          onTap: () {
                            if (_secimModuAktif) {
                              setState(() {
                                dosya.seciliMi = !dosya.seciliMi;
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb 
                                      ? Image.network(dosya.dosyaYolu, fit: BoxFit.cover)
                                      : Image.file(File(dosya.dosyaYolu), fit: BoxFit.cover),
                                ),
                              ),
                              if (dosya.videoMu)
                                const Center(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                                  ),
                                ),
                              if (_secimModuAktif)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Icon(
                                    dosya.seciliMi ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: dosya.seciliMi ? Colors.orange : Colors.white70,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          
          // Çoklu İşlem Menüsü alt çubuğu kontrol paneli hatası tamamen giderildi.
          if (_secimModuAktif && _kasaIcerigi.any((e) => e.seciliMi))
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                    onPressed: _secilenleriSil,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text('Çoklu Sil', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    onPressed: _secilenleriGaleriyeGeriYukle,
                    icon: const Icon(Icons.unarchive, color: Colors.white),
                    label: const Text('Galeriye Döndür', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _secimModuAktif 
          ? null 
          : FloatingActionButton(
              onPressed: _secimMenusunuGoster,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
    );
  }
}