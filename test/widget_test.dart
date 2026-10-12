import 'package:flutter_test/flutter_test.dart';
import 'package:family_connect/app.dart';
import 'package:family_connect/firebase_options.dart';

void main() {
  testWidgets('Shows Firebase setup when not configured', (tester) async {
    expect(DefaultFirebaseOptions.isConfigured, isFalse);
    await tester.pumpWidget(const FamilyConnectApp());
    expect(find.textContaining('Firebase is not configured'), findsOneWidget);
  });
}
