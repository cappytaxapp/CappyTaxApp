import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
}
