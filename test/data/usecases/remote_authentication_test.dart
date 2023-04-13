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

  Map mockValidData() => { 'accessToken': faker.guid.guid(), 'name': faker.person.name() };

  PostExpectation mockRequest () =>
    when(httpClientSpy.request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')));
    
  void mockHttpData(Map data) =>
    mockRequest().thenAnswer((_) async => data);

  void mockHttpError(HttpError error) => 
    mockRequest().thenThrow(error);

  setUp(() {
    httpClientSpy = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClientSpy, url: url);
    params = AuthenticationParams(email: faker.internet.email(), password: faker.internet.password());
    mockHttpData(mockValidData());
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
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

   test("Should throw UnexpectedError if HttpClient returns 500", () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test("Should throw InvalidCredentialsError if HttpClient returns 401", () async {
    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(params: params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test("Should return Account entity if HttpClient returns 200", () async {
    final validData = mockValidData();
    mockHttpData(validData);

    final account = await sut.auth(params: params);

    expect(account.token, validData['accessToken']);
  });

  test("Should return Unexpected Error if HttpClient returns 200 with no data", () async {
    mockHttpData({ 'invalid_key': 'invalid_data' });

    final feature = sut.auth(params: params);

    await expect(feature, throwsA(DomainError.unexpected));
  });
}