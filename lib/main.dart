import 'package:cargo_app/core/repositories/chat_repository.dart';
import 'package:cargo_app/features/chat/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/firebase_initializer.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/password_reset_confirmation.dart';
import 'screens/email_verification_screen.dart';
import 'screens/home.dart';
import 'screens/personal_data_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/booking/providers/booking_provider.dart';
import 'core/repositories/user_repository.dart';
import 'core/repositories/booking_repository.dart';
import 'package:cargo_app/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseInitializer(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ButtonProvider()),
          ProxyProvider0<UserRepository>(
            update: (_, __) => FirebaseUserRepository(),
          ),
          ProxyProvider0<BookingRepository>(
            update: (_, __) => FirebaseBookingRepository(),
          ),
          // Add ChatRepository provider
          ProxyProvider0<ChatRepository>(
            update: (_, __) => FirebaseChatRepository(),
          ),
          ChangeNotifierProxyProvider<UserRepository, ProfileProvider>(
            create: (context) => ProfileProvider(
              Provider.of<UserRepository>(context, listen: false),
            ),
            update: (context, userRepo, previous) =>
            previous ?? ProfileProvider(userRepo),
          ),
          ChangeNotifierProxyProvider<BookingRepository, BookingProvider>(
            create: (context) => BookingProvider(
              Provider.of<BookingRepository>(context, listen: false),
            ),
            update: (context, bookingRepo, previous) =>
            previous ?? BookingProvider(bookingRepo),
          ),
          // ChatProvider depends on ChatRepository
          ChangeNotifierProxyProvider<ChatRepository, ChatProvider>(
            create: (context) => ChatProvider(
              Provider.of<ChatRepository>(context, listen: false),
            ),
            update: (context, chatRepo, previous) =>
            previous ?? ChatProvider(chatRepo),
          ),
        ],
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Initialize auth state when the app starts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.initializeAuth();
            });

            return MaterialApp(
              title: 'CargoLink',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'Lexend',
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
              ),
              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/': (context) => WelcomeScreen(),
                '/login': (context) => LoginScreen(),
                '/signup': (context) => SignupScreen(),
                '/forgot-password': (context) => const ForgetPasswordScreen(),
                '/password-reset-confirmation': (context) =>
                const PasswordResetConfirmation(),
                '/email-verification': (context) =>
                const EmailVerificationScreen(),
                '/home': (context) => const Home(),
                '/personal-data': (context) => const PersonalDataScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}