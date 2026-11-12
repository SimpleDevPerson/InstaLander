import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/widgets/ad_placement.dart';

void main() {
  test('ad positions are separated by three or four complete grid rows', () {
    const columns = 3;
    const userCount = 120;
    final offsets = calculateAdInsertionOffsets(
      userCount: userCount,
      crossAxisCount: columns,
      random: Random(17),
    );

    expect(offsets, isNotEmpty);
    var previousOffset = 0;
    for (final offset in offsets) {
      final rowsSincePreviousAd = (offset - previousOffset) ~/ columns;
      expect(offset % columns, 0);
      expect(rowsSincePreviousAd, anyOf(3, 4));
      expect(offset, lessThan(userCount));
      previousOffset = offset;
    }
  });

  test('no ad is inserted when there are not enough profile rows', () {
    expect(
      calculateAdInsertionOffsets(
        userCount: 8,
        crossAxisCount: 3,
        random: Random(1),
      ),
      isEmpty,
    );
  });
}
