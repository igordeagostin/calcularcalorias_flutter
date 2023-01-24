import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

List _items = [];

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  List<String> names = <String>['Aby', 'Aish'];
  TextEditingController nameController = TextEditingController();

  void addItemToList(value) {
    setState(() {
      var alimentos = _items
          .where((element) => element["description"]
              .toString()
              .toLowerCase()
              .contains(value.toString().toLowerCase()))
          .take(15)
          .toList();
      names.clear();

      for (var element in alimentos) {
        names.insert(0, element["description"]);
      }
    });
  }

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/listaDeAlimentos.json');
    final data = await json.decode(response);
    setState(() {
      _items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    readJson();

    return Scaffold(
        appBar: AppBar(
          title: Text('Calcula calorias'),
        ),
        body: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: nameController,
              // ignore: prefer_const_constructors
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Nome do alimento',
              ),
              onChanged: (value) {
                addItemToList(value);
              },
            ),
          ),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: names.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 60,
                      margin: EdgeInsets.all(2),
                      color: Colors.blue[400],
                      child: Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            showAlertDialog(context, names[index]);
                          },
                          child: Text(
                            '${names[index]}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }))
        ]));
  }
}

showAlertDialog(BuildContext context, nomeAlimento) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("Fechar"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  var alimento = _items
      .where((element) =>
          element["description"].toString().toLowerCase() ==
          nomeAlimento.toString().toLowerCase())
      .first;

  AlertDialog alert = AlertDialog(
    title: Text(
      alimento["description"],
      textAlign: TextAlign.center,
      style: TextStyle(
        decorationStyle: TextDecorationStyle.solid,
      ),
    ),
    content: Container(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ignore: prefer_interpolation_to_compose_strings
          Text('Porção de ' +
              alimento["base_qty"].toString() +
              alimento["base_unit"].toString() +
              " tem " +
              alimento["attributes"]["energy"]["kcal"]
                  .toString()
                  .split('.')[0] +
              " calorias"),
          Text('Calcule você:'),
          TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'peso em gramas',
              )),
        ],
      ),
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
