import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Iniciar sesión con correo y contraseña
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } catch (e) {
      print("Error en autenticación con correo: $e");
      return null;
    }
  }

  // Registrar un nuevo usuario con correo y contraseña
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } catch (e) {
      print("Error en registro con correo: $e");
      return null;
    }
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}