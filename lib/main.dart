import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// ===== THEME COLORS =====
const kBg = Color(0xFF0E1013);
const kCard = Color(0xFF171A20);
const kOutline = Color(0xFF252830);
const kPrimary = Color(0xFF4DA3FF);
const kTextMain = Color(0xFFE8ECF1);
const kTextMuted = Color(0xFFA1A8B0);

void main() {
  runApp(const KulmaProtoApp());
}

class KulmaProtoApp extends StatelessWidget {
  const KulmaProtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kulmaproto',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: kPrimary,
          surface: kCard,
          background: kBg,
          onSurface: kTextMain,
        ),
        scaffoldBackgroundColor: kBg,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kCard,
          contentTextStyle: TextStyle(color: kTextMain),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kTextMain, fontSize: 16),
          labelSmall: TextStyle(color: kTextMuted, fontSize: 12),
          titleMedium:
              TextStyle(color: kTextMain, fontWeight: FontWeight.w600),
        ),
      ),
      builder: (ctx, child) {
        final mq = MediaQuery.of(ctx);
        final clamped = mq.textScaler.clamp(maxScaleFactor: 1.1);
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
      debugShowCheckedModeBanner: false,
      home: const GaragePage(),
    );
  }
}

/// ===== COMMON UI PARTS =====
class CardPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const CardPanel({super.key, required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 700;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.article_rounded, size: isPhone ? 14 : 16, color: kTextMuted),
            const SizedBox(width: 6),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ]),
          Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
          const Divider(height: 20, color: kOutline),
          child,
        ],
      ),
    );
  }
}

class StepperField extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final double step;
  final int fractionDigits;
  final ValueChanged<double> onChanged;

  const StepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.unit = '',
    this.min = -9999,
    this.max = 9999,
    this.step = 1,
    this.fractionDigits = 0,
  });

  @override
  Widget build(BuildContext context) {
    final text = value.toStringAsFixed(fractionDigits);
    final isPhone = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.1)),
          const SizedBox(height: 6),
          Row(
            children: [
              _roundBtn(Icons.remove, onTap: () {
                final v = (value - step).clamp(min, max);
                onChanged(v);
              }, isPhone: isPhone),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final ctrl = TextEditingController(text: text.replaceAll('.', ','));
                    final v = await showDialog<double>(
                      context: context,
                      builder: (ctx) => _NumberDialog(
                        title: label,
                        controller: ctrl,
                        fractionDigits: fractionDigits,
                        unit: unit,
                      ),
                    );
                    if (v != null) onChanged(v.clamp(min, max));
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1217),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kOutline),
                    ),
                    child: Text(
                      unit.isEmpty ? text : '$text $unit',
                      style: TextStyle(fontSize: isPhone ? 16 : 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _roundBtn(Icons.add, onTap: () {
                final v = (value + step).clamp(min, max);
                onChanged(v);
              }, isPhone: isPhone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, {required VoidCallback onTap, required bool isPhone}) {
    final sz = isPhone ? 40.0 : 44.0;
    return SizedBox(
      width: sz,
      height: sz,
      child: Material(
        color: const Color(0xFF10141A),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Icon(icon, color: kTextMain, size: isPhone ? 18 : 20),
        ),
      ),
    );
  }
}

