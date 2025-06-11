import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // flutterfire configure tarafından oluşturulan dosya
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Arka planda gelen bildirimleri işlemek için (uygulama kapalıyken veya arka plandayken)
// Bu fonksiyon main() dışında, en üst seviyede olmalı
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Önemli: Firebase'i burada da başlatmanız gerekebilir, özellikle uygulama tamamen kapalıyken
  // bildirim geldiğinde çalışacaksa.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
  // Burada gelen mesajı işleyebilirsiniz (örneğin yerel bir bildirim gösterebilirsiniz)
  // Veya veriyi saklayıp uygulama açıldığında kullanıcıya gösterebilirsiniz.
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Kanal ID (unique olmalı)
    'High Importance Notifications', // Kanal adı (kullanıcıya görünür)
    description: 'This channel is used for important notifications.', // Kanal açıklaması
    importance: Importance.high, // Bildirim önceliği (düşük, normal, yüksek, kritik vs.)
  );

  // Kanalı Android platformuna bildiriyoruz
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}


Future<void> main() async {

        WidgetsFlutterBinding.ensureInitialized();
      // Firebase'i başlat
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

        await setupNotificationChannel();

        // Arka plan mesaj işleyicisini ayarla
            FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');

          print("123");
          RemoteNotification? notification = message.notification;
          print("456");

          //print("notification123:"+notification);
        //  AndroidNotification? android = message.notification?.android;
         // print("notification.body"+notification.body);
          NotificationDetails notificationDetails = const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // Yukarıda oluşturduğun kanal ID'si
              'High Importance Notifications', // Kanal adı
              channelDescription: 'This channel is used for important notifications.', // Kanal açıklaması
              importance: Importance.high,
              priority: Priority.high,
              ticker: 'ticker',
              icon: '@mipmap/ic_launcher',
            ),
          );

          if (notification != null
          //notification.body  != null //&& android != null
          ) {
            print("if içinde");
            // Veya sadece notification != null kontrolü
            // flutter_local_notifications ile yerel bildirim göster
            flutterLocalNotificationsPlugin.show(
              1, // Bildirim ID'si (unique olmalı)
              'Veli Bildirim', // Bildirim başlığı
              notification.body,//'Bildirim mesajı içeriği', // Bildirim içeriği
              notificationDetails, // Az önce oluşturduğun NotificationDetails
              payload: 'optional payload', // Bildirim tıklandığında dönecek data (opsiyonel)
            );
            /*flutterLocalNotificationsPlugin.show(
              251414,//notification.hashCode,
              "mesaj var haniiim",//notification.title,
              message.data["body"],//notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'your_channel_id', // Kendi kanal ID'nizi oluşturun
                  'your_channel_name', // Kendi kanal adınızı oluşturun
                  channelDescription: 'your_channel_description',
                  icon: '@mipmap/ic_launcher',//android.smallIcon, // Veya kendi ikonunuz: '@mipmap/ic_launcher'
                  // Diğer ayarlar...
                ),
              ),
              payload: message.data['screen'], // veya istediğiniz bir veri
            );*/
            print("if bitti");
          }
        });

            runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okul Güvenlik Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}