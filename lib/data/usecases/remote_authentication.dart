import '../../domain/usecases/usecases.dart';
import '../http/http.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({ required this.httpClient, required this.url });

  Future<void>? auth({ required AuthenticationParams params }) async {
    final remoteAuthenticationParams = RemoteAuthenticationParams.make(paramsFromDomain: params);
    return await httpClient.request(url: url, method: 'post', body: remoteAuthenticationParams.toJson());
  }
}

class RemoteAuthenticationParams {
  final String email;
  final String password;

  RemoteAuthenticationParams({ required this.email, required this.password });

  factory RemoteAuthenticationParams.make({ required AuthenticationParams paramsFromDomain }) =>
    RemoteAuthenticationParams(email: paramsFromDomain.email, password: paramsFromDomain.password);

  Map toJson() => { 'email': email, 'password': password };
}