import 'package:flutter_test/flutter_test.dart';
import 'package:meu_inventario/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Aplicativo Meu Inventário inicia', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuInventarioApp());

    await tester.pumpAndSettle();

    expect(find.byType(MeuInventarioApp), findsOneWidget);
  });
}