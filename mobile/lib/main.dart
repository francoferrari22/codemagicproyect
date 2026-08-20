import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home.dart';
import 'screens/settings.dart';

final api = ApiClient();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await api.load();
  runApp(const FerrariPOSApp());
}

class FerrariPOSApp extends StatelessWidget {
  const FerrariPOSApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Ferrari's POS Mobile",
    theme: ThemeData.dark(useMaterial3: true),
    home: api.baseUrl.isEmpty ? const SettingsScreen() : const HomeScreen(),
  );
}

class ApiClient {
  String baseUrl = '';
  String token = '';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    baseUrl = p.getString('api_url') ?? '';
    token = p.getString('token') ?? '';
  }
  Future<void> save(String url) async {
    final p = await SharedPreferences.getInstance();
    baseUrl = url.trim().replaceAll(RegExp(r'/$'), '');
    await p.setString('api_url', baseUrl);
  }
  Future<void> setToken(String value) async {
    token = value;
    final p = await SharedPreferences.getInstance();
    await p.setString('token', value);
  }
  Future<dynamic> get(String path) async {
    if (baseUrl.isEmpty) throw Exception('Configure la URL de la API primero.');
    final r = await http.get(Uri.parse('$baseUrl$path'), headers: _headers());
    return _decode(r);
  }
  Future<dynamic> post(String path, Map<String,dynamic> body) async {
    if (baseUrl.isEmpty) throw Exception('Configure la URL de la API primero.');
    final r = await http.post(Uri.parse('$baseUrl$path'), headers: {..._headers(), 'Content-Type':'application/json'}, body: jsonEncode(body));
    return _decode(r);
  }
  Map<String,String> _headers() => token.isEmpty ? {} : {'Authorization':'Bearer $token'};
  dynamic _decode(http.Response r) {
    dynamic body;
    try { body = jsonDecode(r.body); } catch (_) { body = r.body; }
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception('${r.statusCode}: ${body is Map ? (body['message'] ?? body['error'] ?? body) : body}');
    return body;
  }
}
