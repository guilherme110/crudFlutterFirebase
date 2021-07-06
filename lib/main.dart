import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Completo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataAniController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  CollectionReference _pessoas = FirebaseFirestore.instance.collection('pessoas');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    if (documentSnapshot != null) {
      action = 'update';
      _nomeController.text = documentSnapshot['nome'];
      _dataAniController.text = documentSnapshot['dataAniversario'];
      _emailController.text = documentSnapshot['email'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  TextField(
                    controller: _dataAniController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(labelText: 'Data de Aniversário'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'E-mail'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(action == 'create' ? 'Create' : 'Update'),
                    onPressed: () async {
                      final String nome = _nomeController.text;
                      final String data = _dataAniController.text;
                      final String email = _emailController.text;

                      if (action == 'create') {
                        await _pessoas.add({
                          "nome": nome,
                          "dataAniversario": data,
                          "email": email
                        });
                      }

                      if (action == 'update') {
                        await _pessoas.doc(documentSnapshot!.id).update({
                          "nome": nome,
                          "dataAniversario": data,
                          "email": email
                        });
                      }

                      _nomeController.text = '';
                      _dataAniController.text = '';
                      _emailController.text = '';

                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
          );
        }
    );
  }

  Future<void> _deleteProduct(String pessoaId) async {
    await _pessoas.doc(pessoaId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pessoa excluida com sucesso!')
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('CRUD Completo'),
      ),
      body: StreamBuilder(
        stream: _pessoas.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['nome']),
                    subtitle: Text(documentSnapshot['email'] + ' - ' + documentSnapshot['dataAniversario']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                              _createOrUpdate(documentSnapshot)
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                _deleteProduct(documentSnapshot.id)
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Icon(Icons.add),
      ),
    );
  }
}
