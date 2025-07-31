import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_app/core/models/user_model.dart';
import 'package:cargo_app/core/enums/app_enums.dart';

void main() {
  group('UserModel', () {
    test('constructor creates correct instance', () {
      final user = UserModel(
        uid: 'u1',
        name: 'John',
        email: 'john@example.com',
        phoneNumber: '1234567890',
        role: UserRole.driver,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );
      expect(user.uid, 'u1');
      expect(user.name, 'John');
      expect(user.email, 'john@example.com');
      expect(user.phoneNumber, '1234567890');
      expect(user.role, UserRole.driver);
      expect(user.createdAt, DateTime(2024, 1, 1));
      expect(user.updatedAt, DateTime(2024, 1, 2));
      expect(user.isVerified, false);
    });
  });
}
