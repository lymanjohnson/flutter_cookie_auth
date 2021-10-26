import 'dart:async';
import 'package:http/http.dart' as http;

final String _localBaseURL = "http://localhost:8000/";
final String _gcpBaseURL =
    "https://compatica-web-ma-1549541408356.ue.r.appspot.com/";

final _baseURL = _localBaseURL;
// final _baseURL = _gcpBaseURL;
final String _loginURL = _baseURL + 'api_login/';

Future<http.Response> authenticateUser(String username, String password) async {
  final http.Response response = await http.post(
    Uri.parse(_loginURL),
    body: {'username': username, 'password': password},
  );
  print(response.body);
  print(response.statusCode);
  return response;
  // http.Response response = await http.post(
  //   Uri.parse(_loginURL),
  //   body: {'username': username, 'password': password},
  // );
  // print(response.body);
  // return response;
}
