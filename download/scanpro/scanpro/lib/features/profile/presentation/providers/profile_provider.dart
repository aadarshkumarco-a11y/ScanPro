import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String subscriptionTier; // free, premium, pro
  final DateTime subscriptionExpiry;
  final int usedStorageBytes;
  final int totalStorageBytes;
  final int totalDocuments;
  final int totalScans;
  final int ocrCount;
  final List<LinkedAccount> linkedAccounts;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.subscriptionTier = 'free',
    DateTime? subscriptionExpiry,
    this.usedStorageBytes = 3221225472,
    this.totalStorageBytes = 5368709120,
    this.totalDocuments = 47,
    this.totalScans = 128,
    this.ocrCount = 35,
    this.linkedAccounts = const [],
  }) : subscriptionExpiry = subscriptionExpiry ?? DateTime(2024, 12, 31);

  String get storageUsedFormatted {
    if (usedStorageBytes < 1024 * 1024 * 1024) {
      return '${(usedStorageBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(usedStorageBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get storageTotalFormatted {
    if (totalStorageBytes < 1024 * 1024 * 1024) {
      return '${(totalStorageBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(totalStorageBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  double get storageFraction =>
      totalStorageBytes > 0 ? usedStorageBytes / totalStorageBytes : 0;

  bool get isPremium => subscriptionTier != 'free';
}

class LinkedAccount {
  final String provider;
  final String displayName;
  final String email;
  final bool isConnected;

  const LinkedAccount({
    required this.provider,
    required this.displayName,
    required this.email,
    this.isConnected = true,
  });
}

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String errorMessage;
  final bool isSigningOut;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage = '',
    this.isSigningOut = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isSigningOut,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSigningOut: isSigningOut ?? this.isSigningOut,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    _loadProfile();
  }

  void _loadProfile() {
    state = state.copyWith(isLoading: true);
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(
        isLoading: false,
        profile: UserProfile(
          id: 'user_001',
          displayName: 'John Doe',
          email: 'john.doe@example.com',
          subscriptionTier: 'free',
          linkedAccounts: const [
            LinkedAccount(
              provider: 'google',
              displayName: 'John Doe',
              email: 'john.doe@gmail.com',
            ),
          ],
        ),
      );
    });
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (state.profile == null) return;
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      isLoading: false,
      profile: state.profile!.copyWith(
        displayName: displayName ?? state.profile!.displayName,
        photoUrl: photoUrl ?? state.profile!.photoUrl,
      ),
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isSigningOut: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isSigningOut: false);
    // In production, clear auth state and navigate to login
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
