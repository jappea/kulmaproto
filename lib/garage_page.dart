import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'home_shell.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});
  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  late List<CarData> cars;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cars = [];
    _loadSample();
  }

  void _loadSample() async {
    cars = [
      CarData(
        car: Car(make: 'BMW', model: 'E36', surface: 'Sora/Jää'),
        shockType: ShockType.threeWay,
        fl: Corner(camber: -2.0, toeMm: 0.8, springMm: 25),
        fr: Corner(camber: -1.7, toeMm: 0.3, springMm: 26),
        rl: Corner(camber: -1.5, toeMm: -0.1, springMm: 29),
        rr: Corner(camber: -1.8, toeMm: -0.1, springMm: 27),
        sfl: Shocks(total: 32, fast: 10, slow: 18),
        sfr: Shocks(total: 35, fast: 12, slow: 16),
        srl: Shocks(total: 30, fast: 8, slow: 20),
        srr: Shocks(total: 34, fast: 9, slow: 19),
      ),
    ];
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Oma autotalli')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: cars.length,
        itemBuilder: (_, i) {
          final d = cars[i];
          return ListTile(
            tileColor: kCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: kOutline)),
            leading: const Icon(Icons.directions_car_filled, color: kTextMuted),
            title: Text(d.car.title),
            subtitle: Text('Pinta: ${d.car.surface}  ·  Iskari: ${d.shockType == ShockType.threeWay ? '3-tie' : '1-tie'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => HomeShell(data: d, onSaved: () async {})));
              setState(() {});
            },
          );
        },
      ),
    );
  }
}

