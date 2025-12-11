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

import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';

void main() {
  group('Utils.convertToTypedMap - Android Format (primitiveMap)', () {
    // These tests verify Android behavior where original structure is preserved

    test('should preserve nested maps in Android format', () {
      final input = {
        'simple': 'value',
        'user': {
          'id': '123',
          'name': 'John',
          'age': 30,
        }
      };

      final result = Utils.convertToTypedMap(input); // Default is Android format

      expect(result, isNotNull);
      expect(result.containsKey('simple'), true);
      expect(result.containsKey('user'), true);

      // Android format: original structure preserved
      expect(result['simple'], 'value');
      expect(result['user'], isA<Map>());
      final userMap = result['user'] as Map;
      expect(userMap['id'], '123');
      expect(userMap['name'], 'John');
      expect(userMap['age'], 30);
    });

    test('should preserve deeply nested maps in Android format', () {
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

      final level1 = result['level1'] as Map;
      final level2 = level1['level2'] as Map;
      final level3 = level2['level3'] as Map;
      expect(level3['value'], 'deep');
    });

    test('should preserve lists of primitives in Android format', () {
      final input = {
        'tags': ['flutter', 'optimizely', 'sdk'],
        'scores': [1, 2, 3, 4, 5],
      };

      final result = Utils.convertToTypedMap(input);

      expect(result['tags'], isA<List>());
      expect((result['tags'] as List).length, 3);
      expect((result['tags'] as List)[0], 'flutter');

      expect(result['scores'], isA<List>());
      expect((result['scores'] as List).length, 5);
      expect((result['scores'] as List)[0], 1);
    });

    test('should preserve lists of maps in Android format', () {
      final input = {
        'users': [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ]
      };

      final result = Utils.convertToTypedMap(input);

      final users = result['users'] as List;
      expect(users.length, 2);
      expect((users[0] as Map)['name'], 'Alice');
      expect((users[0] as Map)['age'], 30);
      expect((users[1] as Map)['name'], 'Bob');
      expect((users[1] as Map)['age'], 25);
    });

    test('should handle empty collections in Android format', () {
      final input = {
        'emptyMap': <String, dynamic>{},
        'emptyList': <dynamic>[],
        'name': 'test',
      };

      final result = Utils.convertToTypedMap(input);

      expect(result['emptyMap'], isA<Map>());
      expect((result['emptyMap'] as Map).isEmpty, true);
      expect(result['emptyList'], isA<List>());
      expect((result['emptyList'] as List).isEmpty, true);
      expect(result['name'], 'test');
    });
  });

  group('Utils.convertToTypedMap - iOS Format (typedMap)', () {
    // These tests verify iOS behavior where types are wrapped

    test('should wrap primitive types with type information for iOS', () {
      final input = {
        'stringKey': 'value',
        'intKey': 42,
        'doubleKey': 3.14,
        'boolKey': true,
      };

      final result = Utils.convertToTypedMap(input, forceIOSFormat: true);

      // iOS format: values are wrapped with type information
      expect(result['stringKey'], isA<Map>());
      expect(result['stringKey']['value'], 'value');
      expect(result['stringKey']['type'], Constants.stringType);

      expect(result['intKey']['value'], 42);
      expect(result['intKey']['type'], Constants.intType);

      expect(result['doubleKey']['value'], 3.14);
      expect(result['doubleKey']['type'], Constants.doubleType);

      expect(result['boolKey']['value'], true);
      expect(result['boolKey']['type'], Constants.boolType);
    });

    test('should wrap nested maps with type information for iOS', () {
      final input = {
        'user': {
          'id': '123',
          'name': 'John',
          'age': 30,
        }
      };

      final result = Utils.convertToTypedMap(input, forceIOSFormat: true);

      // Check outer map type
      expect(result['user'], isA<Map>());
      expect(result['user']['type'], Constants.mapType);
      expect(result['user']['value'], isA<Map>());

      // Check nested values
      final nestedMap = result['user']['value'] as Map;
      expect(nestedMap['id']['value'], '123');
      expect(nestedMap['id']['type'], Constants.stringType);
      expect(nestedMap['name']['value'], 'John');
      expect(nestedMap['name']['type'], Constants.stringType);
      expect(nestedMap['age']['value'], 30);
      expect(nestedMap['age']['type'], Constants.intType);
    });

    test('should wrap deeply nested maps for iOS', () {
      final input = {
        'user': {
          'profile': {
            'preferences': {
              'theme': 'dark',
              'notifications': true,
            }
          }
        }
      };

      final result = Utils.convertToTypedMap(input, forceIOSFormat: true);

      expect(result['user']['type'], Constants.mapType);
      final userMap = result['user']['value'] as Map;

      expect(userMap['profile']['type'], Constants.mapType);
      final profileMap = userMap['profile']['value'] as Map;

      expect(profileMap['preferences']['type'], Constants.mapType);
      final preferencesMap = profileMap['preferences']['value'] as Map;

      expect(preferencesMap['theme']['value'], 'dark');
      expect(preferencesMap['theme']['type'], Constants.stringType);
      expect(preferencesMap['notifications']['value'], true);
      expect(preferencesMap['notifications']['type'], Constants.boolType);
    });

    test('should wrap lists of primitives for iOS', () {
      final input = {
        'tags': ['flutter', 'optimizely', 'sdk'],
        'scores': [1, 2, 3, 4, 5],
      };

      final result = Utils.convertToTypedMap(input, forceIOSFormat: true);

      // Check list is wrapped
      expect(result['tags']['type'], Constants.listType);
      final tagsList = result['tags']['value'] as List;
      expect(tagsList.length, 3);
      expect(tagsList[0]['value'], 'flutter');
      expect(tagsList[0]['type'], Constants.stringType);

      expect(result['scores']['type'], Constants.listType);
      final scoresList = result['scores']['value'] as List;
      expect(scoresList.length, 5);
      expect(scoresList[0]['value'], 1);
      expect(scoresList[0]['type'], Constants.intType);
    });

    test('should wrap lists of maps for iOS', () {
      final input = {
        'users': [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ]
      };

      final result = Utils.convertToTypedMap(input, forceIOSFormat: true);

      expect(result['users']['type'], Constants.listType);
      final usersList = result['users']['value'] as List;
      expect(usersList.length, 2);

      // Check first user
      expect(usersList[0]['type'], Constants.mapType);
      final firstUser = usersList[0]['value'] as Map;
      expect(firstUser['name']['value'], 'Alice');
      expect(firstUser['name']['type'], Constants.stringType);
      expect(firstUser['age']['value'], 30);
      expect(firstUser['age']['type'], Constants.intType);

      // Check second user
      expect(usersList[1]['type'], Constants.mapType);
      final secondUser = usersList[1]['value'] as Map;
      expect(secondUser['name']['value'], 'Bob');
      expect(secondUser['age']['value'], 25);
    });

    test('should handle empty collections in iOS format', () {
      final input = {
        'emptyMap': <String, dynamic>{},
        'emptyList': <dynamic>[],
        'name': 'test',
      };

      final result = Utils.convertToTypedMap(input, forceIOSFormat: true);

      expect(result['emptyMap']['type'], Constants.mapType);
      final emptyMapValue = result['emptyMap']['value'] as Map;
      expect(emptyMapValue.isEmpty, true);

      expect(result['emptyList']['type'], Constants.listType);
      final emptyListValue = result['emptyList']['value'] as List;
      expect(emptyListValue.isEmpty, true);

      expect(result['name']['value'], 'test');
      expect(result['name']['type'], Constants.stringType);
    });

    test('should handle mixed complex structures for iOS', () {
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

      final result = Utils.convertToTypedMap(input, forceIOSFormat: true);

      // Check primitives
      expect(result['event']['value'], 'purchase');
      expect(result['event']['type'], Constants.stringType);
      expect(result['revenue']['value'], 99.99);
      expect(result['revenue']['type'], Constants.doubleType);

      // Check nested map
      expect(result['user']['type'], Constants.mapType);
      final userMap = result['user']['value'] as Map;
      expect(userMap['id']['value'], 'user123');
      expect(userMap['premium']['value'], true);

      // Check nested list in map
      expect(userMap['tags']['type'], Constants.listType);
      final tagsList = userMap['tags']['value'] as List;
      expect(tagsList[0]['value'], 'vip');

      // Check list of maps
      expect(result['items']['type'], Constants.listType);
      final itemsList = result['items']['value'] as List;
      expect(itemsList.length, 2);
      expect(itemsList[0]['type'], Constants.mapType);
      final item0 = itemsList[0]['value'] as Map;
      expect(item0['name']['value'], 'Product A');
      expect(item0['quantity']['value'], 2);
    });
  });

  group('Utils.convertToTypedMap - Real World Scenarios', () {
    test('should handle real-world trackEvent example in both formats', () {
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

      // Test Android format
      final androidResult = Utils.convertToTypedMap(input);
      expect(androidResult, isNotNull);
      expect(androidResult.containsKey('event_type'), true);
      expect(androidResult['event_type'], 'checkout');

      final androidUserMap = androidResult['user'] as Map;
      expect(androidUserMap['id'], 'user_12345');
      expect(androidUserMap['is_premium'], true);

      final androidCartMap = androidResult['cart'] as Map;
      final androidItems = androidCartMap['items'] as List;
      expect(androidItems.length, 2);
      expect((androidItems[0] as Map)['product_id'], 'prod_1');

      // Test iOS format
      final iosResult = Utils.convertToTypedMap(input, forceIOSFormat: true);
      expect(iosResult, isNotNull);
      expect(iosResult.containsKey('event_type'), true);
      expect(iosResult['event_type']['value'], 'checkout');
      expect(iosResult['event_type']['type'], Constants.stringType);

      final iosUserMap = iosResult['user']['value'] as Map;
      expect(iosUserMap['id']['value'], 'user_12345');
      expect(iosUserMap['is_premium']['value'], true);

      final iosCartMap = iosResult['cart']['value'] as Map;
      final iosItems = iosCartMap['items']['value'] as List;
      expect(iosItems.length, 2);
      final iosFirstItem = iosItems[0]['value'] as Map;
      expect(iosFirstItem['product_id']['value'], 'prod_1');
    });

    test('should not throw error on nested objects (regression test)', () {
      // This ensures we no longer silently drop nested objects like before
      final input = {
        'supported': 'value',
        'nested': {
          'should': 'work',
          'now': true,
        }
      };

      // Should work in both formats without error
      expect(() => Utils.convertToTypedMap(input), returnsNormally);
      expect(() => Utils.convertToTypedMap(input, forceIOSFormat: true), returnsNormally);

      final androidResult = Utils.convertToTypedMap(input);
      expect(androidResult.containsKey('nested'), true);
      expect((androidResult['nested'] as Map)['should'], 'work');

      final iosResult = Utils.convertToTypedMap(input, forceIOSFormat: true);
      expect(iosResult.containsKey('nested'), true);
      expect(iosResult['nested']['type'], Constants.mapType);
    });

    test('should handle list with mixed types in both formats', () {
      final input = {
        'mixed': [1, 'two', 3.0, true],
      };

      // Android format
      final androidResult = Utils.convertToTypedMap(input);
      final androidMixed = androidResult['mixed'] as List;
      expect(androidMixed[0], 1);
      expect(androidMixed[1], 'two');
      expect(androidMixed[2], 3.0);
      expect(androidMixed[3], true);

      // iOS format
      final iosResult = Utils.convertToTypedMap(input, forceIOSFormat: true);
      final iosMixed = iosResult['mixed']['value'] as List;
      expect(iosMixed[0]['value'], 1);
      expect(iosMixed[0]['type'], Constants.intType);
      expect(iosMixed[1]['value'], 'two');
      expect(iosMixed[1]['type'], Constants.stringType);
      expect(iosMixed[2]['value'], 3.0);
      expect(iosMixed[2]['type'], Constants.doubleType);
      expect(iosMixed[3]['value'], true);
      expect(iosMixed[3]['type'], Constants.boolType);
    });
  });

  group('Utils.convertToTypedMap - Edge Cases', () {
    test('should handle empty map', () {
      final input = <String, dynamic>{};

      final androidResult = Utils.convertToTypedMap(input);
      expect(androidResult.isEmpty, true);

      final iosResult = Utils.convertToTypedMap(input, forceIOSFormat: true);
      expect(iosResult.isEmpty, true);
    });

    test('should handle map with only primitives', () {
      final input = {
        'a': 1,
        'b': 'text',
        'c': true,
        'd': 3.14,
      };

      final androidResult = Utils.convertToTypedMap(input);
      expect(androidResult['a'], 1);
      expect(androidResult['b'], 'text');

      final iosResult = Utils.convertToTypedMap(input, forceIOSFormat: true);
      expect(iosResult['a']['value'], 1);
      expect(iosResult['b']['value'], 'text');
    });

    test('should handle deeply nested arrays', () {
      final input = {
        'nested': [
          [1, 2, 3],
          [4, 5, 6],
        ]
      };

      // Android
      final androidResult = Utils.convertToTypedMap(input);
      expect(((androidResult['nested'] as List)[0] as List)[0], 1);

      // iOS
      final iosResult = Utils.convertToTypedMap(input, forceIOSFormat: true);
      final iosOuter = iosResult['nested']['value'] as List;
      final iosInner = iosOuter[0]['value'] as List;
      expect(iosInner[0]['value'], 1);
      expect(iosInner[0]['type'], Constants.intType);
    });
  });
}