class _NumberDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final int fractionDigits;
  final String unit;
  const _NumberDialog({required this.title, required this.controller, required this.fractionDigits, this.unit = ''});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCard,
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        style: const TextStyle(color: kTextMain),
        decoration: InputDecoration(
          hintText: '0${unit.isEmpty ? '' : ' $unit'}',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Peruuta')),
        FilledButton(
          onPressed: () {
            final raw = controller.text.replaceAll(',', '.');
            final v = double.tryParse(raw);
            Navigator.pop(context, v);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// ===== WHEEL PAGE – responsive with side notes =====
class WheelPage extends StatelessWidget {
  final CarData data;
  final VoidCallback onChanged;
  const WheelPage({super.key, required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 800;

    final center = _centerSummary();

    if (isPhone) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 8), child: center),
          _cardWithNoteInside(context, 'FL', 'Etu-vasen', data.fl),
          _cardWithNoteInside(context, 'FR', 'Etu-oikea', data.fr),
          _cardWithNoteInside(context, 'RL', 'Taka-vasen', data.rl),
          _cardWithNoteInside(context, 'RR', 'Taka-oikea', data.rr),
        ],
      );
    }

    Widget leftCell(String code, String pos, Corner c) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: CardPanel(title: code, subtitle: pos, child: _cornerFields(context, c))),
          const SizedBox(width: 8),
          if (c.note.isNotEmpty) _sideNote(c.note, alignLeft: false),
        ],
      );
    }

    Widget rightCell(String code, String pos, Corner c) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.note.isNotEmpty) _sideNote(c.note, alignLeft: true),
          const SizedBox(width: 8),
          Expanded(child: CardPanel(title: code, subtitle: pos, child: _cornerFields(context, c))),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 8), child: center),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftCell('FL', 'Etu-vasen', data.fl)),
              const SizedBox(width: 12),
              Expanded(child: rightCell('FR', 'Etu-oikea', data.fr)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftCell('RL', 'Taka-vasen', data.rl)),
              const SizedBox(width: 12),
              Expanded(child: rightCell('RR', 'Taka-oikea', data.rr)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _centerSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _axleLine('Etuakseli total toe', data.fl.toeMm + data.fr.toeMm),
          const SizedBox(height: 6),
          _axleLine('Taka-akseli total toe', data.rl.toeMm + data.rr.toeMm),
          const SizedBox(height: 6),
          Text('Pinta: ${data.car.surface}', style: const TextStyle(color: kTextMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sideNote(String note, {required bool alignLeft}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF12161C),
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(alignLeft ? 8 : 0),
            right: Radius.circular(alignLeft ? 0 : 8),
          ),
          border: Border.all(color: kOutline),
        ),
        child: Text(
          note,
          style: const TextStyle(color: kTextMuted, fontSize: 12, height: 1.15),
        ),
      ),
    );
  }

  Widget _cardWithNoteInside(BuildContext context, String code, String pos, Corner c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardPanel(title: code, subtitle: pos, child: _cornerFields(context, c)),
          if (c.note.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF12161C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kOutline),
              ),
              child: Text(c.note, style: const TextStyle(color: kTextMuted, fontSize: 12, height: 1.15)),
            ),
        ],
      ),
    );
  }

  Widget _cornerFields(BuildContext context, Corner c) {
    return Column(
      children: [
        StepperField(
          label: 'Camber (°)',
          value: c.camber,
          min: -10, max: 10, step: 0.1, fractionDigits: 1,
          onChanged: (v) { c.camber = _round1(v); onChanged(); },
        ),
        StepperField(
          label: 'Toe (mm)',
          value: c.toeMm,
          min: -10, max: 10, step: 0.1, fractionDigits: 1,
          onChanged: (v) { c.toeMm = _round1(v); onChanged(); },
        ),
        StepperField(
          label: 'Jousi (mm)',
          value: c.springMm,
          min: -100, max: 1000, step: 1, fractionDigits: 0,
          onChanged: (v) { c.springMm = v.roundToDouble(); onChanged(); },
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () async {
            final ctrl = TextEditingController(text: c.note);
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: kCard,
                title: const Text('Muistiinpano'),
                content: TextField(
                  controller: ctrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Mittaustapa / huomio (max 200)'),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Peruuta')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tallenna')),
                ],
              ),
            );
            if (ok == true) { c.note = ctrl.text.trim(); onChanged(); }
          },
          icon: const Icon(Icons.note_add_outlined, color: kTextMuted, size: 18),
          label: const Text('Note', style: TextStyle(color: kTextMuted)),
        ),
      ],
    );
  }

  Widget _axleLine(String label, double value) {
    final text = value.toStringAsFixed(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label (mm): ', style: const TextStyle(color: kTextMuted)),
        const Icon(Icons.arrow_right_alt, color: Colors.white, size: 18),
        Text(text),
      ],
    );
  }
}

