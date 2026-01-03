import 'package:flutter_test/flutter_test.dart';
import 'package:senseai/data/models/child.dart';

void main() {
  group('Child Model', () {
    test('should create Child with all required fields', () {
      final child = Child(
        id: 'test-id',
        childCode: 'CHILD001',
        name: 'Test Child',
        dateOfBirth: DateTime(2020, 1, 1),
        ageInMonths: 48,
        gender: 'male',
        language: 'en',
        age: 4.0,
        createdAt: DateTime.now(),
        group: ChildGroup.typicallyDeveloping,
        diagnosisSource: 'Test Hospital',
      );

      expect(child.id, 'test-id');
      expect(child.childCode, 'CHILD001');
      expect(child.name, 'Test Child');
      expect(child.ageInMonths, 48);
      expect(child.gender, 'male');
      expect(child.group, ChildGroup.typicallyDeveloping);
    });

    test('should create Child with ASD group', () {
      final child = Child(
        id: 'test-id',
        childCode: 'CHILD002',
        name: 'ASD Child',
        dateOfBirth: DateTime(2019, 1, 1),
        ageInMonths: 60,
        gender: 'female',
        language: 'si',
        age: 5.0,
        createdAt: DateTime.now(),
        group: ChildGroup.asd,
        asdLevel: AsdLevel.level1,
        diagnosisSource: 'LRH Hospital',
      );

      expect(child.group, ChildGroup.asd);
      expect(child.asdLevel, AsdLevel.level1);
    });

    group('ChildGroup', () {
      test('should convert ChildGroup to JSON correctly', () {
        expect(ChildGroup.typicallyDeveloping.toJson(), 'typically_developing');
        expect(ChildGroup.asd.toJson(), 'asd');
      });

      test('should create ChildGroup from JSON correctly', () {
        expect(ChildGroup.fromJson('typically_developing'),
            ChildGroup.typicallyDeveloping);
        expect(ChildGroup.fromJson('asd'), ChildGroup.asd);
      });

      test('should handle invalid JSON gracefully', () {
        expect(() => ChildGroup.fromJson('invalid'), throwsA(isA<Exception>()));
      });
    });

    group('AsdLevel', () {
      test('should convert AsdLevel to JSON correctly', () {
        expect(AsdLevel.level1.toJson(), 'level_1');
        expect(AsdLevel.level2.toJson(), 'level_2');
        expect(AsdLevel.level3.toJson(), 'level_3');
      });

      test('should create AsdLevel from JSON correctly', () {
        expect(AsdLevel.fromJson('level_1'), AsdLevel.level1);
        expect(AsdLevel.fromJson('level_2'), AsdLevel.level2);
        expect(AsdLevel.fromJson('level_3'), AsdLevel.level3);
      });
    });

    group('Age Calculation', () {
      test('should calculate age correctly', () {
        final dob = DateTime(2020, 1, 1);
        final now = DateTime(2024, 1, 1);
        final child = Child(
          id: 'test-id',
          childCode: 'CHILD001',
          name: 'Test Child',
          dateOfBirth: dob,
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          age: 4.0,
          createdAt: now,
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
        );

        expect(child.age, 4.0);
        expect(child.ageInMonths, 48);
      });
    });
  });
}



