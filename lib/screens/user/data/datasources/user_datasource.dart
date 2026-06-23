import 'dart:convert';
import 'dart:math';
import 'package:composable_network/composable_network.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract user data source interface
abstract class UserDataSource {
  Future<UserDto> getCurrentUser();
}

/// Implementation of user data source with mock data
/// This simulates API calls and responses
class UserDataSourceImpl implements UserDataSource {
  final RestClientService restClientService;
  final SharedPreferences sharedPreferences;

  UserDataSourceImpl({
    required this.restClientService,
    required this.sharedPreferences,
  });

  @override
  Future<UserDto> getCurrentUser() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if we have cached user data
    final cachedUser = sharedPreferences.getString('current_user');
    if (cachedUser != null) {
      final userData = jsonDecode(cachedUser);
      return UserDto.fromJson(userData);
    }

    // Mock current user data
    final mockUser = UserDto.mock(
      id: 'current_user_123',
      email: 'current.user@example.com',
      username: 'currentuser',
    );

    // Cache the user data
    await sharedPreferences.setString('current_user', jsonEncode(mockUser.toJson()));

    return mockUser;
  }
} 