import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hbjjgames_web/logic/board_generator.dart';

void main() {
  late BoardGenerator generator;

  setUp(() {
    generator = BoardGenerator(random: Random(42));
  });

  group('generateBasicBoard', () {
    test('front contains all numbers 1-25', () {
      final board = generator.generateBasicBoard();
      final front = board[0];
      expect(front.length, 25);
      expect(front.toSet().length, 25);
      for (int i = 1; i <= 25; i++) {
        expect(front.contains(i), isTrue);
      }
    });

    test('back contains all numbers 26-50', () {
      final board = generator.generateBasicBoard();
      final back = board[1];
      expect(back.length, 25);
      expect(back.toSet().length, 25);
      for (int i = 26; i <= 50; i++) {
        expect(back.contains(i), isTrue);
      }
    });

    test('front and back have no overlapping numbers', () {
      final board = generator.generateBasicBoard();
      final frontSet = board[0].toSet();
      final backSet = board[1].toSet();
      expect(frontSet.intersection(backSet), isEmpty);
    });

    test('board is randomized (different seeds produce different boards)', () {
      final gen1 = BoardGenerator(random: Random(1));
      final gen2 = BoardGenerator(random: Random(2));
      final board1 = gen1.generateBasicBoard();
      final board2 = gen2.generateBasicBoard();
      // At least one layer should differ in order
      final frontDiffers = board1[0].toString() != board2[0].toString();
      final backDiffers = board1[1].toString() != board2[1].toString();
      expect(frontDiffers || backDiffers, isTrue);
    });
  });

  group('generateInfiniteBoard', () {
    test('generates correct range starting at 1', () {
      final board = generator.generateInfiniteBoard(1);
      final front = board[0];
      final back = board[1];
      expect(front.length, 25);
      expect(back.length, 25);
      for (int i = 1; i <= 25; i++) {
        expect(front.contains(i), isTrue);
      }
      for (int i = 26; i <= 50; i++) {
        expect(back.contains(i), isTrue);
      }
    });

    test('generates correct range starting at 51', () {
      final board = generator.generateInfiniteBoard(51);
      final front = board[0];
      final back = board[1];
      for (int i = 51; i <= 75; i++) {
        expect(front.contains(i), isTrue);
      }
      for (int i = 76; i <= 100; i++) {
        expect(back.contains(i), isTrue);
      }
    });
  });

  group('generateLastSetBackNumbers', () {
    test('contains icon marker (-1) and provided numbers', () {
      final numbers = List<int>.generate(24, (i) => 976 + i);
      final result = generator.generateLastSetBackNumbers(numbers);
      expect(result.length, 25);
      expect(result.contains(-1), isTrue);
      for (final n in numbers) {
        expect(result.contains(n), isTrue);
      }
    });

    test('has exactly one icon marker', () {
      final numbers = List<int>.generate(24, (i) => 976 + i);
      final result = generator.generateLastSetBackNumbers(numbers);
      expect(result.where((n) => n == -1).length, 1);
    });
  });
}
