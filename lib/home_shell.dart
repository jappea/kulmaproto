import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'wheel_page.dart';
import 'shock_page.dart';

class HomeShell extends StatefulWidget {
  final CarData data;
  final Future<void> Function() onSaved;
  const HomeShell({super.key, required this.data, required this.onSaved});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late ShockType shockType;
  @override
  void initState() { super.initState(); shockType = widget.data.shockType; }

  @override
  Widget build(BuildContext context) {
    final tabs = [const Tab(text: 'Pyöränkulmat'), if (shockType == ShockType.threeWay) const Tab(text: 'Iskari 3-tie')];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBg,
          elevation: 0,
          title: Text(widget.data.car.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SegmentedButton<ShockType>(
                segments: const [ButtonSegment(value: ShockType.oneWay, label: Text('1-tie')), ButtonSegment(value: ShockType.threeWay, label: Text('3-tie'))],
                selected: {shockType},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? kCard : kBg),
                  foregroundColor: const WidgetStatePropertyAll<Color>(kTextMain),
                ),
                onSelectionChanged: (set) => setState(() { shockType = set.first; }),
              ),
            ),
          ],
          bottom: TabBar(tabs: tabs, indicatorColor: kPrimary),
        ),
        body: TabBarView(physics: const NeverScrollableScrollPhysics(), children: [
          WheelPage(data: widget.data, onChanged: () => setState(() {})),
          if (shockType == ShockType.threeWay) ShockPage(data: widget.data, onChanged: () => setState(() {})),
        ]),
      ),
    );
  }
}

