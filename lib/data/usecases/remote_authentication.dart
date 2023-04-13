import 'package:meta/meta.dart';

import '../../domain/entities/entities.dart';
import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../http/http.dart';
import '../models/models.dart';

class RemoteAuthentication implements Authentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({ @required this.httpClient, @required this.url });

  Future<AccountEntity> auth({ @required AuthenticationParams params }) async {
    final remoteAuthenticationParams = RemoteAuthenticationParams.make(paramsFromDomain: params);
    try {
      final accountJson = await httpClient.request(url: url, method: 'post', body: remoteAuthenticationParams.toJson());
      if (!accountJson.containsKey('accessToken')) {
        throw HttpError.invalidData;
      }
      return RemoteAccountModel.fromJson(accountJson).toEntity();
    } on HttpError catch(error) { 
      throw error == HttpError.unauthorized ? DomainError.invalidCredentials : DomainError.unexpected;
    }
  }
}

class RemoteAuthenticationParams {
  final String email;
  final String password;

  RemoteAuthenticationParams({ @required this.email, @required this.password });

  factory RemoteAuthenticationParams.make({ @required AuthenticationParams paramsFromDomain }) =>
    RemoteAuthenticationParams(email: paramsFromDomain.email, password: paramsFromDomain.password);

  Map toJson() => { 'email': email, 'password': password };
}