import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/primary_button.dart';

/// Parmakla ıslak imza çizimi için alt sayfa.
///
/// Kullanıcı parmağıyla imza atar; "İmzayı Kaydet" denildiğinde çizim
/// şeffaf zemine sahip PNG baytlarına dönüştürülerek döndürülür.
/// Kullanıcı vazgeçerse `null` döner.
class SignaturePadSheet extends StatefulWidget {
  const SignaturePadSheet({super.key});

  static Future<Uint8List?> show(BuildContext context) {
    return showModalBottomSheet<Uint8List>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SignaturePadSheet(),
    );
  }

  @override
  State<SignaturePadSheet> createState() => _SignaturePadSheetState();
}

class _SignaturePadSheetState extends State<SignaturePadSheet> {
  final List<List<Offset>> _strokes = [];
  final GlobalKey _boundaryKey = GlobalKey();
  bool _saving = false;

  void _startStroke(DragStartDetails d) {
    setState(() => _strokes.add([d.localPosition]));
  }

  void _extendStroke(DragUpdateDetails d) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.add(d.localPosition));
  }

  void _clear() {
    if (_strokes.isEmpty) return;
    setState(_strokes.clear);
  }

  Future<void> _save() async {
    if (_strokes.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    try {
      final boundary =
          _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _saving = false);
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      if (data == null) {
        setState(() => _saving = false);
        return;
      }
      final png = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      Navigator.of(context).pop(png);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İmza kaydedilemedi, lütfen tekrar deneyin'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: sub.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.draw_outlined, size: 22, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Islak İmza',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Aşağıdaki alana parmağınızla imzanızı çizin.',
                style: TextStyle(color: sub, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: _startStroke,
                            onPanUpdate: _extendStroke,
                            child: CustomPaint(
                              painter: _SignaturePainter(_strokes),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      ),
                      if (_strokes.isEmpty)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Text(
                                'İmzanızı buraya çizin',
                                style: TextStyle(
                                  color: Color(0xFFB0B0B5),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Temizle',
                      icon: Icons.refresh_rounded,
                      variant: PrimaryButtonVariant.glass,
                      onPressed: _saving ? null : _clear,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'İmzayı Kaydet',
                      icon: Icons.check_rounded,
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.6, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
