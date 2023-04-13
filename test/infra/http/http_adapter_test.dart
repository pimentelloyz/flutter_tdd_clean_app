import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class HttpAdapter {
  Client client;

  HttpAdapter({ this.client });

  Future<void> request({ 
    @required String url,
    @required String method,
    Map body
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json'
    };
    final jsonBody = body != null ? jsonEncode(body) : null;

    await client.post(url, headers: headers, body: jsonBody);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  HttpAdapter sut;
  ClientSpy clientSpy;
  String url;
  
  setUp( () {
    url = faker.internet.httpUrl();
    clientSpy = ClientSpy();
    sut = HttpAdapter(client: clientSpy);
  });

  group('post', () {
    test('Should call post with correct values', () async {
      await sut.request(url: url, method: 'post', body: { 'any_key': 'any_value' });

      verify(clientSpy.post(
        url, 
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json'
        },
        body: '{"any_key":"any_value"}'
      ));
    });

    test('Should call post without values', () async {
      await sut.request(url: url, method: 'post');

      verify(clientSpy.post(
        url, 
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json'
        }
      ));
    });
  });
}