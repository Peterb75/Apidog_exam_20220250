import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Dog {
  final String breedName;
  final String bredFor;
  final String breedGroup;
  final String lifeSpan;
  final String temperament;
  final String origin;
  String imageUrl; // Remove the 'final' modifier here

  Dog({
    required this.breedName,
    required this.bredFor,
    required this.breedGroup,
    required this.lifeSpan,
    required this.temperament,
    required this.origin,
    required this.imageUrl,
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      breedName: json['name'],
      bredFor: json['bred_for'],
      breedGroup: json['breed_group'],
      lifeSpan: json['life_span'] ,
      temperament: json['temperament'],
      origin: json['origin'],
      imageUrl: '', 
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dog Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Infodog(),
    );
  }
}

class Infodog extends StatefulWidget {
  @override
  _InfodogState createState() => _InfodogState();
}

class _InfodogState extends State<Infodog> {
  late Future<Dog> futureDog;
  late String namedog;
  late String imageId;

  @override
  void initState() {
    super.initState();
    namedog = 'Affenpinscher'; 
    imageId = '1';
    futureDog = fetchDog();
  }

  Future<Dog> fetchDog() async {
    const apiKey = 'live_vRJ9IYGctm8q5epTUGSj4ry8uNDcwb2UD24sjCAvYjmscyJJaKNjWE3llmk0a6pn';
    
    final breedResponse = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$namedog'),
      headers: {'x-api-key': apiKey},
    );

    if (breedResponse.statusCode == 200) {
      final List<dynamic> breedDataList = json.decode(breedResponse.body);
      if (breedDataList.isNotEmpty) {
        final Map<String, dynamic> breedData = breedDataList[0];
        final imageUrl = await fetchDogImageUrl(apiKey);
        return Dog.fromJson(breedData)..imageUrl = imageUrl;
      } else {
        throw Exception('Breed not found');
      }
    } else {
      throw Exception('Failed to fetch dog data');
    }
  }

  Future<String> fetchDogImageUrl(String apiKey) async {
    final imageResponse = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/images/search?breed_id=$imageId'),
      headers: {'x-api-key': apiKey},
    );

    if (imageResponse.statusCode == 200) {
      final List<dynamic> imageDataList = json.decode(imageResponse.body);
      if (imageDataList.isNotEmpty) {
        final Map<String, dynamic> imageData = imageDataList[0];
        return imageData['url'];
      } else {
        throw Exception('No image data found');
      }
    } else {
      throw Exception('Failed to fetch dog image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Info'),
      ),
      body: Center(
        child: FutureBuilder<Dog>(
          future: futureDog,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    snapshot.data!.imageUrl,
                    width: 200,
                    height: 200,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Breed Name: ${snapshot.data!.breedName}'),
                  Text('Bred For: ${snapshot.data!.bredFor}'),
                  Text('Breed Group: ${snapshot.data!.breedGroup}'),
                  Text('Life Span: ${snapshot.data!.lifeSpan}'),
                  Text('Temperament: ${snapshot.data!.temperament}'),
                  Text('Origin: ${snapshot.data!.origin}'),
                  SizedBox(height: 20),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
