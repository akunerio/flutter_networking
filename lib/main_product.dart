import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Product.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Layout 1",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const myHomePage(),
    );
  }
}

class myHomePage extends StatefulWidget {
  const myHomePage({Key? key}) : super(key: key);

  @override
  State<myHomePage> createState() => _myHomePageState();
}

class _myHomePageState extends State<myHomePage> {

  Future<List> getData() async {
    List products = [];

    try {
      final response = await http.get(
        Uri.parse('http://10.62.0.3:8000/api/products'),
        headers: {
          HttpHeaders.authorizationHeader : 'Bearer 3|xeEDlYrptPX5Ci3zmIYrUvIN1cbIX4NhvLGqRWzJba986a6f',
        },
      );

      var data = jsonDecode(response.body);
      var parsed = data['list'].cast<Map<String, dynamic>>();
      products = parsed.map<Products>((json) => Products.fromJson(json)).toList();

    } catch (err) {
      print (err);
    }

    return products;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fetch Data Example")),
      body: FutureBuilder(
        future: getData(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  subtitle: Text(snapshot.data![index].price.toString()),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}