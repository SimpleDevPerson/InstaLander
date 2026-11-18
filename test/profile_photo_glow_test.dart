import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/widgets/profile_photo.dart';

void main() {
  test('samples the dominant colored area of an avatar', () async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 16, 16),
      ui.Paint()..color = const ui.Color(0xffcd442a),
    );
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 4, 16),
      ui.Paint()..color = const ui.Color(0xff3782c5),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(16, 16);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();

    expect(
      await samplePhotoGlow(bytes!.buffer.asUint8List()),
      const ui.Color(0xffcd442a),
    );
  });
}
