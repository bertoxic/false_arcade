import 'package:flutter_test/flutter_test.dart';
import 'package:fluga/app/arcade_catalog.dart';

void main() {
  test('catalog exposes six uniquely identified games', () {
    expect(arcadeCatalog, hasLength(6));
    expect(arcadeCatalog.map((game) => game.id).toSet(), hasLength(6));
    expect(arcadeCatalog.every((game) => game.colors.length >= 2), isTrue);
  });
}
