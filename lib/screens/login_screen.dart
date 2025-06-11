import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_okul_mobile/screens/door_control_screen.dart';
import 'package:smart_okul_mobile/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

var globalKullaniciAdi ="";
var globalOkulAdi      ="";
var globalParentTCKN   ="";
var globalKullaniciTipi ="";
var globalOgrenciAdi    ="";
var globalStatusCode    ="";
var globalErrMsg        ="";
var globalSchoolId      ="";
var globalKonumEnlem    ="";
var globalKonumBoylam   ="";
var mevcutEnlem         ="";
var mevcutBoylam         ="";
int mesafeLimit         =150;

String _konumBilgisi = "Konum bilgisi bekleniyor...";


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _tcNoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeFirebaseMessaging();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kullaniciAdiniKontrolEt(context);
    });
}

  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Cihaz token'ını al (sunucuya göndermek için)
    var _token = await messaging.getToken();
    print("FirebaseMessaging Token: $_token");

    // İzinleri iste (iOS ve Android 13+ için)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Ön planda gelen mesajları dinle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Burada ön planda bildirim göstermek için flutter_local_notifications kullanabilirsiniz.
        // FCM otomatik olarak ön planda bildirim göstermez.
      }
    });

    // Uygulama arka plandayken veya kapalıyken açılan bildirimi dinle
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');
      // Bildirime tıklandığında yapılacak işlemler (örneğin belirli bir sayfaya yönlendirme)
    });
  }

  void _kullaniciAdiniKontrolEt(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tcNoController.text = prefs.getString("kullaniciAdi") ?? "";
    _passwordController.text = prefs.getString("sifre") ?? "";

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[700]!,
              Colors.blue[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve Başlık
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Smart Okul Sistemi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Giriş Formu
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // TC Kimlik No
                          TextFormField(
                            controller: _tcNoController,
                            keyboardType: TextInputType.number,
                            maxLength: 11,
                            decoration: InputDecoration(
                              labelText: 'TC Kimlik No',
                              hintText: '11 haneli TC Kimlik No giriniz',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'TC Kimlik No boş bırakılamaz';
                              }
                              if (value.length != 11) {
                                return 'TC Kimlik No 11 haneli olmalıdır';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Şifre
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              hintText: 'Şifrenizi giriniz',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre boş bırakılamaz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Giriş Butonu
                          ElevatedButton(
                            onPressed: () {
                              print("butona basıldı");
                              if (_formKey.currentState!.validate()) {
                                // TODO: Giriş işlemi
                                print("menu1");
                                _girisYap(context);
                                print("menu2");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 16,
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tcNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _girisYap(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("kullaniciAdi", _tcNoController.text);
    await prefs.setString("sifre", _passwordController.text);
    print ("giris yap $globalKullaniciAdi");
    String sonuc = await _kullaniciBilgileriniCek();
    //String konum = await konumAlYeni();
    print("_kullaniciBilgileriniCek sonrası globalStatusCode"+globalStatusCode);

    if(globalStatusCode!="200"){
      print("pencere acilacak");
      _pencereAc(context, globalErrMsg);
      return;
    }

    /*konumAlYeni().then((konum)
    {
      print("konum bilgisi yeni:"+konum);
    }
    );*/
    _kullaniciBilgileriniCek().then((sonuc){
      print("veri indirildi");
      /*if(globalStatusCode!=200){
        _pencereAc(context, globalErrMsg);
        return;
      }*/
      onLoginSuccess(globalParentTCKN);
      print("onLoginSuccess bitti");
    });
    print ("giris yap "+globalKullaniciAdi.toString());

    if (_tcNoController.text.isEmpty || _passwordController.text.isEmpty) {
      _pencereAc(context,"Kullanıcı adı veya şifre boş bırakılamaz");
      return;
    } else {
      _menuSayfasiniAc(context);
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

  Future<String> _kullaniciBilgileriniCek() async {
    final String baseUrl =
        "http://212.154.74.47:5000/api/school/validate-person?tckn=${_tcNoController.text}&pin=${_passwordController.text}";
    // "http://api.exchangeratesapi.io/v1/latest?access_key=";
    print("baseUrl:$baseUrl");
    Uri uri = Uri.parse(baseUrl );
    http.Response response = await http.get(uri);
    print("response:$response");
    print("response.body:${response.body}");

    globalStatusCode =    response.statusCode.toString()??"0";
    print("globalStatusCode"+globalStatusCode);

    globalErrMsg  = response.body.toString()??"";
    if(globalStatusCode!="200"){
      return Future.delayed(Duration(seconds: 2), () => globalErrMsg);
    }
    Map<String, dynamic> parsedResponse =  jsonDecode(response.body);

    //Map<String, dynamic> rates = parsedResponse["rates"];
    print('MAP YAZIYOR DİKKAT$parsedResponse');


    globalKullaniciAdi = parsedResponse["Name"];
    globalOkulAdi = parsedResponse["SchoolName"];
    globalParentTCKN = parsedResponse["TCKN"];
    globalKullaniciTipi = parsedResponse["Type"];
    globalOgrenciAdi = parsedResponse["StudentName"]??"";
    globalSchoolId = parsedResponse["SchoolId"].toString();
    globalKonumEnlem = parsedResponse["KonumEnlem"].toString();
    globalKonumBoylam= parsedResponse["KonumBoylam"].toString();
    mesafeLimit = parsedResponse["MesafeLimit"];

    //Future.delayed(const Duration(seconds: 5), () => print('Large Latte'));


    print("KULLANICI ADI$globalKullaniciAdi");
    return Future.delayed(Duration(seconds: 2), () => "Veri indirildi!");


    /*if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
         // _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }*/

  }

  void onLoginSuccess(String tckn) async {
    // 1. Firebase token'ı al
   // FirebaseMessaging messaging = FirebaseMessaging.instance;
   // final fcmToken = await messaging.getToken();
   Future<String?> token = FirebaseMessaging.instance.getToken();
   String tokenRequest ;
   // 2. Server'a gönder
   await http.post(Uri.parse("http://212.154.74.47:5000/api/school/validate-person?tckn="+_tcNoController.text+"&pin="+_passwordController.text) as Uri);

   FirebaseMessaging.instance.getToken().then((token){
     print("token:"+token.toString());
     tokenRequest = "http://212.154.74.47:5000/api/school/register-fcm-token?tckn="+_tcNoController.text+"&fcmToken="+token.toString();
     print("tokenRequest "+tokenRequest);
     http.post(Uri.parse(tokenRequest) as Uri);
   });


    /* await http.post(
      Uri.parse("http://212.154.74.47:5000/api/school/register-fcm-token"),
      body: {
        "tckn": tckn,
        "fcmToken": fcmToken,
      },
    );

    await messaging.requestPermission();*/

    // 3. Ana ekrana geç
    /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
        );*/
  }



  void _menuSayfasiniAc(BuildContext context) {
    print("menu sayfasına gidiyor");
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen();//(globalKullaniciAdi);//_userController.text);
      },
    );
    Navigator.push(context, sayfaYolu);
    print("menu sayfasına gidiyor2");
  }


  /*Future<String> konumAlYeni() async {
    bool servisAktif = await Geolocator.isLocationServiceEnabled();
    if (!servisAktif) {
      setState(() {
        _konumBilgisi = "Konum servisi kapalı.";
      });
      return _konumBilgisi;
    }

    LocationPermission izinDurumu = await Geolocator.checkPermission();
    if (izinDurumu == LocationPermission.denied) {
      izinDurumu = await Geolocator.requestPermission();
      if (izinDurumu == LocationPermission.denied) {
        setState(() {
          _konumBilgisi = "Konum izni reddedildi.";
        });
        return _konumBilgisi;
      }
    }

    if(izinDurumu == LocationPermission.deniedForever){
      setState(() {
        _konumBilgisi = "Konum izni kalıcı olarak reddedildi.";
      });
      return _konumBilgisi;
    }

    Position konum = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      mevcutEnlem = konum.latitude.toString();
      mevcutBoylam = konum.longitude.toString();

      _konumBilgisi = "Enlem: ${konum.latitude}, Boylam: ${konum.longitude}";

    });
    print("konum bilgisi:"+_konumBilgisi);
    return _konumBilgisi;
  }*/
}
/*
web       1:1081547088552:web:7ab6c52acd30d1cc14d89d
android   1:1081547088552:android:e2f266e1e78a392014d89d
ios       1:1081547088552:ios:839e138180537d1014d89d
macos     1:1081547088552:ios:839e138180537d1014d89d
windows   1:1081547088552:web:c50ea4e82f5ecce014d89d

* */