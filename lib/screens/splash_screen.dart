import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configuración de animaciones
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duración de la animación
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut), // Efecto rebote
    );

    _controller.forward(); // Iniciar animación

    // Verificar autenticación después de la animación
    Future.delayed(const Duration(seconds: 3), _checkLoginStatus);
  }

  void _checkLoginStatus() {
    User? user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        user != null ? '/home' : '/login', // Redirige a home o login
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF76b5c5), // Color de fondo
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/images/r5-logo-light.png', // Ruta correcta de la imagen
            width: 150,
          ),
        ),
      ),
    );
  }
}
