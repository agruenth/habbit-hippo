import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance;

  Future<TokenPair> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final resp = await _dio.post('/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
    });
    final pair = TokenPair.fromJson(resp.data);
    await SecureStorage.saveTokens(access: pair.accessToken, refresh: pair.refreshToken);
    return pair;
  }

  Future<TokenPair> login({required String email, required String password}) async {
    final resp = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final pair = TokenPair.fromJson(resp.data);
    await SecureStorage.saveTokens(access: pair.accessToken, refresh: pair.refreshToken);
    return pair;
  }

  Future<void> logout() => SecureStorage.clear();

  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getAccessToken();
    return token != null;
  }
}

final authRepositoryProvider = Provider((_) => AuthRepository());
