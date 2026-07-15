import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

const Duration completionCheckDuration = Duration(milliseconds: 1000);
const Duration completionCardFlightDuration = Duration(milliseconds: 800);

/// 完了時のチェックマークを画面中央に表示する。
Future<void> showCompletionCheckOverlay({
  required BuildContext context,
  required bool disableAnimations,
}) async {
  if (disableAnimations) {
    return;
  }

  final overlay = Overlay.of(context);
  final completed = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CompletionCheckOverlay(
      onCompleted: () {
        if (!completed.isCompleted) {
          completed.complete();
        }
      },
    ),
  );
  overlay.insert(entry);
  await completed.future;
  entry.remove();
}

/// 実施中カードのコピーを履歴タブへ移動・縮小して消す。
Future<void> showCompletionCardFlightOverlay({
  required BuildContext context,
  required Rect sourceRect,
  required Offset targetCenter,
  required String suggestionTitle,
  required bool disableAnimations,
}) async {
  if (disableAnimations) {
    return;
  }

  final overlay = Overlay.of(context);
  final completed = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CompletionCardFlightOverlay(
      sourceRect: sourceRect,
      targetCenter: targetCenter,
      suggestionTitle: suggestionTitle,
      onCompleted: () {
        if (!completed.isCompleted) {
          completed.complete();
        }
      },
    ),
  );
  overlay.insert(entry);
  await completed.future;
  entry.remove();
}

class _CompletionCheckOverlay extends StatefulWidget {
  const _CompletionCheckOverlay({required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<_CompletionCheckOverlay> createState() =>
      _CompletionCheckOverlayState();
}

class _CompletionCheckOverlayState extends State<_CompletionCheckOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: completionCheckDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          final badgeProgress = Curves.elasticOut.transform(
            (progress / 0.6).clamp(0.0, 1.0),
          );
          final checkProgress = ((progress - 0.2) / 0.5).clamp(0.0, 1.0);
          final fadeOut = 1 - ((progress - 0.82) / 0.18).clamp(0.0, 1.0);

          return Opacity(
            opacity: fadeOut,
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.28),
              child: Center(
                child: Transform.scale(
                  scale: badgeProgress,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: CustomPaint(
                      size: const Size.square(64),
                      painter: _CheckMarkPainter(
                        progress: checkProgress,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckMarkPainter extends CustomPainter {
  const _CheckMarkPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final firstPoint = Offset(size.width * 0.2, size.height * 0.52);
    final middlePoint = Offset(size.width * 0.43, size.height * 0.72);
    final lastPoint = Offset(size.width * 0.82, size.height * 0.28);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    const firstSegmentEnd = 0.4;
    final path = Path()..moveTo(firstPoint.dx, firstPoint.dy);
    if (progress <= firstSegmentEnd) {
      final segmentProgress = progress / firstSegmentEnd;
      final point = Offset.lerp(firstPoint, middlePoint, segmentProgress)!;
      path.lineTo(point.dx, point.dy);
    } else {
      path.lineTo(middlePoint.dx, middlePoint.dy);
      final segmentProgress =
          (progress - firstSegmentEnd) / (1 - firstSegmentEnd);
      final point = Offset.lerp(middlePoint, lastPoint, segmentProgress)!;
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _CompletionCardFlightOverlay extends StatefulWidget {
  const _CompletionCardFlightOverlay({
    required this.sourceRect,
    required this.targetCenter,
    required this.suggestionTitle,
    required this.onCompleted,
  });

  final Rect sourceRect;
  final Offset targetCenter;
  final String suggestionTitle;
  final VoidCallback onCompleted;

  @override
  State<_CompletionCardFlightOverlay> createState() =>
      _CompletionCardFlightOverlayState();
}

class _CompletionCardFlightOverlayState
    extends State<_CompletionCardFlightOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: completionCardFlightDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sourceSize = widget.sourceRect.size;
    final endScale = 28 / sourceSize.longestSide;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOutCubic.transform(_controller.value);
          final center = Offset.lerp(
            widget.sourceRect.center,
            widget.targetCenter,
            progress,
          )!;
          final scale = lerpDouble(1, endScale, progress)!;
          final opacity =
              1 - Curves.easeIn.transform(((progress - 0.72) / 0.28).clamp(0, 1));

          return Stack(
            children: [
              Positioned(
                left: center.dx - sourceSize.width / 2,
                top: center.dy - sourceSize.height / 2,
                width: sourceSize.width,
                height: sourceSize.height,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Material(
                      elevation: 8,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'よりみち完了',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.suggestionTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
