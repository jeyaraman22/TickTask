import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';

import '../../../../l10n/helper/translation_keys.dart';
import '../../../app_locale/language_bloc.dart';
import '../../../theme/theme_bloc/theme_bloc.dart';
import '../../../core/utils/app_colors.dart';

// Main drawer widget for side menu
class MenuSideDrawer extends StatefulWidget {
  const MenuSideDrawer({super.key});

  @override
  State<MenuSideDrawer> createState() => _MenuSideDrawerState();
}

class _MenuSideDrawerState extends State<MenuSideDrawer> {
  // List to hold menu items
  final List<Widget> _menuList = [];

  @override
  Widget build(BuildContext context) {
    return _buildDrawerView(context, _menuList);
  }

  // Build the main drawer structure
  Widget _buildDrawerView(BuildContext context, List<Widget> menuList) {
    return Drawer(
      // Set drawer width to 55% of screen width
      width: MediaQuery.of(context).size.width * 0.55,
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Main Drawer View
            Expanded(
                flex: 5,
                child: Container(
                    height: double.infinity,
                    color: AppColors.cardBackground,
                    child: _buildMenu(context, menuList))),
          ],
        ),
      ),
    );
  }

  // Build the menu structure with header and settings
  Widget _buildMenu(BuildContext context, List<Widget> menuList) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SideMenuHeader(),
        _buildSettingsSection(),
        _buildMenuList(context, menuList),
      ],
    );
  }

  // Build the settings section including theme and language
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App title
          Text(
            context.l10n.get(AppTranslationStrings.appTitle),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeSelector(),
          const SizedBox(height: 16),
          _buildLanguageSelector(),
        ],
      ),
    );
  }

  // Build language selection buttons
  Widget _buildLanguageSelector() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LoadAppLanguage) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.get(AppTranslationStrings.language)),
              const SizedBox(height: 8),
              Row(
                children: [
                  // English language button
                  _buildLanguageButton(
                    context: context,
                    languageCode: 'en',
                    label: 'En',
                    isSelected: state.currentLanguageCode == 'en',
                  ),
                  const SizedBox(width: 8),
                  // German language button
                  _buildLanguageButton(
                    context: context,
                    languageCode: 'de',
                    label: 'De',
                    isSelected: state.currentLanguageCode == 'de',
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  // Build individual language selection button
  Widget _buildLanguageButton({
    required BuildContext context,
    required String languageCode,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
          foregroundColor: isSelected ? Colors.white : null,
        ),
        onPressed: () {
          context.read<LanguageBloc>().add(ChangeLanguageEvent(languageCode));
        },
        child: Text(label),
      ),
    );
  }

  // Build scrollable menu list
  Widget _buildMenuList(BuildContext context, List<Widget> menuList) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 15, right: 10, left: 20),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: menuList.length,
        itemBuilder: (context, index) =>
            Container(color: Colors.transparent, child: menuList[index]),
      ),
    ));
  }
}

// Header section of the side menu
class _SideMenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        color: Theme.of(context).primaryColor,
        width: double.infinity,
        height: 150,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme toggle button
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  if (state is ThemeInitial) {
                    return Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.read<ThemeBloc>().add(ChangeThemeEvent(
                              state.currentTheme, !state.isDarkMode));
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            const Text(
              "Hi",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ));
  }
}

// Build theme selection dropdown
Widget _buildThemeSelector() {
  return BlocBuilder<ThemeBloc, ThemeState>(
    builder: (context, state) {
      if (state is ThemeInitial) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.get(AppTranslationStrings.theme)),
            const SizedBox(height: 8),
            // Theme dropdown with available options
            DropdownButton<String>(
              value: state.currentTheme,
              isExpanded: true,
              items: ['SoftPastel', 'Earthy', 'Vibrant']
                  .map((theme) => DropdownMenuItem(
                        value: theme,
                        child: Text(theme),
                      ))
                  .toList(),
              onChanged: (newTheme) {
                if (newTheme != null) {
                  context
                      .read<ThemeBloc>()
                      .add(ChangeThemeEvent(newTheme, state.isDarkMode));
                }
              },
            ),
          ],
        );
      }
      return const SizedBox();
    },
  );
}
