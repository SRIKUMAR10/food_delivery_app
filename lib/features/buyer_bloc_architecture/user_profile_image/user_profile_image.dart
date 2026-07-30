// lib/user_profile_image/user_profile_image.dart
//
// Barrel file for the User Profile BLoC architecture.
// Provides the root wrapper widget `user_profile_image` which injects
// the UserProfileBloc into the widget tree and displays the UI.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';

import 'user_profile_image_Bloc.dart';
import 'user_profile_image_UI.dart';

export 'transactions_page.dart';
export 'user_profile_image_Bloc.dart';
export 'user_profile_image_UI.dart';
export 'user_profile_models.dart';

/// The root entry point for the User Profile Drawer.
/// We keep the name `user_profile_image` (lowercase) for backward compatibility
/// with existing files that import it.
class user_profile_image extends StatelessWidget {
  const user_profile_image({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProfileBloc>(
      create: (context) => UserProfileBloc(
        authService: context.read<IAuthService>(),
        profileRepository: context.read<IUserProfileRepository>(),
      ),
      child: const UserProfileDrawer(),
    );
  }
}
