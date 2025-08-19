import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_base/screens/authentication/presentation/authentication/blocs/authentication_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/user_profile/user_profile_bloc.dart';
import '../blocs/user_profile/user_profile_event.dart';
import '../blocs/user_profile/user_profile_state.dart';
import '../models/user_profile_model.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/utils/widget_util.dart';
import '../../../../injection_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProfileBloc>(
      create: (_) => sl<UserProfileBloc>()
        ..add(const LoadUserProfileEvent()),
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppNavigationBarVariants.withLogout(
              title: l10n.profile,
              onLogout: () => _showLogoutDialog(context),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileState state) {
    if (state is UserProfileLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is UserProfileError && state.profileModel == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.r,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              state.message,
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _loadProfile(context),
              child: Text(l10n.userRetry),
            ),
          ],
        ),
      );
    } else if (state is UserProfileLoaded ||
        state is UserProfileSuccess ||
        (state is UserProfileError && state.profileModel != null)) {
      
      final profileModel = state is UserProfileLoaded
          ? state.profileModel
          : state is UserProfileSuccess
            ? state.profileModel
            : (state as UserProfileError).profileModel!;

      return RefreshIndicator(
        onRefresh: () async => _refreshProfile(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // User Avatar
              _buildAvatar(profileModel),
              
              SizedBox(height: 24.h),
              
              // Basic User Information Card
              _buildUserInfoCard(profileModel),
              
              SizedBox(height: 24.h),
              
              // Language Switcher Card
              _buildLanguageCard(),
              
              SizedBox(height: 24.h),
              
              // Logout Button
              _buildLogoutButton(context),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildAvatar(UserProfileModel profileModel) {
    return Center(
      child: CircleAvatar(
        radius: 50.r,
        backgroundColor: Colors.blue,
        child: Text(
          profileModel.user.initials,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(UserProfileModel profileModel) {
    final user = profileModel.user;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.userInformation,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            _buildInfoRow(l10n.userID, user.id),
            _buildInfoRow(l10n.userEmail, user.email),
            _buildInfoRow(l10n.userUsername, user.username),
            _buildInfoRow(l10n.userDisplayName, user.displayName),
            _buildInfoRow(
              l10n.userCreatedAt, 
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
            ),
            _buildInfoRow(
              l10n.userVerified,
              user.isVerified ? '✓ ${l10n.userVerified}' : '✗ ${l10n.userNotVerified}',
              valueColor: user.isVerified ? Colors.green : Colors.orange,
            ),
            _buildInfoRow(
              l10n.userStatus,
              user.isActive ? '✓ ${l10n.userActive}' : '✗ ${l10n.userInactive}',
              valueColor: user.isActive ? Colors.green : Colors.red,
            ),
            _buildInfoRow(
              l10n.userAccountAge,
              user.isNewUser ? l10n.userNewUser : '${user.accountAgeInDays} ${l10n.userDaysOld}',
              valueColor: user.isNewUser ? Colors.yellow : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.languageSettings,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            const LanguageSwitcher(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: Text(l10n.userLogout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.userLogout),
          content: Text(l10n.areYouSureLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.userCancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthenticationBloc>().add(LogoutEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.userLogout),
            ),
          ],
        );
      },
    );
  }

  void _loadProfile(BuildContext context) {
    context.read<UserProfileBloc>().add(const LoadUserProfileEvent());
  }

  void _refreshProfile(BuildContext context) {
    context.read<UserProfileBloc>().add(const RefreshUserProfileEvent());
  }
} 