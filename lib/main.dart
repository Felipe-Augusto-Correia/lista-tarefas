import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController toDoController = TextEditingController();

  // Retorna o arquivo diretorio que vou usar para salvar nossas tarefas(arquivo Json)
  Future<File> _getFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/tarefas.json");
  }

  // Criei minha lista
  List _toDoList = [];

  // Ler os dados ao iniciar o App
  @override
  void initState() {
    super.initState();

    _readData().then((value) => (data) {
          setState(() {
            _toDoList = jsonDecode(data);
          });
        });
  }

  // adicionar dados na lista
  void _addToDo() async {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = toDoController.text;
      toDoController.text = "";
      newToDo["ok"] = false;
      // Aqui estamos colocando um Map dentro de uma List
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  //Salvar os dados
  Future<File> _saveData() async {
    // Transforma nossa lista em um Json
    String data = jsonEncode(_toDoList);
    //Pegamos nosso arquivo do diretorio
    final file = await _getFile();
    // Vamos escrever nossas tarefas como texto
    // Passando minha lista para o diretorio
    file.writeAsString(data);
  }

  // Ler os dados
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Lista de Tarefas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: toDoController,
                    decoration: InputDecoration(
                      labelText: 'Nova Tarefa',
                      labelStyle: TextStyle(
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.indigo,
                      textStyle: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: _addToDo,
                  child: Text('ADD'),
                ),
              ],
            ),
          ),
          Expanded(
            // O builder vai criando a lista a medida que é chamada
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _toDoList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_toDoList[index]['title']),
                    value: _toDoList[index]['ok'],
                    secondary: CircleAvatar(
                      child: Icon(
                          _toDoList[index]['ok'] ? Icons.check : Icons.error),
                    ),
                    onChanged: (c) {
                      setState(() {
                        _toDoList[index]['ok'] = c;
                        _saveData();
                      });
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
