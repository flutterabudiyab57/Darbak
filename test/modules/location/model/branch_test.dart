import 'package:darbak/modules/location/data/models/branch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Branch.fromBranchesApi', () {
    test('parses string lat/long into doubles, reading long not lng', () {
      final branch = Branch.fromBranchesApi({
        'id': 1,
        'name': 'Main Branch',
        'lat': '24.7136',
        'long': '46.6753',
        'lng': '99.9', // must be ignored — the API key is "long"
      });

      expect(branch.lat, 24.7136);
      expect(branch.lng, 46.6753);
    });

    test('name falls back to text when name is absent', () {
      final branch = Branch.fromBranchesApi({'id': 1, 'text': 'Fallback Name'});
      expect(branch.name, 'Fallback Name');
    });

    test('name prefers name over text when both present', () {
      final branch = Branch.fromBranchesApi({'id': 1, 'name': 'Primary', 'text': 'Secondary'});
      expect(branch.name, 'Primary');
    });

    test('book_today reads the int flag and defaults to false when absent', () {
      expect(Branch.fromBranchesApi({'id': 1, 'name': 'A', 'book_today': 1}).bookToday, isTrue);
      expect(Branch.fromBranchesApi({'id': 1, 'name': 'A', 'book_today': 0}).bookToday, isFalse);
      expect(Branch.fromBranchesApi({'id': 1, 'name': 'A'}).bookToday, isFalse);
      expect(
        Branch.fromBranchesApi({'id': 1, 'name': 'A', 'can_book_today': 1}).bookToday,
        isTrue,
      );
    });

    test('deliveryPrice defaults to 0', () {
      expect(Branch.fromBranchesApi({'id': 1, 'name': 'A'}).deliveryPrice, 0);
      expect(
        Branch.fromBranchesApi({'id': 1, 'name': 'A', 'delivery_price': '25.5'}).deliveryPrice,
        25.5,
      );
    });

    test('malformed geometry yields null and never throws', () {
      expect(
        () => Branch.fromBranchesApi({'id': 1, 'name': 'A', 'polygon': 'not a list'}),
        returnsNormally,
      );
      final branch = Branch.fromBranchesApi({'id': 1, 'name': 'A', 'polygon': 'not a list'});
      expect(branch.polygon, isNull);

      expect(
        () => Branch.fromBranchesApi({'id': 1, 'name': 'A', 'center': 'not a map'}),
        returnsNormally,
      );
      final branch2 = Branch.fromBranchesApi({'id': 1, 'name': 'A', 'center': 'not a map'});
      expect(branch2.center, isNull);
    });
  });

  group('Branch.fromCarBranchesApi', () {
    test('sets isPartial true and leaves the rest null', () {
      final branch = Branch.fromCarBranchesApi({
        'id': 5,
        'text': 'Car Branch',
        'image': 'img.png',
        'can_book_today': 1,
      });

      expect(branch.isPartial, isTrue);
      expect(branch.name, 'Car Branch');
      expect(branch.image, 'img.png');
      expect(branch.bookToday, isTrue);
      expect(branch.regionId, isNull);
      expect(branch.address, isNull);
      expect(branch.lat, isNull);
      expect(branch.lng, isNull);
      expect(branch.workTime, isNull);
      expect(branch.polygon, isNull);
      expect(branch.center, isNull);
    });
  });

  group('Branch identity', () {
    test('two branches with the same id but different names, languages and '
        'geometry are equal with equal hashCode', () {
      final a = Branch.fromBranchesApi({
        'id': 7,
        'name': 'Main Branch',
        'lat': '24.7',
        'long': '46.6',
        'polygon': [
          {'lat': 1, 'lng': 2},
        ],
      });
      final b = Branch.fromBranchesApi({
        'id': 7,
        'name': 'الفرع الرئيسي',
        'lat': '99.9',
        'long': '11.1',
      });

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('a branch with polygon equals the same branch without it', () {
      final withPolygon = Branch.fromBranchesApi({
        'id': 3,
        'name': 'X',
        'polygon': [
          {'lat': 1, 'lng': 2},
        ],
      });
      final withoutPolygon = Branch.fromBranchesApi({'id': 3, 'name': 'X'});

      expect(withPolygon, equals(withoutPolygon));
    });

    test('different ids are never equal', () {
      final a = Branch.fromBranchesApi({'id': 1, 'name': 'A'});
      final b = Branch.fromBranchesApi({'id': 2, 'name': 'A'});
      expect(a, isNot(equals(b)));
    });
  });
}
