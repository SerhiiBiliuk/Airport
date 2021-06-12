import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
  return MaterialApp(
   debugShowCheckedModeBanner: false,
   title: 'Airports',
   theme: ThemeData(
    primarySwatch: Colors.blue,
   ),
   home: Scaffold(
    appBar: AppBar(
     title: Text('Airports'),
    ),
    body: MyHomePage(),
   ),
  );
 }
}

class MyHomePage extends StatefulWidget {
 @override
 _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 Map<String, String> _ara = {
  'UKBB' : 'Киев-Борисполь',
  'UKKK' : 'Киев',
  'UKCC' : 'Донецк',
  'UKCM' : 'Мариуполь',
  'UKCW' : 'Луганск',
  'UKDD' : 'Днепр',
  'UKDE' : 'Запорожье',
  'UKDR' : 'Кривой Рог',
  'UKHH' : 'Харьков-Основа',
  'UKKE' : 'Черкассы',
  'UKKG' : 'Кировоград—Кропивницкий',
  'UKKM' : 'Гостомель',
  'UKLI' : 'Ивано-Франковск',
  'UKLL' : 'Львов',
  'UKLH' : 'Хмельницкий',
  'UKLN' : 'Черновцы',
  'UKLR' : 'Ровно',
  'UKLT' : 'Тернополь',
  'UKLU' : 'Ужгород',
  'UKON' : 'Николаев',
  'UKOO' : 'Одесса',
  'UKFB' : 'Севастополь-Бельбек',
  'UKFF' : 'Симферополь',
  'UKFK' : 'Керчь'
 };

 //https://account.avwx.rest/
 String _token = '8EtFTDEM7_cwAfiCt30d2T3_Fh3v6v2Y4y2Ftq-HtNw';
 String _url = '';
 Future<Station?>? _futureStation;
 Future<Metar?>? _futureMetar;

 double _myLatitude = 0.0;
 double _myLongitude = 0.0;

 String _strMyLocation = '';
 String _strCity = '';

 @override
 void initState() {
  super.initState();
  _funGetLocation();
  _funGetAddress();
 }

 @override
 void dispose() {
  super.dispose();

 }

 Future<Station?> _funGetDataStation(String ICAO) async {
  _url = 'https://avwx.rest/api/station/$ICAO?token=$_token';
  Uri uri = Uri.parse(_url);
  final response = await http.get(uri);
  if (response.statusCode == 200) {
   //десериализация, преобразование формата JSON в объект
   return Station.fromJson(jsonDecode(response.body));
  } else {
   return null;
  }
 }

 Future<Metar?> _funGetDataMetar(String ICAO) async {
  _url = 'https://avwx.rest/api/metar/$ICAO?token=$_token';
  Uri uri = Uri.parse(_url);
  final response = await http.get(uri);
  if (response.statusCode == 200) {
   //десериализация, преобразование формата JSON в объект
   return Metar.fromJson(jsonDecode(response.body));
  } else {
   return null;
  }
 }

 _funGetLocation() async {
  bool serviceEnabled;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if(!serviceEnabled) {
   setState(() {
    //открытие службы местоположения для включения
    Geolocator.openLocationSettings();
    _strMyLocation = 'Location services was are disabled. Now they are enable. Close this app and open it  again';
   });
  } else {
   //LocationAccuracy.best - точность определения местоположения высокая
   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
   setState(() {
    _strMyLocation = 'моя широта : ${position.latitude}\nмоя долгота : ${position.longitude}';
    _myLatitude = position.latitude;
    _myLongitude = position.longitude;
   });
  }
 }

