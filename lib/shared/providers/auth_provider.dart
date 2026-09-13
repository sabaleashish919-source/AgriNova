import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

/// Provides secure local storage.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provides the API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);

  return ApiClient(storage);
});

/// Represents the current authentication state.
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  bool get isAuthenticated => user != null;
}

/// Handles authentication operations.
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient api;
  final SecureStorage storage;

  AuthNotifier(
    this.api,
    this.storage,
  ) : super(const AuthState());

  /// Restores the previously logged-in user from local storage.
  Future<void> initialize() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final storedUser = await storage.getUser();
      final token = await storage.getToken();

      if (storedUser != null && token != null) {
        final decodedUser = jsonDecode(storedUser);

        if (decodedUser is Map<String, dynamic>) {
          final user = UserModel.fromJson(decodedUser);

          state = AuthState(
            user: user,
            isLoading: false,
          );

          return;
        }
      }

      state = const AuthState();
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Logs the user into the AgroSurplus backend.
  Future<bool> login(
    String email,
    String password,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final response = await api.dio.post(
        '/auth/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw Exception('Invalid response received from server.');
      }

      final data = Map<String, dynamic>.from(responseData);

      final accessToken = data['access_token'];

      if (accessToken == null || accessToken.toString().isEmpty) {
        throw Exception('Access token was not returned by the server.');
      }

      final userData = data['user'];

      if (userData is! Map) {
        throw Exception('User information was not returned by the server.');
      }

      final user = UserModel.fromJson(
        Map<String, dynamic>.from(userData),
      );

      await storage.saveToken(
        accessToken.toString(),
      );

      await storage.saveUser(
        jsonEncode(user.toJson()),
      );

      state = AuthState(
        user: user,
        isLoading: false,
      );

      return true;
    } on DioException catch (e) {
      String message = 'Unable to login.';

      if (e.response != null) {
        final responseData = e.response?.data;

        if (responseData is Map && responseData['detail'] != null) {
          message = responseData['detail'].toString();
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        } else if (e.response?.statusCode == 401) {
          message = 'Invalid email or password.';
        } else if (e.response?.statusCode == 422) {
          message = 'Please check your login details.';
        }
      } else {
        message = 'Unable to connect to the server.';
      }

      state = AuthState(
        isLoading: false,
        error: message,
      );

      return false;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString(),
      );

      return false;
    }
  }

  /// Logs the user out and clears local authentication data.
  Future<void> logout() async {
    await storage.clear();

    state = const AuthState();
  }
}

/// Global authentication provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});
