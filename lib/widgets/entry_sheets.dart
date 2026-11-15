import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import 'quick_form.dart';

/// Abre um painel (bottom sheet) com título e o conteúdo informado.
Future<T?> showFormSheet<T>(BuildContext context, {required String title, required Widget child}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppText.heading.copyWith(fontSize: 22)),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    ),
  );
}

/// Fecha o painel mostrando o feedback visual (SnackBar) ao usuário.
void _finish(BuildContext context, String message) {
  if (!context.mounted) return;
  showAppSnack(context, message);
  Navigator.of(context).pop();
}

Future<void> showFoodSheet(BuildContext context) {
  return showFormSheet<void>(
    context,
    title: 'Adicionar alimento',
    child: Builder(
      builder: (sheetContext) => QuickForm(
        submitLabel: 'Salvar alimento',
        fields: const [
          FieldSpec('Alimento', hint: 'Ex.: Arroz com feijão', autofocus: true),
          FieldSpec('Quantidade ou porção', hint: 'Ex.: 1 prato, 100 g'),
          FieldSpec('Calorias', kind: FieldKind.integer, suffix: 'kcal', min: 0, max: 10000),
        ],
        onSubmit: (v) async {
          await appController.addFood(v[0], v[1], parseInteger(v[2])!);
          if (!sheetContext.mounted) return;
          _finish(sheetContext, 'Alimento adicionado');
        },
      ),
    ),
  );
}

Future<void> showWaterSheet(BuildContext context) {
  return showFormSheet<void>(
    context,
    title: 'Quantidade de água',
    child: Builder(
      builder: (sheetContext) => QuickForm(
        submitLabel: 'Adicionar',
        fields: const [
          FieldSpec('Quantidade', kind: FieldKind.integer, suffix: 'ml', max: 5000, autofocus: true),
        ],
        onSubmit: (v) async {
          final ml = parseInteger(v[0])!;
          await appController.addWater(ml);
          if (!sheetContext.mounted) return;
          _finish(sheetContext, '$ml ml adicionados');
        },
      ),
    ),
  );
}

Future<void> showWeightSheet(BuildContext context) {
  final current = appController.profile?.weightKg;
  return showFormSheet<void>(
    context,
    title: 'Registrar peso de hoje',
    child: Builder(
      builder: (sheetContext) => QuickForm(
        submitLabel: 'Salvar peso',
        fields: [
          FieldSpec(
            'Peso',
            kind: FieldKind.decimal,
            suffix: 'kg',
            min: 20,
            max: 400,
            autofocus: true,
            initial: current == null ? null : fmtNum(current),
          ),
        ],
        onSubmit: (v) async {
          await appController.registerWeight(parseDecimal(v[0])!);
          if (!sheetContext.mounted) return;
          _finish(sheetContext, 'Peso registrado');
        },
      ),
    ),
  );
}

Future<void> showExerciseSheet(BuildContext context) {
  return showFormSheet<void>(context, title: 'Registrar exercício', child: const _ExerciseForm());
}

class _ExerciseForm extends StatefulWidget {
  const _ExerciseForm();

  @override
  State<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<_ExerciseForm> {
  static const _types = ['Caminhada', 'Corrida', 'Musculação', 'Bicicleta', 'Outros'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minutesController = TextEditingController();
  String _type = _types.first;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final name = _type == 'Outros' ? _nameController.text.trim() : _type;
    await appController.addExercise(name, parseInteger(_minutesController.text)!, dateKey(_date));
    if (!mounted) return;
   _finish(context, 'Exercício registrado');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _types)
                ChoiceChip(
                  label: Text(t),
                  selected: _type == t,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_type == 'Outros') ...[
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome do exercício'),
              validator: validateRequired,
            ),
            const SizedBox(height: 14),
          ],
          TextFormField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duração', suffixText: 'min'),
            validator: (v) => validateNumber(v, integer: true, max: 1440),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data',
                suffixIcon: Icon(Icons.calendar_today_rounded, size: 20),
              ),
              child: Text(friendlyDate(dateKey(_date)), style: AppText.body),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _saving ? null : _submit, child: const Text('Salvar exercício')),
        ],
      ),
    );
  }
}
