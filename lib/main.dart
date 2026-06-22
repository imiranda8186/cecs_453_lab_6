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
      debugShowCheckedModeBanner: false,
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
      condition: json['weather'][0]['main'],
      temp: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}

class WeatherService {
  Future<Weather> fetchWeather(String city) async {
    final apiKey = dotenv.env['API_KEY'];
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
  final List<String> cities = ["Sacramento", "Long Beach", "Los Angeles", "San Diego",
                                "Palm Springs", "Carson", "Torrance"];
  IconData weatherIcon = Icons.help;

  Future<void> getWeather() async {
    final data = await _weatherService.fetchWeather(city);
    IconData selectedIcon;

    if (data.condition == 'Clear') {
      selectedIcon = Icons.sunny;
    } else if (data.condition == 'Clouds') {
      selectedIcon = Icons.cloud;
    } else if (data.condition == 'Rain' || data.condition == 'Drizzle' || data.condition == 'Thunderstorm') {
      selectedIcon = Icons.water_drop;
    } else {
      selectedIcon = Icons.help_outline;
    }

    setState((){
      weatherData = data;
      weatherIcon = selectedIcon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Weather Data')
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Select city: "),
                SizedBox(width: 20),
                DropdownButton<String>(
                    value: city,
                    items: cities.map((String choice){
                      return DropdownMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState((){
                        city = newValue!;
                      });
                    },
                  ),
              ]
            ),
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
                    Icon(weatherIcon, size: 180),
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