/// ===== SHOCK PAGE — responsive with side notes =====
class ShockPage extends StatelessWidget {
  final CarData data;
  final VoidCallback onChanged;
  const ShockPage({super.key, required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 800;

    Widget panel(String code, String pos, Shocks s) {
      return CardPanel(
        title: code, subtitle: pos,
        child: Column(
          children: [
            StepperField(
              label: 'Kokonaisklikit',
              value: s.total.toDouble(),
              min: 0, max: 50, step: 1, fractionDigits: 0,
              onChanged: (v) { s.total = v.round().clamp(0, 50); onChanged(); },
            ),
            StepperField(
              label: 'Nopea',
              value: s.fast.toDouble(),
              min: 0, max: 50, step: 1, fractionDigits: 0,
              onChanged: (v) { s.fast = v.round().clamp(0, 50); onChanged(); },
            ),
            StepperField(
              label: 'Hidas',
              value: s.slow.toDouble(),
              min: 0, max: 50, step: 1, fractionDigits: 0,
              onChanged: (v) { s.slow = v.round().clamp(0, 50); onChanged(); },
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () async {
                final ctrl = TextEditingController(text: s.note);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: kCard,
                    title: const Text('Muistiinpano'),
                    content: TextField(
                      controller: ctrl,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Klikkien mittaustapa / huomio'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Peruuta')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tallenna')),
                    ],
                  ),
                );
                if (ok == true) { s.note = ctrl.text.trim(); onChanged(); }
              },
              icon: const Icon(Icons.note_add_outlined, color: kTextMuted, size: 18),
              label: const Text('Note', style: TextStyle(color: kTextMuted)),
            ),
          ],
        ),
      );
    }

    if (isPhone) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _cardWithNoteBlock(panel('FL', 'Etu-vasen', data.sfl), data.sfl.note),
          _cardWithNoteBlock(panel('FR', 'Etu-oikea', data.sfr), data.sfr.note),
          _cardWithNoteBlock(panel('RL', 'Taka-vasen', data.srl), data.srl.note),
          _cardWithNoteBlock(panel('RR', 'Taka-oikea', data.srr), data.srr.note),
        ],
      );
    }

    Widget leftCell(String code, String pos, Shocks s) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: panel(code, pos, s)),
          const SizedBox(width: 8),
          if (s.note.isNotEmpty) _sideNote(s.note, alignLeft: false),
        ],
      );
    }

    Widget rightCell(String code, String pos, Shocks s) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s.note.isNotEmpty) _sideNote(s.note, alignLeft: true),
          const SizedBox(width: 8),
          Expanded(child: panel(code, pos, s)),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftCell('FL', 'Etu-vasen', data.sfl)),
              const SizedBox(width: 12),
              Expanded(child: rightCell('FR', 'Etu-oikea', data.sfr)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftCell('RL', 'Taka-vasen', data.srl)),
              const SizedBox(width: 12),
              Expanded(child: rightCell('RR', 'Taka-oikea', data.srr)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardWithNoteBlock(Widget card, String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card,
          if (note.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF12161C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kOutline),
              ),
              child: Text(note, style: const TextStyle(color: kTextMuted, fontSize: 12, height: 1.15)),
            ),
        ],
      ),
    );
  }

  Widget _sideNote(String note, {required bool alignLeft}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF12161C),
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(alignLeft ? 8 : 0),
            right: Radius.circular(alignLeft ? 0 : 8),
          ),
          border: Border.all(color: kOutline),
        ),
        child: Text(note, style: const TextStyle(color: kTextMuted, fontSize: 12, height: 1.15)),
      ),
    );
  }
}

/// ===== helpers =====
double _round1(double v) => (v * 10).roundToDouble() / 10.0;

/// ===== DATA MODELS + SERIALIZATION =====
enum ShockType { oneWay, threeWay }

