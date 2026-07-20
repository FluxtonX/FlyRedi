import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/notification_service.dart';
import '../core/storage/storage_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../features/auth/data/datasources/auth_firebase_data_source.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../features/traveller/data/repositories/trip_repository_impl.dart';
import '../features/traveller/data/repositories/alert_repository_impl.dart';
import '../features/traveller/data/repositories/claim_repository_impl.dart';
import '../features/traveller/data/repositories/dashboard_repository_impl.dart';
import '../features/traveller/presentation/providers/trips_provider.dart';
import '../features/traveller/presentation/providers/alert_provider.dart';
import '../features/traveller/presentation/providers/claim_provider.dart';
import '../features/traveller/presentation/providers/dashboard_provider.dart';
import '../features/traveller/presentation/providers/profile_provider.dart';
import 'app_router.dart';

/// Root of the Provider tree.
/// All top-level providers are defined here.
/// Screens access them via [context.read] / [context.watch].
class AppProviders extends StatelessWidget {
  final StorageService storageService;

  const AppProviders({required this.storageService, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Infrastructure ───────────────────────────────────────────────────
        Provider<StorageService>.value(value: storageService),

        // ── Theme ────────────────────────────────────────────────────────────
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(storageService),
        ),

        // ── Auth ─────────────────────────────────────────────────────────────
        Provider<AuthFirebaseDataSource>(
          create: (_) => AuthFirebaseDataSource(),
        ),

        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            remoteDataSource: context.read<AuthFirebaseDataSource>(),
            localDataSource: AuthLocalDataSource(
              storageService: storageService,
            ),
          ),
        ),

        // ── Onboarding ───────────────────────────────────────────────────────
        ChangeNotifierProvider<OnboardingProvider>(
          create: (context) => OnboardingProvider(
            context.read<AuthFirebaseDataSource>(),
          ),
        ),

        // ── Firestore instance (shared) ──────────────────────────────────────
        Provider<FirebaseFirestore>(
          create: (_) => FirebaseFirestore.instance,
        ),

        // ── Traveller Feature Repositories ───────────────────────────────────
        Provider<TripRepositoryImpl>(
          create: (context) => TripRepositoryImpl(
            db: context.read<FirebaseFirestore>(),
          ),
        ),

        Provider<AlertRepositoryImpl>(
          create: (context) => AlertRepositoryImpl(
            db: context.read<FirebaseFirestore>(),
          ),
        ),

        Provider<ClaimRepositoryImpl>(
          create: (context) => ClaimRepositoryImpl(
            db: context.read<FirebaseFirestore>(),
          ),
        ),

        Provider<DashboardRepositoryImpl>(
          create: (context) => DashboardRepositoryImpl(
            db: context.read<FirebaseFirestore>(),
          ),
        ),

        // ── Traveller Feature Providers ──────────────────────────────────────
        ChangeNotifierProxyProvider<AuthProvider, TripsProvider>(
          create: (context) => TripsProvider(context.read<TripRepositoryImpl>()),
          update: (_, auth, trips) => trips!..onAuthChanged(auth.user?.id),
        ),

        ChangeNotifierProxyProvider<AuthProvider, AlertProvider>(
          create: (context) => AlertProvider(context.read<AlertRepositoryImpl>()),
          update: (_, auth, alerts) => alerts!..onAuthChanged(auth.user?.id),
        ),

        ChangeNotifierProxyProvider<AuthProvider, ClaimProvider>(
          create: (context) => ClaimProvider(context.read<ClaimRepositoryImpl>()),
          update: (_, auth, claims) => claims!..onAuthChanged(auth.user?.id),
        ),

        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (context) => DashboardProvider(context.read<DashboardRepositoryImpl>()),
          update: (_, auth, db) => db!..onAuthChanged(auth.user?.id),
        ),

        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(
            dataSource: context.read<AuthFirebaseDataSource>(),
            authProvider: context.read<AuthProvider>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) => _SkyRightzApp(theme: theme),
      ),
    );
  }
}

class _SkyRightzApp extends StatelessWidget {
  final ThemeProvider theme;

  const _SkyRightzApp({required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyRightz360',
      navigatorKey: NotificationService.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: theme.themeMode,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
