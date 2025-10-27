import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';

class WheelPage extends StatelessWidget {
  final CarData data;
  final VoidCallback onChanged;
  const WheelPage({super.key, required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 700;
    final hPad = isPhone ? 12.0 : 24.0;
    final panelWidth = isPhone ? 240.0 : 260.0;
    const gap = 6.0;
    const minNoteWidth = 140.0;
    final maxNoteWidth = isPhone ? 180.0 : 200.0;

    Widget fields(Corner c) => Column(children: [
          StepperField(label: 'Camber (°)', value: c.camber, min: -10, max: 10, step: 0.1, fractionDigits: 1, onChanged: (v) { c.camber = _round1(v); onChanged(); }),
          StepperField(label: 'Toe (mm)', value: c.toeMm, min: -10, max: 10, step: 0.1, fractionDigits: 1, onChanged: (v) { c.toeMm = _round1(v); onChanged(); }),
          StepperField(label: 'Jousi (mm)', value: c.springMm, min: -100, max: 1000, step: 1, fractionDigits: 0, onChanged: (v) { c.springMm = v.roundToDouble(); onChanged(); }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () async {
              final ctrl = TextEditingController(text: c.note);
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: kCard,
                  title: const Text('Muistiinpano'),
                  content: TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Mittaustapa / huomio (max 200)')),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Peruuta')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tallenna'))],
                ),
              );
              if (ok == true) { c.note = ctrl.text.trim(); onChanged(); }
            },
            icon: const Icon(Icons.note_add_outlined, color: kTextMuted, size: 18),
            label: const Text('Note', style: TextStyle(color: kTextMuted)),
          ),
        ]);

    Widget cornerPanel(String code, String pos, Corner c, {required bool noteOnRight, bool inlineAllowed = true}) {
      final note = c.note.trim();
      final halfWidth = (w - 2 * hPad) / 2;
      final avail = halfWidth - panelWidth - gap;
      final inline = inlineAllowed && note.isNotEmpty && avail >= minNoteWidth;
      final noteWidth = inline ? avail.clamp(minNoteWidth, maxNoteWidth) : maxNoteWidth;

      final noteBox = Container(
        width: noteWidth,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kOutline)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.sticky_note_2_outlined, size: isPhone ? 14 : 16, color: kTextMuted),
            SizedBox(width: isPhone ? 4 : 6),
            const Text('Muistiinpano', style: TextStyle(color: kTextMuted, fontSize: 12)),
          ]),
          const SizedBox(height: 6),
          Text(note, style: const TextStyle(fontSize: 11)),
        ]),
      );

      if (note.isEmpty || !inline) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardPanel(title: code, subtitle: pos, child: fields(c)),
          if (note.isNotEmpty) ...[const SizedBox(height: 8), noteBox],
      ]);
      }

      return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!noteOnRight) ...[noteBox, const SizedBox(width: gap)],
        CardPanel(title: code, subtitle: pos, child: fields(c)),
        if (noteOnRight) ...[const SizedBox(width: gap), noteBox],
      ]);
    }

    Widget infoCard() => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kOutline)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _axleLine('Etuakseli total toe', data.fl.toeMm + data.fr.toeMm),
            const SizedBox(height: 8),
            _axleLine('Taka-akseli total toe', data.rl.toeMm + data.rr.toeMm),
            const SizedBox(height: 8),
            Text('Pinta: ${data.car.surface}', style: const TextStyle(color: kTextMuted, fontSize: 12)),
          ]),
        );

    if (isPhone) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            infoCard(),
            const SizedBox(height: 12),
            cornerPanel('FL', 'Etu-vasen', data.fl, noteOnRight: true, inlineAllowed: false),
            const SizedBox(height: 12),
            cornerPanel('FR', 'Etu-oikea', data.fr, noteOnRight: false, inlineAllowed: false),
            const SizedBox(height: 12),
            cornerPanel('RL', 'Taka-vasen', data.rl, noteOnRight: true, inlineAllowed: false),
            const SizedBox(height: 12),
            cornerPanel('RR', 'Taka-oikea', data.rr, noteOnRight: false, inlineAllowed: false),
            const SizedBox(height: 24),
          ]),
        ),
      );
    }

    return Stack(children: [
      Positioned(top: 24, left: hPad, child: cornerPanel('FL', 'Etu-vasen', data.fl, noteOnRight: true)),
      Positioned(top: 24, right: hPad, child: cornerPanel('FR', 'Etu-oikea', data.fr, noteOnRight: false)),
      Positioned(bottom: 24, left: hPad, child: cornerPanel('RL', 'Taka-vasen', data.rl, noteOnRight: true)),
      Positioned(bottom: 24, right: hPad, child: cornerPanel('RR', 'Taka-oikea', data.rr, noteOnRight: false)),
      Align(
        alignment: const Alignment(0, -0.35),
        child: infoCard(),
      ),
    ]);
  }
}

Widget _axleLine(String label, double value) {
  final text = value.toStringAsFixed(1);
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Text('$label (mm): ', style: const TextStyle(color: kTextMuted)),
    const Icon(Icons.arrow_right_alt, color: Colors.white, size: 18),
    Text(text),
  ]);
}

double _round1(double v) => (v * 10).roundToDouble() / 10.0;