String shockTypeToStr(ShockType t) => t == ShockType.threeWay ? 'three' : 'one';
ShockType shockTypeFromStr(String s) => s == 'three' ? ShockType.threeWay : ShockType.oneWay;

class Car {
  String make;
  String model;
  String surface;
  ShockType defaultShockType;

  Car({
    required this.make,
    required this.model,
    this.surface = 'Asfaltti',
    this.defaultShockType = ShockType.threeWay,
  });

  String get title => '$make $model';

  Map<String, dynamic> toJson() => {
        'make': make,
        'model': model,
        'surface': surface,
        'defaultShockType': shockTypeToStr(defaultShockType),
      };

  static Car fromJson(Map<String, dynamic> j) => Car(
        make: j['make'] ?? '',
        model: j['model'] ?? '',
        surface: j['surface'] ?? 'Asfaltti',
        defaultShockType: shockTypeFromStr(j['defaultShockType'] ?? 'three'),
      );
}

class Corner {
  double camber; // °
  double toeMm; // mm
  double springMm; // mm
  String note;

  Corner({
    required this.camber,
    required this.toeMm,
    required this.springMm,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'camber': camber,
        'toeMm': toeMm,
        'springMm': springMm,
        'note': note,
      };

  static Corner fromJson(Map<String, dynamic> j) => Corner(
        camber: (j['camber'] ?? 0).toDouble(),
        toeMm: (j['toeMm'] ?? 0).toDouble(),
        springMm: (j['springMm'] ?? 0).toDouble(),
        note: j['note'] ?? '',
      );

  Corner clone() => Corner(camber: camber, toeMm: toeMm, springMm: springMm, note: note);
}

class Shocks {
  int total; // 0..50
  int fast; // 0..50
  int slow; // 0..50
  String note;

  Shocks({required this.total, required this.fast, required this.slow, this.note = ''});

  Map<String, dynamic> toJson() => {
        'total': total,
        'fast': fast,
        'slow': slow,
        'note': note,
      };

  static Shocks fromJson(Map<String, dynamic> j) => Shocks(
        total: (j['total'] ?? 0).toInt(),
        fast: (j['fast'] ?? 0).toInt(),
        slow: (j['slow'] ?? 0).toInt(),
        note: j['note'] ?? '',
      );

  Shocks clone() => Shocks(total: total, fast: fast, slow: slow, note: note);
}

class MeasurementSet {
  ShockType shockType;
  Corner fl, fr, rl, rr;
  Shocks? sfl, sfr, srl, srr; // vain 3-tie
  DateTime createdAt;
  String? historyNote; // uusi: historia muistiinpano
  String? fileName; // uusi: PDF-tiedoston nimi

  MeasurementSet({
    required this.shockType,
    required this.fl,
    required this.fr,
    required this.rl,
    required this.rr,
    this.sfl,
    this.sfr,
    this.srl,
    this.srr,
    required this.createdAt,
    this.historyNote,
    this.fileName,
  });

  Map<String, dynamic> toJson() => {
        'shockType': shockTypeToStr(shockType),
        'fl': fl.toJson(),
        'fr': fr.toJson(),
        'rl': rl.toJson(),
        'rr': rr.toJson(),
        'sfl': sfl?.toJson(),
        'sfr': sfr?.toJson(),
        'srl': srl?.toJson(),
        'srr': srr?.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'historyNote': historyNote,
        'fileName': fileName,
      };

  static MeasurementSet fromJson(Map<String, dynamic> j) => MeasurementSet(
        shockType: shockTypeFromStr(j['shockType'] ?? 'three'),
        fl: Corner.fromJson(j['fl']),
        fr: Corner.fromJson(j['fr']),
        rl: Corner.fromJson(j['rl']),
        rr: Corner.fromJson(j['rr']),
        sfl: j['sfl'] != null ? Shocks.fromJson(j['sfl']) : null,
        sfr: j['sfr'] != null ? Shocks.fromJson(j['sfr']) : null,
        srl: j['srl'] != null ? Shocks.fromJson(j['srl']) : null,
        srr: j['srr'] != null ? Shocks.fromJson(j['srr']) : null,
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        historyNote: j['historyNote'],
        fileName: j['fileName'],
      );
}

class CarData {
  Car car;
  ShockType shockType;
  Corner fl, fr, rl, rr;
  Shocks sfl, sfr, srl, srr;
  List<MeasurementSet> history;

