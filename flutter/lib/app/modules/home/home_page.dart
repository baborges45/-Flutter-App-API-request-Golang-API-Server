import 'package:flutter/material.dart';
import 'package:flutter_api_golang/app/models/productModel.dart';
import 'package:flutter_api_golang/app/modules/home/home_store.dart';
//import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, this.title = "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ModularState<HomePage, HomeStore> {
  double fetchCountPercentage = 20.0; // default 10%

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.blueGrey,
            body: SizedBox.expand(
                child: Stack(
              children: [
                FutureBuilder<List<Product>>(
                  future: fetchFromServer(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("${snapshot.error}",
                            style: TextStyle(color: Colors.redAccent)),
                      );
                    }

                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                              child: ListTile(
                            title: Text(snapshot.data[index].name),
                            subtitle: Text(
                                "Count: ${snapshot.data[index].count} \t Price:${snapshot.data[index].price}"),
                          ));
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
                Positioned(
                    bottom: 5,
                    right: 5,
                    child: Slider(
                      value: fetchCountPercentage,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: fetchCountPercentage.toString(),
                      onChanged: (double value) {
                        setState(() {
                          fetchCountPercentage = value;
                        });
                      },
                    ))
              ],
            ))));
  }

  Future<List<Product>> fetchFromServer() async {
    var url = "http://192.168.2.28:5500/products/$fetchCountPercentage";
    var response = await http.get(Uri.parse(url));

    List<Product> productList = [];
    if (response.statusCode == 200) {
      var productMap = convert.jsonDecode(response.body);
      for (final item in productMap) {
        productList.add(Product.fromJson(item));
      }
    }

    return productList;
  }
}
