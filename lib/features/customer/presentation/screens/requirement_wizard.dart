import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/customer_providers.dart';

class _WizardPage extends StatelessWidget {
  final Widget child;
  const _WizardPage({required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        child: child,
      ),
    ),
  );
}

class _CHead extends StatelessWidget {
  final VoidCallback onBack;
  const _CHead({required this.onBack});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14, top: 4),
    child: Row(children: [
      InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(6),
        child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_back, size: 16, color: AppColors.primary)),
      ),
      Expanded(
        child: Center(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
              children: const [TextSpan(text: 'Marquee'), TextSpan(text: 'Finder', style: TextStyle(color: AppColors.gold))],
            ),
          ),
        ),
      ),
      const SizedBox(width: 30),
    ]),
  );
}

class _StepperBar extends StatelessWidget {
  final int step;
  const _StepperBar(this.step);
  @override
  Widget build(BuildContext context) {
    const labels = ['Event', 'Menu', 'Services', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      child: SizedBox(
        height: 46,
        child: Stack(children: [
          Positioned(top: 13, left: 16, right: 16, child: Container(height: 2, color: AppColors.border)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(4, (i) {
              final n = i + 1;
              final active = n == step;
              final done = n < step;
              final filled = active || done;
              return SizedBox(
                width: 60,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.primary : Colors.white,
                      border: Border.all(color: filled ? AppColors.primary : AppColors.border, width: 2),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : Text('$n', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: filled ? Colors.white : AppColors.textMuted)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: filled ? AppColors.primary : AppColors.textMuted, fontWeight: filled ? FontWeight.w600 : FontWeight.w500)),
                ]),
              );
            }),
          ),
        ]),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String stepLabel;
  final Widget body;
  const _FormCard({required this.icon, required this.title, required this.stepLabel, required this.body});
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 15, offset: Offset(0, 4))],
    ),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(color: AppColors.soft, border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Spacer(),
          Text(stepLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: body),
    ]),
  );
}

class _Lbl extends StatelessWidget {
  final String text;
  const _Lbl(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.text),
        children: [TextSpan(text: '$text '), const TextSpan(text: '*', style: TextStyle(color: AppColors.red))],
      ),
    ),
  );
}

class _IconField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  const _IconField({required this.controller, required this.icon, required this.hint, this.keyboardType, this.onChanged, this.inputFormatters});
  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const SizedBox(width: 14),
      Icon(icon, size: 15, color: AppColors.primary),
      const SizedBox(width: 13),
      Expanded(
        child: TextField(
          controller: controller, keyboardType: keyboardType, onChanged: onChanged, inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: AppColors.text),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      ),
      const SizedBox(width: 14),
    ]),
  );
}

class _EventTypeDropdown extends ConsumerWidget {
  final AsyncValue<List<dynamic>> events;
  const _EventTypeDropdown({required this.events});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(reqDraftProvider);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.event, size: 15, color: AppColors.primary),
        const SizedBox(width: 13),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Type', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              value: draft.eventType,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 18),
              items: events.when(
                loading: () => const <DropdownMenuItem<String>>[],
                error: (_, __) => const <DropdownMenuItem<String>>[],
                data: (list) => list.map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(value: e.name as String, child: Text(e.name as String))).toList(),
              ),
              onChanged: (v) => ref.read(reqDraftProvider.notifier).setEventType(v ?? ''),
            ),
          ),
        ),
      ]),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  const _DateField({required this.date, required this.onPick});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: DateTime.now());
      if (d != null) onPick(d);
    },
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.calendar_today, size: 15, color: AppColors.primary),
        const SizedBox(width: 13),
        Text(date == null ? 'Select Date' : fmtDate(date!.toIso8601String()), style: TextStyle(fontSize: 14, color: date == null ? AppColors.textMuted : AppColors.text)),
        const Spacer(),
        const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 18),
      ]),
    ),
  );
}

