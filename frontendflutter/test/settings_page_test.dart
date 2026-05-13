import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendflutter/features/impostazioni/settings_api_service.dart';
import 'package:frontendflutter/features/impostazioni/settings_page.dart';

class FailingSettingsApiService extends SettingsApiService {
  @override
  Future<WorkshopSettings> getSettings({required int officinaId}) {
    throw Exception('Table Officina does not exist');
  }
}

void main() {
  testWidgets('shows editable defaults when settings backend fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: SettingsPage(settingsApi: FailingSettingsApiService())),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Impostazioni non disponibili'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Non disponibile con il backend attuale'), findsOneWidget);
  });
}
