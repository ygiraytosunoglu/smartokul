import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_okul_mobile/screens/door_control_page.dart';
import 'package:smart_okul_mobile/screens/door_control_screen.dart';
import 'package:smart_okul_mobile/screens/meal_list_screen_new.dart';
import 'package:smart_okul_mobile/services/konum.dart';
import '../constants.dart';
import 'login_screen.dart';
import 'send_notification_screen.dart';
import 'package:http/http.dart' as http;


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( '$globalOkulAdi'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: <Widget>[
              _buildMenuCard(
                context,
                'Öğretmene Anons',
                Icons.campaign,
                    () => _bildirim(context),/*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>const SendNotificationScreen(),
                  ),
                ),*/
              ),
              /*_buildMenuCard(
                context,
                'Öğrenci Hareket Listesi',
                Icons.people,
                    () {
                  // TODO: Navigate to student movement screen
                },
              ),*/
             /* _buildMenuCard(
                context,
                'Resimler',
                Icons.photo_library,
                    () {
                  // TODO: Navigate to images screen
                },
              ),*/
             /* _buildMenuCard(
                context,
                'Personel Giriş-Çıkış',
                Icons.badge,
                    () {
                  // TODO: Navigate to staff attendance screen
                },
              ),*/
              _buildMenuCard(
                context,
                'Yemek Listesi',
                Icons.restaurant_menu,
                    () {
                  // TODO: Navigate to meal list screen
                      _yemekListesiSayfasiniAc(context);
                },
              ),
             /* _buildMenuCard(
                context,
                'Ödeme Listesi',
                Icons.payment,
                    () {
                  // TODO: Navigate to payment list screen
                },
              ),*/
              _buildMenuCard(
                context,
                'Kapı Kontrol',
                Icons.door_front_door,
                    () {
                  // TODO: Navigate to door control screen
                      kapiKontrol(context);
                },
              ),
              _buildMenuCard(
                context,
                'Bildirim Gönder',
                Icons.notifications,
                    () {
                  // TODO: Navigate to notifications screen
                      _bildirimGonderSayfasiniAc(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.blue.withOpacity(0.3),
            highlightColor: Colors.blue.withOpacity(0.15),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _kapiKontrolSayfasiniAc(BuildContext context) {
    //print("menu sayfasına gidiyor");
    bool vhasGateAccess = true;
    bool vhasParkingAccess = false;
   /* print("mevcut konum öncesi");
    Konum mevcutKonum = new Konum();
    mevcutKonum.createState();*/

    if (globalKullaniciTipi == "M" || globalKullaniciTipi == "T") {
      vhasParkingAccess = true;
    }
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return DoorControlPage(hasGateAccess: vhasGateAccess, hasParkingAccess: vhasParkingAccess);//(globalKullaniciAdi);//_userController.text);
      },
    );
    Navigator.push(context, sayfaYolu);
    //print("menu sayfasına gidiyor2");
  }

  void _yemekListesiSayfasiniAc(BuildContext context) {
    //print("menu sayfasına gidiyor");
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return MealListScreenNew() ;//(globalKullaniciAdi);//_userController.text);
      },
    );
    Navigator.push(context, sayfaYolu);
    //print("menu sayfasına gidiyor2");
  }

  void _bildirimGonderSayfasiniAc(BuildContext context) {
    //print("menu sayfasına gidiyor");
    if (globalKullaniciTipi == "T") {
      MaterialPageRoute sayfaYolu = MaterialPageRoute(
        builder: (BuildContext context) {
          return SendNotificationScreen();//(globalKullaniciAdi);//_userController.text);
        },
      );
      Navigator.push(context, sayfaYolu);
      //print("menu sayfasına gidiyor2");

    }else{
      _pencereAc(context, "Sadece öğretmenler velilere bildirim gönderebilir!");
    }

  }

  void _bildirim(BuildContext context)  {
    print("globalKullaniciTipiiii:"+globalKullaniciTipi);
    if (globalKullaniciTipi == "P" || globalKullaniciTipi == "S") {
      Future<String> cevap ;//= _bildirimGonder();
      _bildirimGonder().then((cevap){
        if (cevap =="200" )   {
          _pencereAc(context,"Öğretmeninize Bildirim gönderildi");
        } else {
          _pencereAc(context, "Bildirim gönderilemedi ");
        }
      });


    }else{
      _pencereAc(context, "Sadece öğrenci ve veliler öğretmene bildirim gönderebilir!");
    }


  }

  Future _pencereAc(BuildContext context, String mesaj) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(title: Text(mesaj));
      },
    );
  }

  double mesafeHesapla(double enlem1, double boylam1, double enlem2, double boylam2) {
    /*double enlem1 = 41.0082; // İstanbul
    double boylam1 = 28.9784;
    double enlem2 = 40.7128; // New York
    double boylam2 = -74.0060;
*/
    // Geolocator paketini kullanarak mesafeyi hesaplama
    double mesafe = Geolocator.distanceBetween(enlem1, boylam1, enlem2, boylam2);

    print('İki konum arasındaki mesafe: ${mesafe.toStringAsFixed(2)} metre');
    return mesafe;
  }

  Future<String> _bildirimGonder() async {
    //URL Degisecek
    final String baseUrl =
        "http://212.154.74.47:5000/api/school/send-notification?schoolId="+globalSchoolId+"&TCKN="+globalParentTCKN;
    // "http://api.exchangeratesapi.io/v1/latest?access_key=";0
    print("baseUrl:$baseUrl");
    Uri uri = Uri.parse(baseUrl );
    http.Response response = await http.get(uri);
    print("response status:${response.statusCode.toString()??"0"}");
    print("response.body:${response.body}");
    return Future.delayed(Duration(seconds: 2), () => response.statusCode.toString()??"0");

  }

  void kapiKontrol(BuildContext context) async{
    String konum = await konumAlYeni();
    double mesafe ;
    konumAlYeni().then((konum)
    {
      print("konum bilgisi yeni:"+konum);
    }
    );
    print("konum bilgisi:"+globalKonumEnlem+" "+ globalKonumBoylam);
    print("mevcut konum bilgisi:"+mevcutEnlem+" "+ mevcutBoylam);


    if(mevcutBoylam!=null && mevcutEnlem!=null){
      mesafe = mesafeHesapla(double.parse(globalKonumEnlem), double.parse(globalKonumBoylam), double.parse(mevcutEnlem), double.parse(mevcutBoylam));
      print("mesafe:"+mesafe.toString());
      /*if (mesafe > mesafeLimit) {
        _pencereAc(context, "Kapıyı açmak için yeteri kadar yakın mesafede değilsiniz.Konum ayarlarınızı kontrol ediniz!");
      }else {
        _kapiKontrolSayfasiniAc(context);
      }*/
      _kapiKontrolSayfasiniAc(context);
    }else{
      _pencereAc(context, "Mevcut konum bulunamadı. Konum ayarlarınızı kontrol ediniz!");
    }

  }

  Future<String> konumAlYeni() async {
    String _konumBilgisi = "Konum bilgisi bekleniyor...";

    bool servisAktif = await Geolocator.isLocationServiceEnabled();
    if (!servisAktif) {
        _konumBilgisi = "Konum servisi kapalı.";
      return _konumBilgisi;
    }

    LocationPermission izinDurumu = await Geolocator.checkPermission();
    if (izinDurumu == LocationPermission.denied) {
      izinDurumu = await Geolocator.requestPermission();
      if (izinDurumu == LocationPermission.denied) {
          _konumBilgisi = "Konum izni reddedildi.";
        return _konumBilgisi;
      }
    }

    if(izinDurumu == LocationPermission.deniedForever){
        _konumBilgisi = "Konum izni kalıcı olarak reddedildi.";
      return _konumBilgisi;
    }

    Position konum = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
     mevcutEnlem = konum.latitude.toString();
      mevcutBoylam = konum.longitude.toString();

      _konumBilgisi = "Enlem: ${konum.latitude}, Boylam: ${konum.longitude}";

    print("konum bilgisi:"+_konumBilgisi+ "mevcutEnlem:"+mevcutEnlem+" mevcutBoylam:"+mevcutBoylam);
    return _konumBilgisi;
  }
}