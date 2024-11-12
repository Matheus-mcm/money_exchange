import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const String uri = "https://api.hgbrasil.com/finance?key=7e9969cf";
void main() async {
  runApp(const MyApp());
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(uri));
  return json.decode(response.body)["results"]["currencies"];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Exchange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          )),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realCtrl = TextEditingController();
  final dolarCtrl = TextEditingController();
  final euroCtrl = TextEditingController();

  double dolar = 0.00;
  double euro = 0.00;

  void _clearAll() {
    realCtrl.text = "";
    dolarCtrl.text = "";
    euroCtrl.text = "";
  }

  void _realChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarCtrl.text = (real / dolar).toStringAsFixed(2);
    euroCtrl.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realCtrl.text = (dolar * dolar).toStringAsFixed(2);
    euroCtrl.text = ((dolar * dolar) / euro).toStringAsFixed(2);
  }

  void _euroChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realCtrl.text = (euro / euro).toStringAsFixed(2);
    dolarCtrl.text = ((euro * euro) / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Conversor de Moedas",
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar dados. Reinicie o aplicativo",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data?["USD"]["buy"];
                euro = snapshot.data?["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextFiel(
                        "Reais (R\$)",
                        "R\$",
                        realCtrl,
                        _realChange,
                      ),
                      const Divider(),
                      buildTextFiel(
                        "Dolar Americano (US\$)",
                        "US\$",
                        dolarCtrl,
                        _dolarChange,
                      ),
                      const Divider(),
                      buildTextFiel(
                        "Euro",
                        "EUR",
                        euroCtrl,
                        _euroChange,
                      )
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextFiel(
  String label,
  String prefix,
  TextEditingController ctrl,
  Function(String) fn,
) {
  return TextField(
    controller: ctrl,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.amber,
      ),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: fn,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