  CarData({
    required this.car,
    required this.shockType,
    required this.fl,
    required this.fr,
    required this.rl,
    required this.rr,
    required this.sfl,
    required this.sfr,
    required this.srl,
    required this.srr,
    required this.history,
  });

  Map<String, dynamic> toJson() => {
        'car': car.toJson(),
        'shockType': shockTypeToStr(shockType),
        'fl': fl.toJson(),
        'fr': fr.toJson(),
        'rl': rl.toJson(),
        'rr': rr.toJson(),
        'sfl': sfl.toJson(),
        'sfr': sfr.toJson(),
        'srl': srl.toJson(),
        'srr': srr.toJson(),
        'history': history.map((e) => e.toJson()).toList(),
      };

  static CarData fromJson(Map<String, dynamic> j) => CarData(
        car: Car.fromJson(j['car']),
        shockType: shockTypeFromStr(j['shockType'] ?? 'three'),
        fl: Corner.fromJson(j['fl']),
        fr: Corner.fromJson(j['fr']),
        rl: Corner.fromJson(j['rl']),
        rr: Corner.fromJson(j['rr']),
        sfl: Shocks.fromJson(j['sfl']),
        sfr: Shocks.fromJson(j['sfr']),
        srl: Shocks.fromJson(j['srl']),
        srr: Shocks.fromJson(j['srr']),
        history: (j['history'] as List? ?? [])
            .map((e) => MeasurementSet.fromJson(e))
            .toList(),
      );
}

class GarageStore {
  static const _key = 'garage_v1';

