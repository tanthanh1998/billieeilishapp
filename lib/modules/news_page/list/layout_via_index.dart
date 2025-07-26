import 'dart:math';

///[int] is index
///the [bool] value decided if they are vertical layout
var _layoutData = <int, bool>{};
var random = Random();

bool isVeriCalLayout(int index) {
  if (index == 0) {
    return false;
  }
  var isVertical = _layoutData[index];
  if (isVertical != null) {
    return isVertical;
  }

  //TODO: Algorithms
  final randomValue = random.nextInt(6);
  isVertical = randomValue != 0;

  _layoutData[index] = isVertical;
  return isVertical;
}

void resetLayoutData() {
  _layoutData = {};
}
