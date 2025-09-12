import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Parent Name',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'parent@email.com',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Profile Options
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileOption(
                      context,
                      'Edit Profile',
                      Icons.edit,
                      () {},
                    ),
                    _buildProfileOption(
                      context,
                      'Child Information',
                      Icons.child_care,
                      () {},
                    ),
                    _buildProfileOption(
                      context,
                      'Assessment History',
                      Icons.history,
                      () {},
                    ),
                    _buildProfileOption(
                      context,
                      'Settings',
                      Icons.settings,
                      () {},
                    ),
                    _buildProfileOption(
                      context,
                      'Help & Support',
                      Icons.help_outline,
                      () {},
                    ),
                    _buildProfileOption(
                      context,
                      'Privacy Policy',
                      Icons.privacy_tip,
                      () {},
                    ),
                    _buildProfileOption(
                      context,
                      'Terms of Service',
                      Icons.description,
                      () {},
                    ),
                    const SizedBox(height: 24),
                    _buildProfileOption(
                      context,
                      'Sign Out',
                      Icons.logout,
                      () {},
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDestructive ? AppColors.error : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
