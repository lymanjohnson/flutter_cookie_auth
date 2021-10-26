import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<AuthenticatedUser> authenticateUser(
    String username, String password) async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/api_login/'),
    // headers: <String, String>{
    //   'Content-Type': 'application/json; charset=UTF-8',
    // },
    body: {'username': username, 'password': password},
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return AuthenticatedUser.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create authenticated user object.');
  }
}

class Album {
  final int id;
  final String title;

  Album({required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
    );
  }
}

class Employee {
  final int id;
  final int company;
  final String first_name;
  final String last_name;

  Employee({
    required this.id,
    required this.company,
    required this.first_name,
    required this.last_name,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      company: json['company'],
      first_name: json['first_name'],
      last_name: json['last_name'],
    );
  }
}

class AuthenticatedUser {
  final String session_id;
  final Employee employee;

  AuthenticatedUser({
    required this.session_id,
    required this.employee,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      session_id: json['session_id'],
      employee: Employee.fromJson(json['employee']),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'psmith');
  final TextEditingController _passwordController =
      TextEditingController(text: '123456');
  Future<AuthenticatedUser>? _futureAuthenticatedUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Data Example'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureAuthenticatedUser == null)
              ? buildColumn()
              : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          // username
          controller: _usernameController,

          decoration: const InputDecoration(hintText: 'Username'),
        ),
        TextField(
          // password
          controller: _passwordController,
          decoration: const InputDecoration(hintText: 'Password'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureAuthenticatedUser = authenticateUser(
                  _usernameController.text, _passwordController.text);
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<AuthenticatedUser> buildFutureBuilder() {
    return FutureBuilder<AuthenticatedUser>(
      future: _futureAuthenticatedUser,
      builder: (context, snapshot) {
        print(context);
        print(snapshot);
        if (snapshot.hasData) {
          return Text(snapshot.data!.session_id);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
