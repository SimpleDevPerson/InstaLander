import 'dart:math';

List<int> calculateAdInsertionOffsets({
  required int userCount,
  required int crossAxisCount,
  required Random random,
}) {
  if (userCount <= 0 || crossAxisCount <= 0) return const [];

  final offsets = <int>[];
  var offset = 0;
  while (offset < userCount) {
    offset += (random.nextInt(2) + 3) * crossAxisCount;
    if (offset < userCount) offsets.add(offset);
  }
  return offsets;
}
