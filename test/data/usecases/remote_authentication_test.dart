import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_app/domain/usecases/usecases.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({ required this.httpClient, required this.url });

  Future<void>? auth({ required AuthenticationParams params }) async {
    final body = { 'email': params.email, 'password': params.password };
    return await httpClient.request(url: url, method: 'post', body: body);
  }
}

abstract class HttpClient {
  Future<void>? request({ 
    required String url,
    required String method,
    Map body
  });
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClientSpy;
  late String url;

  setUp(() {
    httpClientSpy = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClientSpy, url: url);
  });

  test("Should call httpClient with correct values", () async {
    final params = AuthenticationParams(email: faker.internet.email(), password: faker.internet.password());
    await sut.auth(params: params);

    verify(httpClientSpy.request(
      url: url,
      method: 'post',
      body: {'email': params.email, 'password': params.password}
    ));
  });
}