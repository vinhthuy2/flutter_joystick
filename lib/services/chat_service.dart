import 'dart:convert';

import 'package:flutter_joystick/constants/environment.dart';
import 'package:flutter_joystick/models/message.dart';
import 'package:flutter_joystick/services/http_service.dart';

Future<String> sendDeferredMessage(Message message) {
  String url = '$API_URL/chatDefer';
  return postJsonData(url, message.toJson()).then((res) {
    return res.body.replaceAll('"', '');
  });
}

Stream<String> receiveDeferredMessages(String sessionId) {
  String url = '$API_URL/chatStream?sessionId=$sessionId';
  return eventSource(url);
}

Future<String> sendForRevisory(Message message) {
  String url = '$API_URL/supervisory';
  return postJsonData(url, message.toJson()).then((res) {
    final Map<String, dynamic> jsonBody = json.decode(res.body);
    return jsonBody['content'];
  });
}
