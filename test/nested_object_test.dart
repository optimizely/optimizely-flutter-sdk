/// **************************************************************************
/// Copyright 2022-2024, Optimizely, Inc. and contributors                   *
///                                                                          *
/// Licensed under the Apache License, Version 2.0 (the "License");          *
/// you may not use this file except in compliance with the License.         *
/// You may obtain a copy of the License at                                  *
///                                                                          *
///    http://www.apache.org/licenses/LICENSE-2.0                            *
///                                                                          *
/// Unless required by applicable law or agreed to in writing, software      *
/// distributed under the License is distributed on an "AS IS" BASIS,        *
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
/// See the License for the specific language governing permissions and      *
/// limitations under the License.                                           *
///**************************************************************************/

import 'dart:io' show Platform;
import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';

void main() {
  group('Utils.convertToTypedMap with nested objects', () {
    test('should handle nested maps without error', () {
      final input = {
        'simple': 'value',
        'user': {
          'id': '123',
          'name': 'John',
          'age': 30,
        }
      };

      // Should not throw an error
      final result = Utils.convertToTypedMap(input);

      // Result should not be null and should have the keys
      expect(result, isNotNull);
      expect(result.containsKey('simple'), true);
      expect(result.containsKey('user'), true);

      if (!Platform.isIOS) {
        // On Android/VM, verify nested structure is preserved
        expect(result['simple'], 'value');
        expect(result['user'], isA<Map>());
        final userMap = result['user'] as Map;
        expect(userMap['id'], '123');
        expect(userMap['name'], 'John');
        expect(userMap['age'], 30);
      }
    });

    test('should handle deeply nested maps', () {
      final input = {
        'level1': {
          'level2': {
            'level3': {
              'value': 'deep',
            }
          }
        }
      };

      final result = Utils.convertToTypedMap(input);

      expect(result, isNotNull);
      expect(result.containsKey('level1'), true);

      if (!Platform.isIOS) {
        final level1 = result['level1'] as Map;
        final level2 = level1['level2'] as Map;
        final level3 = level2['level3'] as Map;
        expect(level3['value'], 'deep');
      }
    });

    test('should handle lists of primitives', () {
      final input = {
        'tags': ['flutter', 'optimizely', 'sdk'],
        'scores': [1, 2, 3, 4, 5],
      };

      final result = Utils.convertToTypedMap(input);

      expect(result, isNotNull);
      expect(result.containsKey('tags'), true);
      expect(result.containsKey('scores'), true);

      if (!Platform.isIOS) {
        expect(result['tags'], isA<List>());
        expect((result['tags'] as List).length, 3);
        expect((result['tags'] as List)[0], 'flutter');

        expect(result['scores'], isA<List>());
        expect((result['scores'] as List).length, 5);
        expect((result['scores'] as List)[0], 1);
      }
    });

    test('should handle lists of maps', () {
      final input = {
        'users': [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ]
      };

      final result = Utils.convertToTypedMap(input);

      expect(result, isNotNull);
      expect(result.containsKey('users'), true);

      if (!Platform.isIOS) {
        final users = result['users'] as List;
        expect(users.length, 2);
        expect((users[0] as Map)['name'], 'Alice');
        expect((users[0] as Map)['age'], 30);
        expect((users[1] as Map)['name'], 'Bob');
        expect((users[1] as Map)['age'], 25);
      }
    });

    test('should handle complex mixed structures', () {
      final input = {
        'event': 'purchase',
        'revenue': 99.99,
        'user': {
          'id': 'user123',
          'premium': true,
          'tags': ['vip', 'loyal'],
        },
        'items': [
          {'name': 'Product A', 'quantity': 2},
          {'name': 'Product B', 'quantity': 1},
        ],
      };

      final result = Utils.convertToTypedMap(input);

      expect(result, isNotNull);
      expect(result.containsKey('event'), true);
      expect(result.containsKey('revenue'), true);
      expect(result.containsKey('user'), true);
      expect(result.containsKey('items'), true);

      if (!Platform.isIOS) {
        expect(result['event'], 'purchase');
        expect(result['revenue'], 99.99);

        final userMap = result['user'] as Map;
        expect(userMap['id'], 'user123');
        expect(userMap['premium'], true);
        expect((userMap['tags'] as List)[0], 'vip');

        final items = result['items'] as List;
        expect(items.length, 2);
        expect((items[0] as Map)['name'], 'Product A');
        expect((items[0] as Map)['quantity'], 2);
      }
    });

    test('should handle empty collections', () {
      final input = {
        'emptyMap': <String, dynamic>{},
        'emptyList': <dynamic>[],
        'name': 'test',
      };

      final result = Utils.convertToTypedMap(input);

      expect(result, isNotNull);
      expect(result.containsKey('emptyMap'), true);
      expect(result.containsKey('emptyList'), true);
      expect(result.containsKey('name'), true);

      if (!Platform.isIOS) {
        expect(result['emptyMap'], isA<Map>());
        expect((result['emptyMap'] as Map).isEmpty, true);
        expect(result['emptyList'], isA<List>());
        expect((result['emptyList'] as List).isEmpty, true);
        expect(result['name'], 'test');
      }
    });

    test('should handle real-world trackEvent example', () {
      final input = {
        'event_type': 'checkout',
        'revenue': 199.99,
        'user': {
          'id': 'user_12345',
          'email': 'user@example.com',
          'is_premium': true,
          'account_age_days': 365,
        },
        'cart': {
          'items': [
            {
              'product_id': 'prod_1',
              'name': 'Widget',
              'price': 99.99,
              'quantity': 1,
            },
            {
              'product_id': 'prod_2',
              'name': 'Gadget',
              'price': 100.00,
              'quantity': 1,
            },
          ],
          'total_items': 2,
        },
        'metadata': {
          'source': 'mobile_app',
          'platform': 'ios',
          'version': '2.1.0',
        },
      };

      // The key test: this should not throw an exception or error
      final result = Utils.convertToTypedMap(input);

      // Verify structure was preserved
      expect(result, isNotNull);
      expect(result.containsKey('event_type'), true);
      expect(result.containsKey('user'), true);
      expect(result.containsKey('cart'), true);
      expect(result.containsKey('metadata'), true);

      if (!Platform.isIOS) {
        // Verify the nested structure is intact on Android
        final userMap = result['user'] as Map;
        expect(userMap['id'], 'user_12345');
        expect(userMap['is_premium'], true);
        expect(userMap['account_age_days'], 365);

        final cartMap = result['cart'] as Map;
        final items = cartMap['items'] as List;
        expect(items.length, 2);

        final firstItem = items[0] as Map;
        expect(firstItem['product_id'], 'prod_1');
        expect(firstItem['price'], 99.99);
      }
    });

    test('should not throw error on previous unsupported types', () {
      // This test ensures we no longer silently drop nested objects
      final input = {
        'supported': 'value',
        'nested': {
          'should': 'work',
          'now': true,
        }
      };

      // Previously this would print "Unsupported value type for key: nested"
      // and drop the nested map. Now it should handle it.
      expect(() => Utils.convertToTypedMap(input), returnsNormally);

      final result = Utils.convertToTypedMap(input);
      expect(result.containsKey('nested'), true);
    });
  });
}
