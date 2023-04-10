import '../../domain/usecases/usecases.dart';
import '../http/http.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({ required this.httpClient, required this.url });

  Future<void>? auth({ required AuthenticationParams params }) async {
    final body = { 'email': params.email, 'password': params.password };
    return await httpClient.request(url: url, method: 'post', body: body);
  }
}