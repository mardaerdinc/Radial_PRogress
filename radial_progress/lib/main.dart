import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static double percentage = 100.0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RadialProgressWidget(percentage),
    );
  }
}

class Particle {
  double orbit;
  late double originalOrbit;
  late double theta;
  late double opacity;
  late Color color;
  Particle(this.orbit) {
    this.originalOrbit = this.orbit;
    this.theta = GetRandomRange(0.0, 360.0) * pi / 180.0;
    this.opacity = GetRandomRange(0.3, 1.0);
    this.color = Colors.white;
  }
  void Update() {
    this.orbit += 0.1;
    this.opacity -= 0.0025;
    if (this.opacity <= 0.0) {
      this.orbit = this.originalOrbit;
      this.opacity = GetRandomRange(0.1, 1.0);
    }
  }
}

final rnd = Random();

double GetRandomRange(double min, double max) {
  return rnd.nextDouble() * (max - min) + min;
}

Offset PolarToCartesian(double r, double theta) {
  final dx = r * cos(theta);
  final dy = r * sin(theta);
  return Offset(dx, dy);
}

const double radialSize = 100.0;
const double thickness = 10.0;

class RadialProgressWidget extends StatefulWidget {
  final double percentage;
  const RadialProgressWidget(this.percentage);

  @override
  State<RadialProgressWidget> createState() => _RadialProgressWidgetState();
}

class _RadialProgressWidgetState extends State<RadialProgressWidget> {
  var value = 0.0;
  final speed = 0.5;
  late Timer timer;
  final List<Particle> particles = List<Particle>.generate(
      200, (index) => Particle(radialSize + thickness / 2.0));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.timer = Timer.periodic(Duration(milliseconds: 1000 ~/ 60), (timer) {
      var v = value;
      if (v <= widget.percentage) {
        v += speed;
      } else {
        setState(() {
          this.particles.forEach((p) => p.Update());
        });
        print("updated");
      }

      setState(() {
        value = v;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        child: Container(),
        painter: RadialProgressPainter(this.value, this.particles),
      ),
    );
  }
}

final Color col1 = Colors.black;
final Color col2 = Colors.orange;
final Color col3 = Colors.green;
final Color col4 = Colors.blue;
final Color col5 = Colors.purple;

const TextStyle textStyle =
    TextStyle(color: Colors.red, fontSize: 50, fontWeight: FontWeight.bold);

class RadialProgressPainter extends CustomPainter {
  final double percentage;
  final List<Particle> particles;
  RadialProgressPainter(this.percentage, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2.0, size.height / 2.0);
    drawBackground(canvas, c, size.height / 2.0);
    final rect = Rect.fromCenter(
        center: c, width: 2 * radialSize, height: 2 * radialSize);
    //canvas.drawRect(rect, Paint()..color = Colors.grey);
    drawGuide(canvas, c, radialSize);
    drawArc(canvas, rect);
    drawTextCentered(
        canvas, c, "${percentage.toInt()}", textStyle, radialSize * 2 * 0.8);
    if (this.percentage >= 100.0) {
      drawParticles(canvas, c);
    }
  }

  void drawParticles(Canvas canvas, Offset c) {
    this.particles.forEach((p) {
      final cc = PolarToCartesian(p.orbit, p.theta) + c;
      final paint = Paint()..color = p.color.withOpacity(p.opacity);
      canvas.drawCircle(cc, 1.0, paint);
    });
  }

  void drawGuide(Canvas canvas, Offset c, double radius) {
    Paint paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade400;
    canvas.drawCircle(c, radius, paint);
  }

  void drawBackground(Canvas canvas, Offset c, double extent) {
    final rect = Rect.fromCenter(center: c, width: extent, height: extent);
    final bgPaint = Paint()
      ..shader = RadialGradient(colors: [col1, col2]).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPaint(bgPaint);
  }

  void drawArc(Canvas canvas, Rect rect) {
    final fgPaint = Paint()
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [col4, col5],
              tileMode: TileMode.mirror)
          .createShader(rect);
    final startAngle = -90.0 * pi / 180.0;
    final sweepAngle = 360.0 * this.percentage / 100.0 * pi / 180.0;

    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  Size drawTextCentered(Canvas canvas, Offset position, String text,
      TextStyle style, double maxWidth) {
    final tp = measureText(text, style, maxWidth, TextAlign.center);
    tp.paint(canvas, position + Offset(-tp.width / 2.0, -tp.height / 2.0));
    return tp.size;
  }

  TextPainter measureText(
      String text, TextStyle style, double maxWidth, TextAlign alignment) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
        text: span, textAlign: alignment, textDirection: TextDirection.ltr);
    tp.layout(minWidth: 0, maxWidth: maxWidth);
    return tp;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
