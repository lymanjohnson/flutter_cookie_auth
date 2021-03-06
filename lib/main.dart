import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  final JsonDecoder _decoder = const JsonDecoder();
  final JsonEncoder _encoder = const JsonEncoder();

  Map<String, String> headers = {};
  Map<String, String> cookies = {};

  void _updateCookie(http.Response response) {
    String? allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['cookie'] = _generateCookieHeader();
    }
  }

  void _setCookie(String? rawCookie) {
    if (rawCookie != null) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.isNotEmpty) cookie += ";";
      cookie += key + "=" + cookies[key]!;
    }

    return cookie;
  }

  Future<dynamic> get(String url) {
    return http
        .get(Uri.parse(url), headers: headers)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {body, encoding}) {
    return http
        .post(Uri.parse(url), body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> put(String url, {body, encoding}) {
    return http
        .put(Uri.parse(url), body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }
}

Future<AuthenticatedUser> authenticateUser(
    String username, String password) async {
  final res = await NetworkService().post(
    'http://localhost:8000/api_login/',
    body: {'username': username, 'password': password},
  );
  return AuthenticatedUser.fromJson(res);
}

Future<IncidentSet> fetchIncidents() async {
  final res = await NetworkService().get(
    'http://localhost:8000/api/v1/incident/',
  );
  return IncidentSet.fromJson(res);
}

Future<IncidentSet> loginAndFetchIncidents(
    String username, String password) async {
  final ns = NetworkService();
  final r1 = await ns.post(
    'http://localhost:8000/api_login/',
    body: {'username': username, 'password': password},
  );
  // final user = AuthenticatedUser.fromJson(r1);
  final r2 = await ns.get(
    'http://localhost:8000/api/v1/incident/',
  );
  return IncidentSet.fromJson(r2);
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

class Incident {
  final int id; //": 425,
  final int number; //": 1,
  final int type; //": 2,
  final int employee; //": 4714,
  final int createdBy; //": 4719,
  final DateTime modified; //": "2021-09-09T18:37:47.673233Z",
  final DateTime created; //": "2018-05-07T21:52:17.754005Z",
  final DateTime time; //": "2018-05-07T21:51:26Z",
  final String status; //": "active",
  final String? description; //": null

  Incident({
    required this.id,
    required this.number,
    required this.type,
    required this.employee,
    required this.createdBy,
    required this.modified,
    required this.created,
    required this.time,
    required this.status,
    this.description,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      number: json['number'],
      type: json['type'],
      employee: json['employee'],
      createdBy: json['createdBy'],
      modified: DateTime.parse(json['modified']),
      created: DateTime.parse(json['created']),
      time: DateTime.parse(json['time']),
      status: json['status'],
      description: json['description'],
    );
  }
}

class IncidentSet {
  final List<Incident> incidents;

  IncidentSet({
    required this.incidents,
  });

  factory IncidentSet.fromJson(Map<String, dynamic> jsonArray) {
    List<Incident> incidents = [];
    jsonArray.forEach((key, val) {
      Incident incident = Incident.fromJson(jsonDecode(key));
      incidents.add(incident);
    });

    return IncidentSet(
      incidents: incidents,
    );
  }
// List<dynamic> incidentArray = json.decode(jsonArray)
// Map<String, dynamic> myMap = json.decode(jsonStr);
// List<dynamic> entitlements = myMap["Dependents"][0]["Entitlements"];
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
  Future<IncidentSet>? _futureIncidentSet;

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
        body: Column(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   padding: const EdgeInsets.all(8.0),
            //   child: (_futureAuthenticatedUser == null)
            //       ? buildColumn()
            //       : buildFutureAuthenticatedUser(),
            // ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: (_futureIncidentSet == null)
                  ? buildColumn()
                  : buildFutureIncidentSet(),
            ),
          ],
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
              _futureIncidentSet = loginAndFetchIncidents(
                  _usernameController.text, _passwordController.text);
              // _futureAuthenticatedUser = authenticateUser(
              //     _usernameController.text, _passwordController.text);
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<AuthenticatedUser> buildFutureAuthenticatedUser() {
    return FutureBuilder<AuthenticatedUser>(
      future: _futureAuthenticatedUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text("User Employee ID: " +
              snapshot.data!.employee.id.toString() +
              "\nSession: " +
              snapshot.data!.session_id);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  FutureBuilder<IncidentSet> buildFutureIncidentSet() {
    return FutureBuilder<IncidentSet>(
      future: _futureIncidentSet,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.toString());
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
