import 'dart:async';
import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;

Future<http.Response> fetchJsonData(String url) {
  return http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<http.Response> postJsonData(String url, Map<String, dynamic> data) {
  return http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(data),
  );
}

Stream<String> eventSource(String url) {
  var subscription = SSEClient.subscribeToSSE(
    method: SSERequestType.GET,
    url: url,
    header: {'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'},
  );
  return subscription.transform(
    StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        if (data is Map<String, dynamic>) {
          sink.add(jsonEncode(data));
        } else {
          sink.add(data.data ?? '');
        }
      },
      handleError: (error, stackTrace, sink) {
        sink.close();
      },
    ),
  );
}
