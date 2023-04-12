import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_app/data/http/http.dart';
import 'package:tdd_clean_app/data/usecases/usecases.dart';
import 'package:tdd_clean_app/domain/helpers/helpers.dart';
import 'package:tdd_clean_app/domain/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClientSpy;
  String url;
  AuthenticationParams params;

  setUp(() {
    httpClientSpy = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClientSpy, url: url);
    params = AuthenticationParams(email: faker.internet.email(), password: faker.internet.password());
  });

  test("Should call HttpClient with correct values", () async {
    await sut.auth(params: params);

    verify(httpClientSpy.request(
      url: url,
      method: 'post',
      body: {'email': params.email, 'password': params.password}
    ));
  });

  test("Should throw UnexpectedError if HttpClient returns 400", () async {
    when(httpClientSpy.request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
    .thenThrow(HttpError.badRequest);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test("Should throw UnexpectedError if HttpClient returns 404", () async {
    when(httpClientSpy.request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
    .thenThrow(HttpError.notFound);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

   test("Should throw UnexpectedError if HttpClient returns 500", () async {
    when(httpClientSpy.request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
    .thenThrow(HttpError.serverError);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test("Should throw InvalidCredentialsError if HttpClient returns 401", () async {
    when(httpClientSpy.request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
    .thenThrow(HttpError.unauthorized);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });
}