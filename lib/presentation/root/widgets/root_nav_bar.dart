import 'package:flutter/material.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/presentation/root/models/root_destination.dart';

class RootNavBar extends StatelessWidget {
  final int currentPageIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<RootDestination> destinations;
  final Color borderColor = const Color.fromARGB(93, 52, 52, 52);

  final bool showSelection;
  const RootNavBar({
    super.key,
    required this.currentPageIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.showSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      maintainBottomViewPadding: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.directional(
            bottomEnd: Radius.circular(50),
            bottomStart: Radius.circular(50),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadiusGeometry.directional(
                bottomEnd: Radius.circular(50),
                bottomStart: Radius.circular(50),
              ),
              border: Border(
                left: BorderSide(color: borderColor, width: 1.5),
                right: BorderSide(color: borderColor, width: 1.5),
                bottom: BorderSide(color: borderColor, width: 0.4),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 15, 12, 20),
            child: NavigationBar(
              indicatorColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              animationDuration: Duration(milliseconds: 2000),
              selectedIndex: currentPageIndex,
              onDestinationSelected: onDestinationSelected,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (showSelection && states.contains(WidgetState.selected)) {
                  return TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Satoshi',
                    color: Colors.white,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha(200),
                        blurRadius: 9,
                        offset: Offset(0, 2),
                      ),
                    ],
                  );
                }
                return TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  fontFamily: 'Satoshi',
                  color: Colors.white60,
                  letterSpacing: 0.5,
                  fontSize: 12,
                );
              }),
              destinations: [
                for (var i = 0; i < destinations.length; i++)
                  NavigationDestination(
                    icon: Builder(
                      builder: (_) {
                        final bool isSelected =
                            showSelection && i == currentPageIndex;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 55,
                          height: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? context.isDarkMode
                                        ? AppColors.darkGrey
                                        : AppColors.lightBackground
                                  : Colors.transparent,
                              style: BorderStyle.solid,
                              width: 1.2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              isSelected
                                  ? AppColors.darkBackground
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            child: destinations[i].icon,
                          ),
                        );
                      },
                    ),
                    label: destinations[i].label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
