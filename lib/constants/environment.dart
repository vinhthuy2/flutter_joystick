import 'package:flutter_dotenv/flutter_dotenv.dart';

final String API_URL = dotenv.env['API_URL'] ?? 'http://localhost:8000/api';
