import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/validators.dart';

enum FieldKind { text, integer, decimal }

/// Descrição de um campo do formulário.
class FieldSpec {
  const FieldSpec(
    this.label, {
    this.kind = FieldKind.text,
    this.suffix,
    this.hint,
    this.initial,
    this.min = 1,
    this.max = 100000,
    this.autofocus = false,
  });

  final String label;
  final FieldKind kind;
  final String? suffix;
  final String? hint;
  final String? initial;
  final double min;
  final double max;
  final bool autofocus;
}

/// Formulário genérico: recebe a lista de campos, valida tudo (campos vazios e
/// números inválidos) e entrega os textos digitados em [onSubmit].
/// É usado no perfil, nas metas, e nos formulários de alimento, água e peso.
class QuickForm extends StatefulWidget {
  const QuickForm({
    super.key,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    this.header,
  });

  final List<FieldSpec> fields;
  final String submitLabel;
  final Future<void> Function(List<String> values) onSubmit;
  final Widget? header;

  @override
  State<QuickForm> createState() => _QuickFormState();
}

class _QuickFormState extends State<QuickForm> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers = [
    for (final f in widget.fields) TextEditingController(text: f.initial),
  ];
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit([for (final c in _controllers) c.text.trim()]);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<TextInputFormatter> _formatters(FieldKind kind) {
    switch (kind) {
      case FieldKind.text:
        return [LengthLimitingTextInputFormatter(60)];
      case FieldKind.integer:
        return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)];
      case FieldKind.decimal:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')), LengthLimitingTextInputFormatter(7)];
    }
  }

  String? _validate(FieldSpec f, String? value) {
    if (f.kind == FieldKind.text) return validateRequired(value);
    return validateNumber(value, integer: f.kind == FieldKind.integer, min: f.min, max: f.max);
  }

  Widget _buildField(FieldSpec f, TextEditingController controller, bool isLast) {
    return TextFormField(
      controller: controller,
      autofocus: f.autofocus,
      keyboardType: f.kind == FieldKind.text
          ? TextInputType.text
          : TextInputType.numberWithOptions(decimal: f.kind == FieldKind.decimal),
      textCapitalization: f.kind == FieldKind.text ? TextCapitalization.sentences : TextCapitalization.none,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      inputFormatters: _formatters(f.kind),
      decoration: InputDecoration(labelText: f.label, hintText: f.hint, suffixText: f.suffix),
      validator: (value) => _validate(f, value),
      onFieldSubmitted: isLast ? (_) => _submit() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = widget.fields.length - 1;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) ...[widget.header!, const SizedBox(height: 20)],
          for (var i = 0; i < widget.fields.length; i++) ...[
            _buildField(widget.fields[i], _controllers[i], i == last),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 6),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
