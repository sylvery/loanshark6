import 'package:bookinman/data/local/settings_repository.dart';
import 'package:bookinman/domain/entities/penalty_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesSettings', () {
    late SharedPreferences prefs;
    late SharedPreferencesSettings repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = SharedPreferencesSettings(prefs);
    });

    test('theme mode defaults to dark and round-trips', () async {
      expect(await repository.getThemeMode(), 'dark');
      await repository.setThemeMode('light');
      expect(await repository.getThemeMode(), 'light');
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('display name round-trips and clears', () async {
      await repository.setDisplayName('Jane Lender');
      expect(await repository.getDisplayName(), 'Jane Lender');
      await repository.setDisplayName(null);
      expect(await repository.getDisplayName(), isNull);
    });

    test('penalty and reminder policies still persist', () async {
      final policy = PenaltyPolicy(enabled: true, flatAmount: 5);
      await repository.setPenaltyPolicy(policy);
      expect((await repository.getPenaltyPolicy()).flatAmount, 5);
    });
  });
}