class _DurBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _DurBtn({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.text))),
      ),
    ),
  );
}

class _TimeNum extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const _TimeNum({required this.controller, required this.hint, this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 64,
    child: TextField(
      controller: controller, keyboardType: TextInputType.number, textAlign: TextAlign.center, onChanged: onChanged,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      ),
    ),
  );
}

class _ApPmDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ApPmDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true, value: value,
        items: const [DropdownMenuItem(value: 'AM', child: Text('AM')), DropdownMenuItem(value: 'PM', child: Text('PM'))],
        onChanged: (v) => onChanged(v ?? 'PM'),
        style: const TextStyle(fontSize: 14, color: AppColors.text),
      ),
    ),
  );
}

class _BudgetField extends ConsumerWidget {
  final TextEditingController controller;
  const _BudgetField({required this.controller});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    height: 48,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(color: AppColors.soft, border: Border(right: BorderSide(color: AppColors.border))),
        child: const Center(child: Text('PKR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))),
      ),
      Expanded(
        child: TextField(
          controller: controller, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => ref.read(reqDraftProvider.notifier).setBudget(num.tryParse(v) ?? 0),
          style: const TextStyle(fontSize: 14, color: AppColors.text),
          decoration: const InputDecoration(hintText: 'e.g. 500000', hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted), border: InputBorder.none, isCollapsed: true, contentPadding: EdgeInsets.symmetric(horizontal: 14)),
        ),
      ),
    ]),
  );
}

class _GridCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const _GridCard({required this.imageUrl, required this.name, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        borderRadius: BorderRadius.circular(10),
        color: selected ? const Color(0xFFF0FDF4) : Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Column(children: [
          Expanded(child: Image.network(imageUrl ?? '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: AppColors.soft))),
          Padding(padding: const EdgeInsets.all(4), child: Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600))),
        ]),
        Positioned(top: 5, right: 5, child: Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.black.withOpacity(0.35),
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: selected ? const Icon(Icons.check, size: 11, color: Colors.white) : null,
        )),
      ]),
    ),
  );
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool busy;
  const _PrimaryBtn({required this.label, required this.icon, required this.onTap, this.busy = false});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
      child: busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Icon(icon, color: Colors.white, size: 15),
            ]),
    ),
  );
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _ReviewBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onEdit;
  final Widget child;
  const _ReviewBlock({required this.icon, required this.title, required this.onEdit, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: const BoxDecoration(color: AppColors.soft, border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 15),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Spacer(),
          InkWell(
            onTap: onEdit,
            child: const Row(children: [
              Icon(Icons.edit, size: 12, color: AppColors.primary),
              SizedBox(width: 5),
              Text('Edit', style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(14), child: child),
    ]),
  );
}

class _ReviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ReviewItem({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: AppColors.primary, size: 15),
    const SizedBox(width: 8),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text)),
    ])),
  ]);
}

class _ChipsRow extends StatelessWidget {
  final List<String> items;
  const _ChipsRow({required this.items});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('None', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted));
    return Wrap(spacing: 8, runSpacing: 8, children: items.map((name) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check, size: 12, color: AppColors.primary), const SizedBox(width: 6),
        Text(name, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
      ]),
    )).toList());
  }
}

class ReqStep1Screen extends ConsumerStatefulWidget {
  const ReqStep1Screen({super.key});
  @override ConsumerState<ReqStep1Screen> createState() => _ReqStep1State();
}

class _ReqStep1State extends ConsumerState<ReqStep1Screen> {
  final location = TextEditingController(); final guests = TextEditingController(); final budget = TextEditingController();
  final startH = TextEditingController(); final startM = TextEditingController(); final endH = TextEditingController(); final endM = TextEditingController();
  String startAp = 'PM'; String endAp = 'PM'; DateTime? date; bool isFullDay = false;

