import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendflutter/features/impostazioni/settings_api_service.dart';
import 'package:frontendflutter/features/impostazioni/settings_page.dart';

class FailingSettingsApiService extends SettingsApiService {
  @override
  Future<WorkshopSettings> getSettings() {
    throw Exception(
      "Errore nel recupero delle impostazioni soccorso: Authentication failed., full error: {'ok': 0.0, 'errmsg': 'Authentication failed.', 'code': 18, 'codeName': 'AuthenticationFailed'}",
    );
  }
}

void main() {
  testWidgets('shows editable defaults when settings backend fails', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: SettingsPage(settingsApi: FailingSettingsApiService())),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Impostazioni non disponibili'), findsOneWidget);
    expect(
      find.textContaining('Configurazione database non disponibile'),
      findsOneWidget,
    );
    expect(find.textContaining('Authentication failed'), findsNothing);
    expect(find.byType(TextField, skipOffstage: false), findsNWidgets(7));
    expect(find.text('Profilo'), findsOneWidget);
    expect(find.text('Notifiche'), findsNothing);
    expect(find.text('Parametri Operativi'), findsOneWidget);
  });
}
