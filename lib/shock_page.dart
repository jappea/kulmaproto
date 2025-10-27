import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';

class ShockPage extends StatelessWidget {
  final CarData data;
  final VoidCallback onChanged;
  const ShockPage({super.key, required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 700;
    final hPad = isPhone ? 12.0 : 24.0;
    final panelWidth = isPhone ? 240.0 : 260.0;
    const gap = 6.0;
    const minNoteWidth = 140.0;
    final maxNoteWidth = isPhone ? 180.0 : 200.0;

    Widget controls(String code, String pos, Shocks s) => CardPanel(title: code, subtitle: pos, child: Column(children: [
          StepperField(label: 'Kokonaisklikit', value: s.total.toDouble(), min: 0, max: 50, step: 1, fractionDigits: 0, onChanged: (v) { s.total = v.round().clamp(0, 50); onChanged(); }),
          StepperField(label: 'Nopea', value: s.fast.toDouble(), min: 0, max: 50, step: 1, fractionDigits: 0, onChanged: (v) { s.fast = v.round().clamp(0, 50); onChanged(); }),
          StepperField(label: 'Hidas', value: s.slow.toDouble(), min: 0, max: 50, step: 1, fractionDigits: 0, onChanged: (v) { s.slow = v.round().clamp(0, 50); onChanged(); }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () async {
              final ctrl = TextEditingController(text: s.note);
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: kCard,
                  title: const Text('Muistiinpano'),
                  content: TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Klikkien mittaustapa / huomio')),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Peruuta')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tallenna'))],
                ),
              );
              if (ok == true) { s.note = ctrl.text.trim(); onChanged(); }
            },
            icon: const Icon(Icons.note_add_outlined, color: kTextMuted, size: 18),
            label: const Text('Note', style: TextStyle(color: kTextMuted)),
          ),
        ]));

    Widget panel(String code, String pos, Shocks s, {required bool noteOnRight, bool inlineAllowed = true}) {
      final note = s.note.trim();
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
          controls(code, pos, s),
          if (note.isNotEmpty) ...[const SizedBox(height: 8), noteBox],
        ]);
      }
      return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!noteOnRight) ...[noteBox, const SizedBox(width: gap)],
        controls(code, pos, s),
        if (noteOnRight) ...[const SizedBox(width: gap), noteBox],
      ]);
    }

    if (isPhone) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            panel('FL', 'Etu-vasen', data.sfl, noteOnRight: true, inlineAllowed: false),
            const SizedBox(height: 12),
            panel('FR', 'Etu-oikea', data.sfr, noteOnRight: false, inlineAllowed: false),
            const SizedBox(height: 12),
            panel('RL', 'Taka-vasen', data.srl, noteOnRight: true, inlineAllowed: false),
            const SizedBox(height: 12),
            panel('RR', 'Taka-oikea', data.srr, noteOnRight: false, inlineAllowed: false),
            const SizedBox(height: 24),
          ]),
        ),
      );
    }

    return Stack(children: [
      Positioned(top: 24, left: hPad, child: panel('FL', 'Etu-vasen', data.sfl, noteOnRight: true)),
      Positioned(top: 24, right: hPad, child: panel('FR', 'Etu-oikea', data.sfr, noteOnRight: false)),
      Positioned(bottom: 24, left: hPad, child: panel('RL', 'Taka-vasen', data.srl, noteOnRight: true)),
      Positioned(bottom: 24, right: hPad, child: panel('RR', 'Taka-oikea', data.srr, noteOnRight: false)),
    ]);
  }
}