  @override void dispose() { location.dispose(); guests.dispose(); budget.dispose(); startH.dispose(); startM.dispose(); endH.dispose(); endM.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventTypesProvider);
    return _WizardPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CHead(onBack: () => context.go('/customer/home')),
      Text('Create Requirement', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 4),
      const Text('Tell us about your event', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4)),
      const _StepperBar(1),
      _FormCard(
        icon: Icons.event_note, title: 'Event Details', stepLabel: '1 of 4',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _Lbl('Event Type'), _EventTypeDropdown(events: events), const SizedBox(height: 14),
          const _Lbl('Event Date'), _DateField(date: date, onPick: (d) { setState(() => date = d); ref.read(reqDraftProvider.notifier).setDate(d.toIso8601String().substring(0, 10)); }), const SizedBox(height: 14),
          const _Lbl('Event Duration'),
          Row(children: [
            _DurBtn(label: 'Custom Time', active: !isFullDay, onTap: () { setState(() => isFullDay = false); ref.read(reqDraftProvider.notifier).setFullDay(false); }),
            const SizedBox(width: 8),
            _DurBtn(label: '24 Hours / Full Day', active: isFullDay, onTap: () { setState(() => isFullDay = true); ref.read(reqDraftProvider.notifier).setFullDay(true); }),
          ]),
          if (!isFullDay) ...[
            const SizedBox(height: 14), const _Lbl('Start Time'),
            Row(children: [
              _TimeNum(controller: startH, hint: 'HH', onChanged: (v) => ref.read(reqDraftProvider.notifier).setStart(v, startM.text, startAp)),
              const SizedBox(width: 6), const Text(':', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)), const SizedBox(width: 6),
              _TimeNum(controller: startM, hint: 'MM', onChanged: (v) => ref.read(reqDraftProvider.notifier).setStart(startH.text, v, startAp)),
              const SizedBox(width: 6),
              Expanded(child: _ApPmDropdown(value: startAp, onChanged: (v) { setState(() => startAp = v); ref.read(reqDraftProvider.notifier).setStart(startH.text, startM.text, startAp); })),
            ]),
            const SizedBox(height: 14), const _Lbl('End Time'),
            Row(children: [
              _TimeNum(controller: endH, hint: 'HH', onChanged: (v) => ref.read(reqDraftProvider.notifier).setEnd(v, endM.text, endAp)),
              const SizedBox(width: 6), const Text(':', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)), const SizedBox(width: 6),
              _TimeNum(controller: endM, hint: 'MM', onChanged: (v) => ref.read(reqDraftProvider.notifier).setEnd(endH.text, v, endAp)),
              const SizedBox(width: 6),
              Expanded(child: _ApPmDropdown(value: endAp, onChanged: (v) { setState(() => endAp = v); ref.read(reqDraftProvider.notifier).setEnd(endH.text, endM.text, endAp); })),
            ]),
          ],
          const SizedBox(height: 14), const _Lbl('Total Guests'),
          _IconField(controller: guests, icon: Icons.people, hint: 'e.g. 300', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], onChanged: (v) => ref.read(reqDraftProvider.notifier).setGuests(int.tryParse(v) ?? 0)),
          const SizedBox(height: 14), const _Lbl('Budget (PKR)'), _BudgetField(controller: budget), const SizedBox(height: 14),
          const _Lbl('Location'), _IconField(controller: location, icon: Icons.location_on, hint: 'e.g. DHA, Lahore', onChanged: (v) => ref.read(reqDraftProvider.notifier).setLocation(v)),
        ]),
      ),
      const SizedBox(height: 16),
      _PrimaryBtn(label: 'Next', icon: Icons.arrow_forward, onTap: () {
        final d = ref.read(reqDraftProvider);
        if (d.eventType == null || d.eventDate == null || (!d.isFullDay && (d.startHour == null || d.endHour == null)) || d.guests <= 0 || d.budget <= 0 || (d.location?.isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all required fields'))); return;
        }
        context.go('/customer/req/2');
      }),
    ]));
  }
}