 _funGetAddress() async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  List<Placemark> ara = await placemarkFromCoordinates(position.latitude, position.longitude);
  setState(() {
   _strCity = 'город : ${ara[0].locality}\n';
  });
 }

 double _funLenght(double myLatitude, double myLongitude, double newLatitude, double newLongitude) {
  double res = 0.0;
  res = Geolocator.distanceBetween(myLatitude, myLongitude, newLatitude, newLongitude) / 1000;
  return res;
 }

 @override
 Widget build(BuildContext context) {
  return Stack(
   children: [
    Align(
     alignment: Alignment.topLeft,
     child: ListView.separated(
      padding: const EdgeInsets.all(5.0),
      separatorBuilder: (context, index) => Container(
       height: 1.0,
      ),
      itemCount: _ara.length,
      itemBuilder: (context, index) => Container(
       decoration: BoxDecoration(
        color: Color(0xff9189DF),
        border: Border.all(
         width: 1.0,
         color: Colors.white,
        ),
        borderRadius: BorderRadius.all(
         Radius.circular(15.0)
        ),
       ),
       child: ListTile(
        leading: Icon(
         Icons.airplanemode_active_outlined,
         size: 36.0,
         color: Colors.white70,
        ),
        title: Text(
         '${_ara.values.toList()[index]}',
         style: TextStyle(
          color: Colors.white,
         ),
        ),
        onTap: () {
         setState(() {

          _futureStation =_funGetDataStation(_ara.keys.toList()[index].toString());

          _futureMetar =_funGetDataMetar(_ara.keys.toList()[index].toString());

          Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => _City('${_ara.values.toList()[index]}', _myLatitude, _myLongitude))
          );

         });
        },
       ),
      ),
     ),
    ),
   ],
  );
 }

 Widget _City(String nameCity, double myLatitude, double myLongitude) {
  return Scaffold(
   appBar: AppBar(
    title: Text(
     nameCity
    ),
   ),
   body: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

     FutureBuilder<Station?>(
      future: _futureStation,
      builder: (context, snapshot) {
       if(snapshot.hasData) {
        return Text(
         'город : ${snapshot.data?.city}\nстрана : ${snapshot.data?.country}\nназвание : ${snapshot.data?.name}\nразмер : ${snapshot.data?.type}\nкод IATA : ${snapshot.data?.iata}\nкод ICAO : ${snapshot.data?.icao}\nширота : ${snapshot.data?.latitude}\nдолгота : ${snapshot.data?.longitude}\n',
         style: TextStyle(
          fontSize: 20.0
         ),
        );
       } else if(snapshot.hasError) {
        return Text("${snapshot.error}");
       } else {
        return Center(
         child: CircularProgressIndicator(),
        );
       }
      },
     ),

     FutureBuilder<Metar?>(
      future: _futureMetar,
      builder: (context, snapshot) {
       if(snapshot.hasData) {
        return Text(
         'видимость : ${snapshot.data?.visibility?["spoken"]}\nтемпература : ${snapshot.data?.temperature?["value"]}C\nдата и время : ${snapshot.data?.time?["dt"]}\n',
         style: TextStyle(
          fontSize: 20.0
         ),
        );
       } else if(snapshot.hasError) {
        return Text("${snapshot.error}");
       } else {
        return SizedBox(
         width: 0.0,
         height: 0.0,
        );
       }
      },
     ),

     Text(
      _strMyLocation,
      style: TextStyle(
       fontSize: 20.0
      ),
     ),

     Text(
      _strCity,
      style: TextStyle(
       fontSize: 20.0
      ),
     ),

     FutureBuilder<Station?>(
      future: _futureStation,
      builder: (context, snapshot) {
       if(snapshot.hasData) {
        return Text(
         'от Вас до аэропорта = ${double.parse( (_funLenght(myLatitude, myLongitude, snapshot.data?.latitude ?? 0.0, snapshot.data?.longitude ?? 0.0)).toStringAsFixed(3) )} км',
         style: TextStyle(
          fontSize: 20.0
         ),
        );
       } else if(snapshot.hasError) {
        return Text("${snapshot.error}");
       } else {
        return Center(
         child: SizedBox(
          width: 0.0,
          height: 25.0,
         ),
        );
       }
      },
     ),

    ],
   ),
  );
 }

}

class Station {

 final String? city;
 final String? country;
 final String? name;
 final String? type;
 final String? iata;
 final String? icao;
 final double? latitude;  //широта
 final double? longitude; //долгота

 Station({
  required this.city,
  required this.country,
  required this.name,
  required this.type,
  required this.iata,
  required this.icao,
  required this.latitude,
  required this.longitude
 });

 factory Station.fromJson(Map<String, dynamic> json) => Station(
  city: json['city'] as String?,
  country: json['country'] as String?,
  name: json['name'] as String?,
  type: json['type'] as String?,
  iata: json['iata'] as String?,
  icao: json['icao'] as String?,
  latitude: json['latitude'] as double?,
  longitude: json['longitude'] as double?
 );

 Map<String, dynamic> toJson() => {
  'city': city,
  'country': country,
  'name': name,
  'type': type,
  'iata': iata,
  'icao': icao,
  'latitude': latitude,
  'longitude': longitude
 };

}

class Metar {

 final Map<String, dynamic>? visibility;
 final Map<String, dynamic>? temperature;
 final Map<String, dynamic>? time;

 Metar({
  required this.visibility,
  required this.temperature,
  required this.time
 });

 factory Metar.fromJson(Map<String, dynamic> json) => Metar(
  visibility: json['visibility'] as Map<String, dynamic>?,
  temperature: json['temperature'] as Map<String, dynamic>?,
  time: json['time'] as Map<String, dynamic>?
 );

 Map<String, dynamic> toJson() => {
  'visibility': visibility,
  'temperature': temperature,
  'windSpeed': time
 };

}