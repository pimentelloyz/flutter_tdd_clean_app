import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({ required this.httpClient, required this.url });

  Future<void>? auth() async {
    return await httpClient.request(url: url, method: 'post');
  }
}

abstract class HttpClient {
  Future<void>? request({ 
    required String url,
    required String method
  });
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  test("Should call httpClient with correct url", () async {
    final httpClientSpy = HttpClientSpy();
    final url = faker.internet.httpUrl();
    final sut = RemoteAuthentication(httpClient: httpClientSpy, url: url);

    await sut.auth();

    verify(httpClientSpy.request(
      url: url,
      method: 'post'
    ));
  });
}