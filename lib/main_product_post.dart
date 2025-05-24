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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const myHomePage(),
    );
  }
}

class myHomePage extends StatefulWidget {
  const myHomePage({Key? key}) : super(key: key);

  @override
  State<myHomePage> createState() => _myHomePageState();
}


Future<List<Products>> fetchProduct() async {

    final response = await http.get(
      Uri.parse('http://10.62.0.3:8000/api/products'),
      headers: {
        HttpHeaders.authorizationHeader:
        'Bearer 3|xeEDlYrptPX5Ci3zmIYrUvIN1cbIX4NhvLGqRWzJba986a6f',
      },
    );

    if(response.statusCode  == 200) {
      var data = jsonDecode(response.body);
      var parsed = data['list'].cast<Map<String, dynamic>>();
      return parsed.map<Products>((json) => Products.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

Future<Map<String, dynamic>> addProduct(_name, _price) async {
  final res = await http.post(
    Uri.parse('http://10.62.0.3:8000/api/products'),
    headers: {
      HttpHeaders.authorizationHeader:
      'Bearer 3|xeEDlYrptPX5Ci3zmIYrUvIN1cbIX4NhvLGqRWzJba986a6f',
    },
    body: {'name': _name, 'price': _price},
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {}
  throw Exception('Failed');
}

class _myHomePageState extends State<myHomePage> {

  var nameInput = TextEditingController();
  var priceInput = TextEditingController();
  late Future<List<Products>> products;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    products = fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fetch Data Example")),
      body: FutureBuilder(
        future: products,
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text("Add Product"),
                children: [
                  Column(
                    children: [
                      TextFormField(
                        controller: nameInput,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          hintText: "Enter Product Name",
                        ),
                      ),
                      TextFormField(
                        controller: priceInput,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          hintText: "Enter Product Price",
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          var res = await addProduct(nameInput.text, priceInput.text);

                          if(res['error']) {
                            //error
                          } else {
                            setState(() {
                              products = fetchProduct();
                            });
                          }
                          Navigator.pop(context);
                          var snackBar = SnackBar(
                            content: Text(res['message']),

                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          nameInput.clear();
                          priceInput.clear();

                        },
                        child: const Text("Add Product"),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}