import 'package:flutter/material.dart';

const kBg = Color(0xFF0E1013);
const kCard = Color(0xFF171A20);
const kOutline = Color(0xFF252830);
const kPrimary = Color(0xFF4DA3FF);
const kTextMain = Color(0xFFE8ECF1);
const kTextMuted = Color(0xFFA1A8B0);

class CardPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double? width;
  const CardPanel({super.key, required this.title, required this.subtitle, required this.child, this.width});
  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 700;
    final panelWidth = width ?? (isPhone ? 240.0 : 260.0);
    return Container(
      width: panelWidth,
      padding: EdgeInsets.all(isPhone ? 10 : 12),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kOutline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.article_rounded, size: 16, color: kTextMuted), const SizedBox(width: 6), Text(title, style: Theme.of(context).textTheme.titleMedium)]),
        Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
        const Divider(height: 20, color: kOutline),
        child,
      ]),
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
  const StepperField({super.key, required this.label, required this.value, required this.onChanged, this.unit = '', this.min = -9999, this.max = 9999, this.step = 1, this.fractionDigits = 0});
  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 700;
    final text = value.toStringAsFixed(fractionDigits);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.1)),
        const SizedBox(height: 6),
        Row(children: [
          _roundBtn(Icons.remove, () { final v = (value - step).clamp(min, max); onChanged(v); }),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final ctrl = TextEditingController(text: text.replaceAll('.', ','));
                final v = await showDialog<double>(
                  context: context,
                  builder: (ctx) => _NumberDialog(title: label, controller: ctrl, fractionDigits: fractionDigits, unit: unit),
                );
                if (v != null) onChanged(v.clamp(min, max));
              },
              child: Container(
                height: isPhone ? 40 : 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFF0F1217), borderRadius: BorderRadius.circular(10), border: Border.all(color: kOutline)),
                child: Text(unit.isEmpty ? text : '$text $unit', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _roundBtn(Icons.add, () { final v = (value + step).clamp(min, max); onChanged(v); }),
        ]),
      ]),
    );
  }
  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    final isPhone = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio < 700;
    return SizedBox(
      width: isPhone ? 40 : 44,
      height: isPhone ? 40 : 44,
      child: Material(color: const Color(0xFF10141A), borderRadius: BorderRadius.circular(10), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Icon(icon, color: kTextMain, size: 20))),
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
      content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true), style: const TextStyle(color: kTextMain), decoration: InputDecoration(hintText: '0${unit.isEmpty ? '' : ' $unit'}')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Peruuta')), FilledButton(onPressed: () { final raw = controller.text.replaceAll(',', '.'); final v = double.tryParse(raw); Navigator.pop(context, v); }, child: const Text('OK'))],
    );
  }
}
