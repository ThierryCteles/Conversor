import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

//API do hg finnace que fornece os dados para o app
const Request =
    "https://api.hgbrasil.com/finance/stock_price?key=fc907c79&symbol=bidi4";

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.white,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[900])),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[900])),
          hintStyle: TextStyle(color: Colors.white),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double Dollar;
  double Euro;

// Fazendo a conversão das Moedas
  void _realChanged(String text) {
    double real = double.parse(text);
    dollarController.text = (real / Dollar).toStringAsFixed(2);
    euroController.text = (real / Euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    double dollar = double.parse(text);
    realController.text = (dollar * this.Dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.Dollar / Euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.Euro).toStringAsFixed(2);
    dollarController.text = (euro * this.Euro / Dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "\$ Conversor \$",
          style: TextStyle(color: Colors.blue[900]),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "ERRO ao Carregar Dados =(",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              } else {
                Dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                Euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 155.00, color: Colors.blue[900]),
                      buildTextFild(
                          "Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextFild(
                          "Dollar", "US\$", dollarController, _dollarChanged),
                      Divider(),
                      buildTextFild("Euro", "€", euroController, _euroChanged),
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

//função esperando resposta do servidor
Future<Map> getData() async {
  http.Response response = await http.get(Request);
  return jsonDecode(response.body);
}

// textfield padrão, só pra dar um otimizada
buildTextFild(
    String label, String prefix, TextEditingController money, Function bucks) {
  return TextField(
    keyboardType: TextInputType.number,
    controller: money,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(
      color: Colors.white,
      fontSize: 25,
    ),
    onChanged: bucks,
  );
}
