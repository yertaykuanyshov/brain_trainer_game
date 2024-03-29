import 'package:logger/logger.dart';

final logger = Logger();

List<int> generateItemPositions({
  required int positionCount,
  required max,
}) {
  final numbers = List.generate(max, (index) => index)..shuffle();

  return numbers.getRange(0, positionCount).toList();
}
