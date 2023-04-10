import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_app/data/http/http_client.dart';
import 'package:tdd_clean_app/data/usecases/remote_authentication.dart';
import 'package:tdd_clean_app/domain/usecases/usecases.dart';

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