class ReqStep2Screen extends ConsumerStatefulWidget {
  const ReqStep2Screen({super.key});
  @override ConsumerState<ReqStep2Screen> createState() => _ReqStep2State();
}
class _ReqStep2State extends ConsumerState<ReqStep2Screen> {
  String? activeCat;
  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(parentCategoriesProvider); final draft = ref.watch(reqDraftProvider);
    return _WizardPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CHead(onBack: () => context.go('/customer/req/1')),
      Text('Menu Preferences', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 4), const Text("Select items you'd like", style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4)),
      const _StepperBar(2),
      _FormCard(icon: Icons.restaurant, title: 'Menu', stepLabel: '2 of 4', body: cats.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
        error: (e, _) => Text('$e'),
        data: (list) {
          if (list.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('No catalog available', textAlign: TextAlign.center));
          activeCat ??= list.first.id;
          final itemsAsync = ref.watch(itemsForCategoryProvider(activeCat!));
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 40, child: ListView.separated(
              scrollDirection: Axis.horizontal, itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final sel = activeCat == list[i].id;
                return GestureDetector(
                  onTap: () => setState(() => activeCat = list[i].id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, border: Border.all(color: sel ? AppColors.primary : AppColors.border), borderRadius: BorderRadius.circular(18)),
                    child: Text(list[i].name, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: sel ? Colors.white : AppColors.text)),
                  ),
                );
              },
            )),
            const SizedBox(height: 12),
            Row(children: [
              Text(list.firstWhere((c) => c.id == activeCat).name, style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const Spacer(),
              Text('${draft.menuItemIds.length} selected', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ]),
            const SizedBox(height: 10),
            itemsAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
              error: (e, _) => Text('$e'),
              data: (items) => GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
                itemCount: items.length,
                itemBuilder: (_, i) => _GridCard(imageUrl: items[i].imageUrl, name: items[i].name, selected: draft.menuItemIds.contains(items[i].id), onTap: () => ref.read(reqDraftProvider.notifier).toggleMenu(items[i].id)),
              ),
            ),
          ]);
        },
      )),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _OutlineBtn(label: 'Back', icon: Icons.arrow_back, onTap: () => context.go('/customer/req/1'))),
        const SizedBox(width: 10),
        Expanded(child: _PrimaryBtn(label: 'Next', icon: Icons.arrow_forward, onTap: () => context.go('/customer/req/3'))),
      ]),
    ]));
  }
}

class ReqStep3Screen extends ConsumerWidget {
  const ReqStep3Screen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svcs = ref.watch(servicesCatalogProvider); final draft = ref.watch(reqDraftProvider);
    return _WizardPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CHead(onBack: () => context.go('/customer/req/2')),
      Text('Additional Services', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 4), const Text('Select services you need', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4)),
      const _StepperBar(3),
      _FormCard(icon: Icons.settings, title: 'Services', stepLabel: '3 of 4', body: svcs.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
        error: (e, _) => Text('$e'),
        data: (list) => GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
          itemCount: list.length,
          itemBuilder: (_, i) => _GridCard(imageUrl: list[i].imageUrl, name: list[i].name, selected: draft.serviceIds.contains(list[i].id), onTap: () => ref.read(reqDraftProvider.notifier).toggleService(list[i].id)),
        ),
      )),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _OutlineBtn(label: 'Back', icon: Icons.arrow_back, onTap: () => context.go('/customer/req/2'))),
        const SizedBox(width: 10),
        Expanded(child: _PrimaryBtn(label: 'Next', icon: Icons.arrow_forward, onTap: () => context.go('/customer/req/4'))),
      ]),
    ]));
  }
}

