import 'dart:math';

import '../config/constants.dart';

/// Generates randomized number boards for both Basic and Infinite modes.
///
/// Basic mode: front 1–25, back 26–50 (each shuffled independently).
/// Infinite mode: sequential sets of 25, continuing up to 999 per loop.
class BoardGenerator {
  BoardGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Returns a shuffled list of numbers from [start] to [end] inclusive.
  List<int> _shuffledRange(int start, int end) {
    final numbers = List<int>.generate(end - start + 1, (i) => start + i);
    numbers.shuffle(_random);
    return numbers;
  }

  /// Generates shuffled front numbers (1–25) for basic mode.
  List<int> generateFrontNumbers() {
    return _shuffledRange(basicModeFrontStart, basicModeFrontEnd);
  }

  /// Generates shuffled back numbers starting from [offset].
  ///
  /// Returns [totalCells] numbers starting at [offset].
  /// E.g., offset = 26 → shuffled 26–50.
  List<int> generateBackNumbers(int offset) {
    return _shuffledRange(offset, offset + totalCells - 1);
  }

  /// Generates a complete basic-mode board.
  ///
  /// Returns `[frontNumbers, backNumbers]` where:
  /// - frontNumbers: shuffled 1–25
  /// - backNumbers: shuffled 26–50
  /// Both lists have length [totalCells] (25).
  List<List<int>> generateBasicBoard() {
    final front = generateFrontNumbers();
    final back = generateBackNumbers(basicModeBackStart);
    return [front, back];
  }

  /// Generates a board set for infinite mode starting at [startNumber].
  ///
  /// Front numbers: [startNumber] to [startNumber + 24], shuffled.
  /// Back numbers: [startNumber + 25] to [startNumber + 49], shuffled.
  ///
  /// For the last set in a loop (976–999), the back layer is handled by
  /// [generateLastSetBackNumbers] instead.
  List<List<int>> generateInfiniteBoard(int startNumber) {
    final frontEnd = startNumber + totalCells - 1;
    final backStart = startNumber + totalCells;
    final backEnd = backStart + totalCells - 1;

    final front = _shuffledRange(startNumber, frontEnd);
    final back = _shuffledRange(backStart, backEnd);
    return [front, back];
  }

  /// Generates the back layer for the last set in an infinite-mode loop.
  ///
  /// The last front set contains numbers 976–999 (24 numbers + the back
  /// layer of the previous set completes them). When those are tapped,
  /// the back layer needs 24 numbers (976–999 range remaining) + 1 icon slot.
  ///
  /// Returns a list of length [totalCells] where:
  /// - 24 entries are the remaining numbers
  /// - 1 entry is -1, representing the loop-completion icon
  /// All positions are randomized.
  ///
  /// [lastNumbers]: the actual number values for the 24 remaining cells.
  /// If fewer than [totalCells] - 1 numbers are provided, remaining
  /// slots are filled with -1 (icon).
  List<int> generateLastSetBackNumbers(List<int> lastNumbers) {
    final cells = List<int>.from(lastNumbers);
    // Fill remaining slots with icon marker (-1)
    while (cells.length < totalCells) {
      cells.add(-1);
    }
    cells.shuffle(_random);
    return cells;
  }
}
