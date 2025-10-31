import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'app_routes.dart';
import '../screens/new/splash_screen.dart';
import '../screens/new/login_screen.dart';
import '../screens/new/cadastro_screen.dart';
import '../screens/new/esqueci_senha_screen.dart';
import '../screens/new/validar_codigo_screen.dart';
import '../screens/new/nova_senha_screen.dart';
import '../screens/new/map_screen.dart';
import '../screens/new/navigation_screen.dart';
import '../screens/new/favoritos_screen.dart';
import '../screens/new/lista_postos_screen.dart';
import '../screens/new/configuracoes_screen.dart';
import '../screens/new/notificacoes_screen.dart';
import '../screens/new/route_selection_screen.dart';
import '../models/posto.dart';

/// 🗺️ POSTUL - Configuração de Rotas
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashScreen());

      case AppRoutes.login:
        return _fadeRoute(const LoginScreen());

      case AppRoutes.cadastro:
        return _slideRoute(const CadastroScreen());

      case AppRoutes.esqueciSenha:
        return _slideRoute(const EsqueciSenhaScreen());

      case AppRoutes.validarCodigo:
        final email = settings.arguments as String;
        return _slideRoute(ValidarCodigoScreen(email: email));

      case AppRoutes.novaSenha:
        final args = settings.arguments as Map<String, String>;
        return _slideRoute(NovaSenhaScreen(
          email: args['email']!,
          codigo: args['codigo']!,
        ));

      case AppRoutes.map:
        final args = settings.arguments as MapScreenArgs?;
        return _fadeRoute(MapScreen(usuarioId: args?.usuarioId ?? 0));

      case AppRoutes.navigation:
        final args = settings.arguments as NavigationArgs?;
        if (args == null) {
          return _errorRoute();
        }
        return _slideRoute(NavigationScreen(posto: args.posto, origem: args.origem));

      case AppRoutes.favoritos:
        return _slideRoute(const FavoritosScreen());

      case AppRoutes.listaPostos:
        return _slideRoute(const ListaPostosScreen());

      case AppRoutes.configuracoes:
        return _slideRoute(const ConfiguracoesScreen());

      case AppRoutes.notificacoes:
        return _slideRoute(const NotificacoesScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<T> _fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  static Route<T> _slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  static Route<T> _errorRoute<T>() {
    return MaterialPageRoute<T>(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Página não encontrada'),
        ),
      ),
    );
  }
}

/// 🗺️ Argumentos de Navegação
class MapScreenArgs {
  final int usuarioId;
  MapScreenArgs(this.usuarioId);
}

class NavigationArgs {
  final Posto posto;
  final latlong.LatLng origem;
  final List<latlong.LatLng>? routePoints;
  final RouteType? routeType;
  
  NavigationArgs(
    this.posto,
    this.origem, {
    this.routePoints,
    this.routeType,
  });
}

// Enum para tipos de rota
enum RouteType {
  rapida,
  curta,
  semPedagio,
  semRodovia,
}

class AvaliacoesArgs {
  final Posto posto;
  AvaliacoesArgs(this.posto);
}

class GaleriaArgs {
  final List<String> fotos;
  final int initialIndex;
  GaleriaArgs(this.fotos, this.initialIndex);
}
