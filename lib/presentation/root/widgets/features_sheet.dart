import 'package:flutter/material.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/presentation/root/models/root_destination.dart';

class FeaturesSheet extends StatefulWidget {
  static const double minExtent = 0.06;
  static const double maxExtent = 0.7;
  static const double fadeEndExtent = 0.57;

  final List<RootDestination> destinations;
  final ValueChanged<int> onFeatureSelected;

  const FeaturesSheet({
    super.key,
    required this.destinations,
    required this.onFeatureSelected,
  });

  @override
  State<FeaturesSheet> createState() => _FeaturesSheetState();
}

class _FeaturesSheetState extends State<FeaturesSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  double _extent = FeaturesSheet.minExtent;
  final Color borderColor = const Color.fromARGB(93, 52, 52, 52);

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
    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            destination.icon,
            const SizedBox(height: 8),
            Text(
              destination.label,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w500,
                fontSize: 14,
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
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                border: Border(
                  left: BorderSide(color: borderColor, width: 0.2),
                  right: BorderSide(color: borderColor, width: 0.2),
                  top: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
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
                            fontSize: 18,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 0),
                        GridView.count(
                          crossAxisCount: 3,
                          // childAspectRatio: 1.4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
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
