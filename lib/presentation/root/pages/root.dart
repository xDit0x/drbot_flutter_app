import 'package:flutter/material.dart';
import 'package:flutter_learning/presentation/root/models/root_destination.dart';
import 'package:flutter_learning/presentation/root/root_navigation.dart';
import 'package:flutter_learning/presentation/root/widgets/feature_scaffold.dart';
import 'package:flutter_learning/presentation/root/widgets/features_sheet.dart';
import 'package:flutter_learning/presentation/root/widgets/root_nav_bar.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPageIndex = 0;
  RootDestination? selectedSheetFeature; // patrón null-aware, si se selecciona una del dock, ya no es null, asique el body coge la página del sheet, si no se ha seleccionado niguna del features, es null -> coge del dock

  final dock = RootDestination.rootDestinations
      .where((d) => d.pinnedToDock)
      .toList();

  final sheet = RootDestination.rootDestinations
      .where((d) => !d.pinnedToDock)
      .toList();
  @override
  void initState() {
    super.initState();
    RootNavigation.pendingDestination.addListener(_handlePendingDestination);
  }

  void _handlePendingDestination() {
    final label = RootNavigation.pendingDestination.value;
    if (label == null) return;

    final dockIndex = dock.indexWhere((d) => d.label == label);
    final sheetIndex = sheet.indexWhere((d) => d.label == label);

    if (!mounted) return;
    setState(() {
      if (dockIndex >= 0) {
        currentPageIndex = dockIndex;
        selectedSheetFeature = null;
      } else if (sheetIndex >= 0) {
        selectedSheetFeature = sheet[sheetIndex];
      }
    });
    RootNavigation.pendingDestination.value = null;
  }

  @override
  void dispose() {
    RootNavigation.pendingDestination.removeListener(_handlePendingDestination);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = selectedSheetFeature ?? dock[currentPageIndex];
    // final current = sheet[1];

    return Scaffold(
      body: Stack(
        children: [
          FeatureScaffold(destination: current),
          FeaturesSheet(
            selectedSheetIndex: selectedSheetFeature == null
                ? null
                : sheet.indexOf(selectedSheetFeature!),
            destinations: sheet,
            onFeatureSelected: (index) {
              setState(() {
                selectedSheetFeature = sheet[index];
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: RootNavBar(
        destinations: dock,
        currentPageIndex: currentPageIndex,
        showSelection: selectedSheetFeature == null,
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
            selectedSheetFeature = null;
          });
        },
      ),
    );
  }
}