  Future<List<CarData>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return [
        CarData(
          car: Car(make: 'BMW', model: 'E36', surface: 'Sora/Jää', defaultShockType: ShockType.threeWay),
          shockType: ShockType.threeWay,
          fl: Corner(camber: -2.0, toeMm: 0.8, springMm: 25),
          fr: Corner(camber: -1.7, toeMm: 0.3, springMm: 26),
          rl: Corner(camber: -1.5, toeMm: -0.1, springMm: 29),
          rr: Corner(camber: -1.8, toeMm: -0.1, springMm: 27),
          sfl: Shocks(total: 32, fast: 10, slow: 18),
          sfr: Shocks(total: 35, fast: 12, slow: 16),
          srl: Shocks(total: 30, fast: 8, slow: 20),
          srr: Shocks(total: 34, fast: 9, slow: 19),
          history: [],
        ),
        CarData(
          car: Car(make: 'Toyota', model: 'GT86', surface: 'Asfaltti', defaultShockType: ShockType.oneWay),
          shockType: ShockType.oneWay,
          fl: Corner(camber: -1.5, toeMm: 0.4, springMm: 20),
          fr: Corner(camber: -1.5, toeMm: 0.4, springMm: 20),
          rl: Corner(camber: -1.2, toeMm: 0.2, springMm: 22),
          rr: Corner(camber: -1.2, toeMm: 0.2, springMm: 22),
          sfl: Shocks(total: 20, fast: 5, slow: 10),
          sfr: Shocks(total: 20, fast: 5, slow: 10),
          srl: Shocks(total: 18, fast: 4, slow: 9),
          srr: Shocks(total: 18, fast: 4, slow: 9),
          history: [],
        ),
      ];
    }
    final list = (jsonDecode(raw) as List)
        .map((e) => CarData.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<void> save(List<CarData> cars) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(cars.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}

/// ===== GARAGE PAGE =====
class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

/// ===== MAIN SHELL (CAR DETAIL) =====
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
  void initState() {
    super.initState();
    shockType = widget.data.shockType;
  }

  String _defaultFileName(CarData d) {
    final ts = DateTime.now().toLocal().toString().replaceAll(':', '-').split('.').first;
    return 'setup_${d.car.make}_${d.car.model}_$ts';
  }

  Future<void> _promptSaveToHistory() async {
    final nameDefault = _defaultFileName(widget.data);
    final nameCtrl = TextEditingController(text: nameDefault);
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Tallenna historiaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tiedoston nimi (ilman .pdf)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Muistiinpano historiaan'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Peruuta')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tallenna')),
        ],
      ),
    );
    if (ok == true) {
      final set = MeasurementSet(
        shockType: shockType,
        fl: widget.data.fl.clone(),
        fr: widget.data.fr.clone(),
        rl: widget.data.rl.clone(),
        rr: widget.data.rr.clone(),
        sfl: shockType == ShockType.threeWay ? widget.data.sfl.clone() : null,
        sfr: shockType == ShockType.threeWay ? widget.data.sfr.clone() : null,
        srl: shockType == ShockType.threeWay ? widget.data.srl.clone() : null,
        srr: shockType == ShockType.threeWay ? widget.data.srr.clone() : null,
        createdAt: DateTime.now(),
        historyNote: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        fileName: nameCtrl.text.trim().isEmpty ? nameDefault : nameCtrl.text.trim(),
      );
      widget.data.history.insert(0, set);
      widget.data.shockType = shockType;
      await widget.onSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tallennettu ✓ (lisätty historiaan)')),
        );
      }
      setState(() {});
    }
  }

  void _applyHistory(MeasurementSet m) {
    widget.data.fl = m.fl.clone();
    widget.data.fr = m.fr.clone();
    widget.data.rl = m.rl.clone();
    widget.data.rr = m.rr.clone();
    if (m.sfl != null) widget.data.sfl = m.sfl!.clone();
    if (m.sfr != null) widget.data.sfr = m.sfr!.clone();
    if (m.srl != null) widget.data.srl = m.srl!.clone();
    if (m.srr != null) widget.data.srr = m.srr!.clone();
    shockType = m.shockType;
    widget.data.shockType = m.shockType;
  }

  Future<void> _exportPdf(MeasurementSet set) async {
    final pdf = pw.Document();
    final title = set.fileName?.isNotEmpty == true ? set.fileName! : _defaultFileName(widget.data);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          final header = pw.Text('${widget.data.car.title} – ${widget.data.car.surface}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold));
          final ts = pw.Text('Päiväys: ${set.createdAt.toLocal()}');

          pw.Widget wheelTable(String title) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Kulma')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Camber (°)')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Toe (mm)')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Jousi (mm)')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Muistiinpano')),
                    ]),
                    ...[
                      ['FL', set.fl],
                      ['FR', set.fr],
                      ['RL', set.rl],
                      ['RR', set.rr],
                    ].map((e) => pw.TableRow(children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e[0] as String)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Corner).camber.toStringAsFixed(1))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Corner).toeMm.toStringAsFixed(1))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Corner).springMm.toStringAsFixed(0))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Corner).note)),
                        ])),
                  ],
                ),
              ],
            );
          }

          pw.Widget shockTable() {
            final has3 = set.shockType == ShockType.threeWay && set.sfl != null;
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Iskari (3-tie)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                if (!has3) pw.Text('Ei 3-tie-iskareita tälle asettelulle'),
                if (has3)
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
                    children: [
                      pw.TableRow(children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Kulma')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Kokonais')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Nopea')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Hidas')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Muistiinpano')),
                      ]),
                      ...[
                        ['FL', set.sfl!],
                        ['FR', set.sfr!],
                        ['RL', set.srl!],
                        ['RR', set.srr!],
                      ].map((e) => pw.TableRow(children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(e[0] as String)),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Shocks).total.toString())),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Shocks).fast.toString())),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Shocks).slow.toString())),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text((e[1] as Shocks).note)),
                          ])),
                    ],
                  ),
              ],
            );
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              header,
              ts,
              if (set.historyNote?.isNotEmpty == true) pw.Text('Historia: ${set.historyNote}'),
              pw.SizedBox(height: 12),
              pw.Expanded(child: wheelTable('Pyöränkulmat')),
              pw.SizedBox(height: 8),
              pw.Expanded(child: shockTable()),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: '$title.pdf');
  }

  Future<void> _openHistory() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final items = widget.data.history;
        if (items.isEmpty) {
          return SizedBox(
            height: 180,
            child: Center(
              child: Text('Ei tallennuksia vielä',
                  style: Theme.of(context).textTheme.labelSmall),
            ),
          );
        }
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final m = items[i];
              final ts = m.createdAt.toLocal().toString().split('.').first;
              final st = m.shockType == ShockType.threeWay ? '3-tie' : '1-tie';
              final title = m.fileName?.isNotEmpty == true ? m.fileName! : 'Tallennus $ts';
              final sub = 'Iskari: $st${m.historyNote?.isNotEmpty == true ? ' · ${m.historyNote}' : ''}';
              return ListTile(
                tileColor: const Color(0xFF12161C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: kOutline),
                ),
                leading: const Icon(Icons.history, color: kTextMuted),
                title: Text(title),
                subtitle: Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Muokkaa',
                      icon: const Icon(Icons.edit, color: kTextMuted),
                      onPressed: () async {
                        final nameCtrl = TextEditingController(text: m.fileName ?? _defaultFileName(widget.data));
                        final noteCtrl = TextEditingController(text: m.historyNote ?? '');
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (dctx) => AlertDialog(
                            backgroundColor: kCard,
                            title: const Text('Muokkaa tallennusta'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(decoration: const InputDecoration(labelText: 'Tiedoston nimi'), controller: nameCtrl),
                                const SizedBox(height: 8),
                                TextField(decoration: const InputDecoration(labelText: 'Muistiinpano'), controller: noteCtrl, maxLines: 3),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Peruuta')),
                              FilledButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Tallenna')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          setState(() {
                            m.fileName = nameCtrl.text.trim();
                            m.historyNote = noteCtrl.text.trim();
                          });
                          await widget.onSaved();
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Lataa',
                      icon: const Icon(Icons.download, color: kTextMuted),
                      onPressed: () async {
                        _applyHistory(m);
                        if (mounted) Navigator.pop(ctx);
                        setState(() {});
                        await widget.onSaved();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Historia-asetus ladattu')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'PDF',
                      icon: const Icon(Icons.picture_as_pdf, color: kPrimary),
                      onPressed: () async {
                        await _exportPdf(m);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const Tab(text: 'Pyöränkulmat'),
      if (shockType == ShockType.threeWay) const Tab(text: 'Iskari 3-tie'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBg,
          elevation: 0,
          title: Text(widget.data.car.title),
          actions: [
            IconButton(
              tooltip: 'Historia',
              icon: const Icon(Icons.history),
              onPressed: _openHistory,
            ),
            IconButton(
              tooltip: 'PDF (nykyinen)',
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                final temp = MeasurementSet(
                  shockType: shockType,
                  fl: widget.data.fl,
                  fr: widget.data.fr,
                  rl: widget.data.rl,
                  rr: widget.data.rr,
                  sfl: shockType == ShockType.threeWay ? widget.data.sfl : null,
                  sfr: shockType == ShockType.threeWay ? widget.data.sfr : null,
                  srl: shockType == ShockType.threeWay ? widget.data.srl : null,
                  srr: shockType == ShockType.threeWay ? widget.data.srr : null,
                  createdAt: DateTime.now(),
                  fileName: _defaultFileName(widget.data),
                );
                await _exportPdf(temp);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SegmentedButton<ShockType>(
                segments: const [
                  ButtonSegment(value: ShockType.oneWay, label: Text('1-tie')),
                  ButtonSegment(value: ShockType.threeWay, label: Text('3-tie')),
                ],
                selected: {shockType},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected) ? kCard : kBg,
                  ),
                  foregroundColor: const WidgetStatePropertyAll<Color>(kTextMain),
                ),
                onSelectionChanged: (set) => setState(() {
                  shockType = set.first;
                }),
              ),
            ),
          ],
          bottom: TabBar(tabs: tabs, indicatorColor: kPrimary),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WheelPage(data: widget.data, onChanged: () => setState(() {})),
            if (shockType == ShockType.threeWay)
              ShockPage(data: widget.data, onChanged: () => setState(() {})),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Peruutettu')),
                    );
                    setState(() {});
                  },
                  child: const Text('Peruuta'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _promptSaveToHistory,
                  child: const Text('Tallenna'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaragePageState extends State<GaragePage> {
  final store = GarageStore();
  List<CarData> cars = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    cars = await store.load();
    setState(() => loading = false);
  }

  Future<void> _save() async => store.save(cars);

  Future<void> _addCarDialog() async {
    final makeCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    String surface = 'Asfaltti';
    ShockType sType = ShockType.threeWay;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Lisää auto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Merkki'), controller: makeCtrl),
            TextField(decoration: const InputDecoration(labelText: 'Malli'), controller: modelCtrl),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: surface,
              dropdownColor: kCard,
              decoration: const InputDecoration(labelText: 'Pinta'),
              items: const [
                DropdownMenuItem(value: 'Asfaltti', child: Text('Asfaltti')),
                DropdownMenuItem(value: 'Sora/Jää', child: Text('Sora/Jää')),
              ],
              onChanged: (v) => surface = v ?? 'Asfaltti',
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ShockType>(
              value: sType,
              dropdownColor: kCard,
              decoration: const InputDecoration(labelText: 'Iskari tyyppi'),
              items: const [
                DropdownMenuItem(value: ShockType.oneWay, child: Text('1-tie')),
                DropdownMenuItem(value: ShockType.threeWay, child: Text('3-tie')),
              ],
              onChanged: (v) => sType = v ?? ShockType.threeWay,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Peruuta')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lisää')),
        ],
      ),
    );

    if (ok == true && makeCtrl.text.isNotEmpty && modelCtrl.text.isNotEmpty) {
      setState(() {
        cars.add(CarData(
          car: Car(make: makeCtrl.text.trim(), model: modelCtrl.text.trim(), surface: surface, defaultShockType: sType),
          shockType: sType,
          fl: Corner(camber: 0, toeMm: 0, springMm: 0),
          fr: Corner(camber: 0, toeMm: 0, springMm: 0),
          rl: Corner(camber: 0, toeMm: 0, springMm: 0),
          rr: Corner(camber: 0, toeMm: 0, springMm: 0),
          sfl: Shocks(total: 0, fast: 0, slow: 0),
          sfr: Shocks(total: 0, fast: 0, slow: 0),
          srl: Shocks(total: 0, fast: 0, slow: 0),
          srr: Shocks(total: 0, fast: 0, slow: 0),
          history: [],
        ));
      });
      await _save();
    }
  }

  Future<void> _deleteCar(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Poista ajoneuvo?'),
        content: Text('Poistetaanko ${cars[index].car.title}? Tätä ei voi kumota.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Peruuta')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Poista'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() { cars.removeAt(index); });
      await _save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajoneuvo poistettu')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Oma autotalli')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCarDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: cars.length,
        itemBuilder: (_, i) {
          final d = cars[i];
          return ListTile(
            tileColor: kCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: kOutline),
            ),
            leading: const Icon(Icons.directions_car_filled, color: kTextMuted),
            title: Text(d.car.title),
            subtitle: Text('Pinta: ${d.car.surface}  ·  Iskari: ${d.car.defaultShockType == ShockType.threeWay ? '3-tie' : '1-tie'}  ·  Historia: ${d.history.length}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Poista',
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE74C3C)),
                  onPressed: () => _deleteCar(i),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => HomeShell(
                  data: d,
                  onSaved: () async {
                    await _save();
                    setState(() {});
                  },
                ),
              ));
            },
          );
        },
      ),
    );
  }
}
