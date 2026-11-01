import 'package:flutter_test/flutter_test.dart';
import 'package:simple_note/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Simple Note renders app bar and initial state', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Simple Note'), findsOneWidget);
    expect(find.text('Catatan Baru'), findsOneWidget);
  });
}
