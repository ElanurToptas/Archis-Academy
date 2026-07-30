import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppView({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 60,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(size: 28); // Seçili ikon boyutu
            }
            return const IconThemeData(size: 24); // Seçili olmayan ikon boyutu
          }),

          labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.secondary,
            );
          }),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            indicatorColor: Colors.transparent,
            onDestinationSelected: (index) {
              navigationShell.goBranch(index);
            },

            destinations: [
              _menuItem(
                context,
                icon: Icons.mic,
                label: "Record",
                index: 0,
              ),
              _menuItem(
                context,
                icon: Icons.graphic_eq,
                label: "Voice",
                index: 1,
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _menuItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = navigationShell.currentIndex == index;

    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
      ),
      label: label,
    );
  }
}
