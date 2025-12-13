import 'package:flutter/material.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/add_listing_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/my_listing_screen.dart';
import 'screens/booking_requests_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/chat_home_screen.dart';
import 'screens/chat_user_list_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/favorites_screen.dart';

class Routes {
  // Getters for routes used in the app
  static String get chat => chatHome;
  static String get listing => listingDetail;
  static String get chatUser => userChat;

  // Auth & Splash
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // Home & Main
  static const String home = '/home';
  static const String map = '/map';
  static const String favorites = '/favorites';
  static const String chatHome = '/chat';
  static const String userChat = '/chat/user';
  static const String chatScreenUsers = '/chat/users';
  static const String profile = '/profile';
  static const String userProfile = '/userProfile';

  // Listings
  static const String listingDetail = '/listing-detail';
  static const String addListing = '/add-listing';

  // Profile
  static const String editProfile = '/editProfile';
  static const String changePassword = '/changePassword';
  static const String myListings = '/myListings';
  static const String myBookings = '/myBookings';
  static const String bookingRequests = '/bookingRequests';
  static const String helpSupport = '/helpSupport';
  static const String aboutUs = '/aboutUs';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth
      case splash:
        return _buildRoute(const SplashScreen());
      case login:
        return _buildRoute(const LoginScreen());
      case signup:
        return _buildRoute(const SignupScreen());

      // Home
      case home:
        return _buildRoute(const HomeScreen());
      case map:
        return _buildRoute(const MapScreen());

      // Favorites
      case favorites:
        return _buildRoute(const FavoritesScreen());

      // Chat
      case chatHome:
        return _buildRoute(const ChatHomeScreen());
      case userChat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ChatUserListScreen(),
        );
      case chatScreenUsers:
        return _buildRoute(const ChatUserListScreen());

      // Profile
      case profile:
        return _buildRoute(const ProfileScreen());
      case userProfile:
        final userId = settings.arguments as String?;
        return _buildRoute(UserProfileScreen(userId: userId ?? ''));
      case editProfile:
        return _buildRoute(const EditProfileScreen());
      case changePassword:
        return _buildRoute(const ChangePasswordScreen());
      case myBookings:
        return _buildRoute(const MyBookingsScreen());
      case myListings:
        return _buildRoute(const MyListingsScreen());
      case bookingRequests:
        return _buildRoute(const BookingRequestsScreen());
      case helpSupport:
        return _buildRoute(const HelpSupportScreen());
      case aboutUs:
        return _buildRoute(const AboutUsScreen());

      // Listings
      case listingDetail:
        final listingId = settings.arguments as String?;
        return _buildRoute(ListingDetailScreen(listingId: listingId));
      case addListing:
        return _buildRoute(const AddListingScreen());

      // Default
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(Widget page) {
    return MaterialPageRoute<T>(builder: (_) => page);
  }
}