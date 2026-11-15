import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorParser {
  static String getMessage(dynamic error) {
    if (error is AuthException) {
      if (error.message.contains('Invalid login credentials')) return 'Invalid email or password.';
      if (error.message.contains('already registered')) return 'This email is already registered.';
      if (error.message.contains('Password should be')) return 'Password must be at least 6 characters.';
      return 'Authentication failed. Please check your details.';
    }
    if (error is PostgrestException) {
      if (error.code == '23505') return 'A record with this information already exists.';
      if (error.code == '23503') return 'Cannot delete or update because it is still in use.';
      if (error.code == '23502') return 'Please fill all required fields.';
      return 'Database error. Please check your input and try again.';
    }
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('socketexception') || errStr.contains('network') || errStr.contains('failed host lookup')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Something went wrong. Please try again.';
  }
}