class ReqStep4Screen extends ConsumerStatefulWidget {
  const ReqStep4Screen({super.key});
  @override ConsumerState<ReqStep4Screen> createState() => _ReqStep4State();
}
class _ReqStep4State extends ConsumerState<ReqStep4Screen> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final d = ref.watch(reqDraftProvider);
    return _WizardPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CHead(onBack: () => context.go('/customer/req/3')),
      Text('Review & Submit', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 4), const Text('Review your selections', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4)),
      const _StepperBar(4),
      _ReviewBlock(icon: Icons.event_note, title: 'Event', onEdit: () => context.go('/customer/req/1'), child: Column(children: [
        Row(children: [
          Expanded(child: _ReviewItem(icon: Icons.calendar_today, label: 'Date', value: fmtDate(d.eventDate))),
          Expanded(child: _ReviewItem(icon: Icons.people, label: 'Guests', value: '${d.guests}')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ReviewItem(icon: Icons.location_on, label: 'Location', value: d.location ?? '-')),
          Expanded(child: _ReviewItem(icon: Icons.access_time, label: 'Time', value: d.timeString)),
        ]),
        const SizedBox(height: 12),
        _ReviewItem(icon: Icons.wallet, label: 'Budget', value: money(d.budget)),
      ])),
      _ReviewBlock(
        icon: Icons.restaurant, 
        title: 'Menu', 
        onEdit: () => context.go('/customer/req/2'), 
        child: ref.watch(allMenuItemsProvider).when(
          loading: () => const SizedBox(),
          error: (_, __) => const Text('Error'),
          data: (allItems) => _ChipsRow(items: d.menuItemIds.map((id) { final match = allItems.where((x) => x.id == id); return match.isNotEmpty ? match.first.name : 'Unknown'; }).toList()),
        ),
      ),
      _ReviewBlock(
        icon: Icons.settings, 
        title: 'Services', 
        onEdit: () => context.go('/customer/req/3'), 
        child: ref.watch(servicesCatalogProvider).when(
          loading: () => const SizedBox(),
          error: (_, __) => const Text('Error'),
          data: (allSvcs) => _ChipsRow(items: d.serviceIds.map((id) { final match = allSvcs.where((x) => x.id == id); return match.isNotEmpty ? match.first.name : 'Unknown'; }).toList()),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _OutlineBtn(label: 'Back', icon: Icons.arrow_back, onTap: () => context.go('/customer/req/3'))),
        const SizedBox(width: 10),
        Expanded(child: _PrimaryBtn(
          label: 'Submit', icon: Icons.check, busy: busy,
          onTap: busy ? null : () async {
            setState(() => busy = true);
            try {
              final user = ref.read(supabaseProvider).auth.currentUser;
              if (user == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session expired. Please log in again.'), backgroundColor: AppColors.red));
                  context.go('/customer/home'); // Changed from /login to avoid route crash
                }
                setState(() => busy = false);
                return;
              }

              final menu = d.menuItemIds.map((id) => {'catalog_item_id': id}).toList();
              final allSvcs = ref.read(servicesCatalogProvider).value ?? [];
              final svcs = d.serviceIds.map((id) {
                final s = allSvcs.where((x) => x.id == id);
                return s.isNotEmpty ? {'key': s.first.key, 'name': s.first.name} : null;
              }).whereType<Map<String, dynamic>>().toList();

              await ref.read(supabaseProvider).rpc('create_requirement', params: {
                'p_event_type': d.eventType, 'p_event_date': d.eventDate, 'p_event_time': d.timeString,
                'p_guests': d.guests, 'p_budget': d.budget, 'p_location': d.location,
                'p_special_requests': null, 'p_menu_items': menu, 'p_services': svcs,
              });
              ref.read(reqDraftProvider.notifier).reset();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requirement Submitted!'), backgroundColor: AppColors.green));
              context.go('/customer/proposals');
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.red));
            } finally {
              if (mounted) setState(() => busy = false);
            }
          },
        )),
      ]),
    ]));
  }
}
