import 'package:flutter/material.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/presentation/root/models/root_destination.dart';

class FeaturesSheet extends StatefulWidget {
  static const double minExtent = 0.06;
  static const double maxExtent = 0.7;
  static const double fadeEndExtent = 0.57;

  final List<RootDestination> destinations;
  final int? selectedSheetIndex;
  final ValueChanged<int> onFeatureSelected;

  const FeaturesSheet({
    super.key,
    required this.destinations,
    required this.onFeatureSelected,
    this.selectedSheetIndex,
  });

  @override
  State<FeaturesSheet> createState() => _FeaturesSheetState();
}

class _FeaturesSheetState extends State<FeaturesSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  double _extent = FeaturesSheet.minExtent;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncExtent);
  }

  void _syncExtent() {
    if (!mounted) return;
    setState(() => _extent = _controller.size);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncExtent);
    _controller.dispose();
    super.dispose();
  }

  double get _contentOpacity =>
      ((_extent - FeaturesSheet.minExtent) /
              (FeaturesSheet.fadeEndExtent - FeaturesSheet.minExtent))
          .clamp(0.0, 1.0);

  void _onTileTap(int index) {
    widget.onFeatureSelected(index);
    if (_controller.isAttached) {
      _controller.animateTo(
        FeaturesSheet.minExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _featureTile(RootDestination destination, int index) {
    final isSelected = index == widget.selectedSheetIndex;
    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 2,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 250),
              width: 55,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? context.isDarkMode
                            ? AppColors.darkGrey.withAlpha(200)
                            : Colors.transparent
                      : Colors.transparent,
                  style: BorderStyle.solid,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                color: isSelected
                    ? context.isDarkMode
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.surface
                    : Colors.transparent,
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? context.isDarkMode
                            ? AppColors.darkBackground
                            : Theme.of(context).colorScheme.inverseSurface
                                  .withAlpha(200)
                      : context.isDarkMode
                      ? Colors.grey
                      : const Color.fromARGB(255, 79, 79, 79).withAlpha(200),
                  BlendMode.srcIn,
                ),
                child: destination.icon,
              ),
            ),
            Text(
              destination.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.clip,
                fontFamily: 'Satoshi',
                color: isSelected
                    ? context.isDarkMode
                          ? Colors.white
                          : Colors.black
                    : context.isDarkMode
                    ? const Color.fromARGB(255, 235, 235, 235)
                    : const Color.fromARGB(255, 79, 79, 79),
                letterSpacing: 0.5,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: context.isDarkMode
                        ? Colors.black.withAlpha(200)
                        : const Color.fromARGB(
                            255,
                            202,
                            202,
                            202,
                          ).withAlpha(220),
                    blurRadius: 2,
                    offset: Offset(0, 0.4),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = context.isDarkMode
        ? const Color.fromARGB(93, 143, 143, 143)
        : const Color.fromARGB(63, 52, 52, 52);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: FeaturesSheet.minExtent,
        minChildSize: FeaturesSheet.minExtent,
        maxChildSize: FeaturesSheet.maxExtent,
        snap: true,
        builder: (context, scrollController) {
          return ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                border: Border(
                  left: BorderSide(color: borderColor, width: 0.2),
                  right: BorderSide(color: borderColor, width: 0.2),
                  top: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 26),
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _contentOpacity,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Funcionalidades',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        GridView.count(
                          crossAxisCount: 3,
                          // childAspectRatio: 1.1,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 12,
                          children: [
                            for (var i = 0; i < widget.destinations.length; i++)
                              _featureTile(widget.destinations[i], i),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
