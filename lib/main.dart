import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}



class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PostList(),
    );
  }
}

class PostList extends StatefulWidget{
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  List<dynamic> _postData = [];

  Future<void> fetchData() async {
    final url = Uri.parse(
          'https://jsonplaceholder.typicode.com/posts'); 
    final response = await http.get(url);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _postData = jsonDecode(response.body);
      });
    }
      else {
        throw Exception('Failed to load data');
      }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Data Example')
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: fetchData, child: Text('Fetch Data')
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _postData.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(_postData[index]['title'])
                  );
                },
              )
            )
          ],
        )
      )
    );
  }
}
