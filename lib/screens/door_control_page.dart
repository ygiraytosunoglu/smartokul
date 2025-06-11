import 'package:flutter/material.dart';
import 'package:smart_okul_mobile/constants.dart';
import 'package:http/http.dart' as http;
import 'package:smart_okul_mobile/screens/login_screen.dart';

class DoorControlPage extends StatelessWidget {
  final bool hasGateAccess;
  final bool hasParkingAccess;

  const DoorControlPage({
    Key? key,
    required this.hasGateAccess,
    required this.hasParkingAccess,
  }) : super(key: key);

  void anaKapiyiAc(BuildContext context){
    Future<String> cevap = _onGatePressed(context);
    _onGatePressed(context).then((cevap){
      if (cevap =="200" )   {
        _pencereAc(context,"Ana Kapı açılma isteği gönderdildi");
      } else {
        _pencereAc(context, "İstek gönderilemedi ");
      }
    });
  }


  void otoparkKapisiniAc(BuildContext context){
    Future<String> cevap = _onParkingPressed(context);
    _onParkingPressed(context).then((cevap){
      if (cevap =="200" )   {
        _pencereAc(context,"Otopark Kapısı açılma isteği gönderdildi");
      } else {
        _pencereAc(context, "Otopark için İstek gönderilemedi ");
      }
    });
  }

  Future _pencereAc(BuildContext context, String mesaj) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(title: Text(mesaj));
      },
    );
  }

  Future<String> _onGatePressed(BuildContext context) async{
    // TODO: API çağrısı buraya eklenecek
    final String baseUrl =
         "http://212.154.74.47:5000/api/school/open-door/"+globalSchoolId;
    print("baseUrl:$baseUrl");
    Uri uri = Uri.parse(baseUrl );
    http.Response response = await http.get(uri);
    print("gate status:"+response.statusCode.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ana Kapı Kontrol çağrıldı')),
    );
    return Future.delayed(Duration(seconds: 2), () => response.statusCode.toString()??"0");
  }

  Future<String>  _onParkingPressed(BuildContext context) async{
    // TODO: API çağrısı buraya eklenecek
    final String baseUrl =
       "http://212.154.74.47:5000/api/school/open-park/"+globalSchoolId;
    print("baseUrl:$baseUrl");
    Uri uri = Uri.parse(baseUrl );
    http.Response response = await http.get(uri);
    print("otopark status:"+response.statusCode.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Otopark Kontrol çağrıldı')),
    );
    return Future.delayed(Duration(seconds: 2), () => response.statusCode.toString()??"0");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Kapı Kontrol Paneli',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
       ),
        //backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                context: context,
                icon: Icons.door_front_door,
                label: 'Ana Kapı Kontrol',
                enabled: hasGateAccess,
                onPressed: () => anaKapiyiAc(context),
              ),
              const SizedBox(height: 32),
              _buildControlButton(
                context: context,
                icon: Icons.local_parking,
                label: 'Otopark Kontrol',
                enabled: hasParkingAccess,
                onPressed: () => otoparkKapisiniAc(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 64),
          /*shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),*/
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,

        ),
        icon: Icon(icon, size: 32, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}