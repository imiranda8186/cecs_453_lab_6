import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}



class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherScreen(),
    );
  }
}

//Custom class used to store the relevant data from the JSOn
//So I don't have to manually parse the data in UI
class Weather {
  final String cityName;
  final String condition;
  final double temp;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.cityName,
    required this.condition,
    required this.temp,
    required this.humidity,
    required this.windSpeed
  });

  factory Weather.fromJson(Map<String, dynamic> json){
    return Weather(
      cityName: json['name'],
      condition: json['weather'][0]['description'],
      temp: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}

class WeatherService {
  Future<Weather> fetchWeather(String city) async {
    final apiKey = dotenv.env['API_KEY'];

    if (apiKey == null || apiKey.isEmpty){
      throw Exception('API key is missing. Check .env');
    }

    final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'
    ));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode==200) {
      final jsonData = jsonDecode(response.body);
      return Weather.fromJson(jsonData);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "Sacramento";
  final WeatherService _weatherService = WeatherService();
  Weather? weatherData;

  Future<void> getWeather() async {
    final data = await _weatherService.fetchWeather(city);

    setState((){
      weatherData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetching Weather Data Example')
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: getWeather,
              child: const Text('Fetch Data')
            ),
            SizedBox(height: 20),
            Column(
              children: [
                if (weatherData == null)
                  Text('No weather data yet')
                else
                Column(
                  children: [
                    Text(weatherData!.cityName),
                    Text(weatherData!.condition),
                    Text('${weatherData!.temp} (Celcius)'),
                    Text('Humidity: ${weatherData!.humidity}%'),
                    Text('Wind Speed: ${weatherData!.windSpeed} m/s')

                  ]
                )
                
              ]
            )
          ]
        )
      )
    );
  }
}
