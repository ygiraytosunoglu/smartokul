import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;


// Dropdown için seçili değeri tutacak değişken
String? selectedTarget; // Başlangıçta null olabilir veya varsayılan bir değer
// Dropdown seçeneklerini içeren Map (örnek veri)
final Map<String, String> targetOptions = {
  'class_5a': 'Ece Tufan',
  'class_6b': 'Mehmet Öztürk',
  'teachers': 'Ali Gel',
  'staff': 'Semih Berber',
};

// "Hepsi" seçeneğinin anahtarı (Map'teki anahtarlarla çakışmamalı)
final String allOptionKey = 'all_users';
final String allOptionValue = 'Hepsi';

// Dropdown için öğeleri oluşturacak bir liste
List<DropdownMenuItem<String>> dropdownMenuItems = [];



class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({Key? key}) : super(key: key);

  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}


class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Dropdown öğelerini Map'ten ve "Hepsi" seçeneğinden oluştur
   // String sonuc = await _ogrencileriCek();

    dropdownMenuItems = targetOptions.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(entry.value),
      );
    }).toList();

    // "Hepsi" seçeneğini en başa ekle
    dropdownMenuItems.insert(
      0,
      DropdownMenuItem<String>(
        value: allOptionKey,
        child: Text(allOptionValue),
      ),
    );

    // İsteğe bağlı: Başlangıçta "Hepsi" seçili olsun
    // _selectedTarget = _allOptionKey;
  }

 /* Future<String> _ogrencileriCek() async {
    final String baseUrl =
        "http://localhost:5000/api/teacher/studentsOfTeacher?schoolId=${globalSchoolId}&tckn=${_tcNoController.text}";
    // "http://api.exchangeratesapi.io/v1/latest?access_key=";
    print("ogrencileri cek baseUrl:$baseUrl");
    Uri uri = Uri.parse(baseUrl);
    http.Response response = await http.get(uri);
    print("ogrenci response:$response");
    print("ogrenci response.body:${response.body}");

   /* globalErrMsg = response.body.toString() ?? "";
    if (globalStatusCode != "200") {
      return Future.delayed(Duration(seconds: 2), () => globalErrMsg);
    }*/
    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    //Map<String, dynamic> rates = parsedResponse["rates"];
    print('MAP OGRENCI BILGILER $parsedResponse');


    targetOptions = parsedResponse["Students"];

    return Future.delayed(Duration(seconds: 2), () => "Öğrenci bilgileri indirildi!");

  }*/
  Future<void> _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _apiService.sendNotification(
          _titleController.text,
          _messageController.text,
        );
        if (!mounted) return;

        // Başarılı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirim başarıyla gönderildi')),
        );

        // Form alanlarını temizle
        _titleController.clear();
        _messageController.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bildirim gönderilemedi: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Gönder'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Yeni Bildirim',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // ----- YENİ DROPDOWN -----
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Hedef Kitle',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people_alt_outlined), // Uygun bir ikon seçin
                        ),
                        value: selectedTarget, // Seçili değeri bağla
                        hint: const Text('Kime göndermek istersiniz?'), // Seçili bir şey yokken gösterilecek metin
                        isExpanded: true, // Dropdown'ın genişlemesini sağlar
                        items: dropdownMenuItems, // Oluşturduğumuz öğeler
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTarget = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Hedef kitle seçimi gerekli';
                          }
                          return null;
                        },
                      ),
                      // ----- DROPDOWN SONU -----
                      const SizedBox(height: 16), // Dropdown ve başlık arası boşluk
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Bildirim Başlığı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Başlık gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Bildirim Mesajı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mesaj gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendNotification,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'Bildirimi Gönder',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
} 