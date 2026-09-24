import 'package:flutter/material.dart';
import 'theme/sushiro_theme.dart';
import 'providers/checkout_provider.dart';
import 'views/sushiro_main_screen.dart';

void main() {
  // Initialize state provider block
  final checkoutProvider = CheckoutProvider();

  runApp(
    SushiroCheckoutApp(provider: checkoutProvider),
  );
}

class SushiroCheckoutApp extends StatelessWidget {
  const SushiroCheckoutApp({super.key, required this.provider});

  final CheckoutProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Sushiro Checkout & Split-Bill',
          debugShowCheckedModeBanner: false,
          theme: SushiroTheme.lightTheme,
          darkTheme: SushiroTheme.darkTheme,
          themeMode: provider.themeMode,
          home: SushiroMainScreen(provider: provider),
        );
      },
    );
  }
}
