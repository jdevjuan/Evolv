import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import 'dashboard_screen.dart';
import 'evolution_screen.dart';
import 'food_screen.dart';
import 'profile_screen.dart';

/// Estrutura principal do app: barra de navegação inferior com 4 abas.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) appController.refreshIfNewDay();
  }

  Widget _page() {
    switch (_index) {
      case 0:
        return DashboardScreen(onOpenFood: () => setState(() => _index = 1));
      case 1:
        return const FoodScreen();
      case 2:
        return const EvolutionScreen();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_index), child: _page()),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.restaurant_rounded), label: 'Alimentação'),
          NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: 'Evolução'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}
