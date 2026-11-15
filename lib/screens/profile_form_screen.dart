import 'package:material_ui/material_ui.dart';

import '../models/user_profile.dart';
import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/quick_form.dart';
import 'goals_screen.dart';

/// Cadastro inicial (passo 1 de 2) e também a tela de edição do perfil.
class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key, this.editing = false});

  final bool editing;

  @override
  Widget build(BuildContext context) {
    final p = appController.profile; // se o cadastro ficou pela metade, reaproveita o que já foi digitado

    return Scaffold(
      appBar: editing ? AppBar(title: const Text('Editar perfil')) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!editing) ...[
                const Text('Passo 1 de 2', style: AppText.secondary),
                const SizedBox(height: 8),
                const Text('Conte um pouco sobre você', style: AppText.heading),
                const SizedBox(height: 8),
                const Text('Esses dados ficam guardados somente no seu celular.', style: AppText.secondary),
                const SizedBox(height: 28),
              ],
              QuickForm(
                submitLabel: editing ? 'Salvar alterações' : 'Continuar',
                fields: [
                  FieldSpec('Nome', initial: p?.name),
                  FieldSpec('Idade', kind: FieldKind.integer, suffix: 'anos', min: 1, max: 120, initial: p?.age.toString()),
                  FieldSpec('Altura', kind: FieldKind.decimal, suffix: 'cm', min: 50, max: 250, initial: p == null ? null : fmtNum(p.heightCm)),
                  FieldSpec('Peso atual', kind: FieldKind.decimal, suffix: 'kg', min: 20, max: 400, initial: p == null ? null : fmtNum(p.weightKg)),
                ],
                onSubmit: (v) async {
                  final profile = UserProfile(
                    name: v[0],
                    age: parseInteger(v[1])!,
                    heightCm: parseDecimal(v[2])!,
                    weightKg: parseDecimal(v[3])!,
                    objective: appController.profile?.objective,
                  );
                  await appController.saveProfile(profile);
                  if (!context.mounted) return;
                  if (editing) {
                    showAppSnack(context, 'Perfil atualizado');
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GoalsScreen()));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
