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
    @required String method
  }) async {
    await client.post(url);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  group('post', () {
    test('Should call post with correct url', () async {
      final url = faker.internet.httpUrl();
      final clientSpy = ClientSpy();
      final sut = HttpAdapter(client: clientSpy);

      await sut.request(url: url, method: 'post');

      verify(clientSpy.post(url));
    });
  });
}