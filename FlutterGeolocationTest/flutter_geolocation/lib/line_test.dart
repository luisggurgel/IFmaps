import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LineBetweenPointsDemo(),
    );
  }
}

class LineBetweenPointsDemo extends StatefulWidget {
  const LineBetweenPointsDemo({super.key});
  @override
  State<LineBetweenPointsDemo> createState() => _LineBetweenPointsDemoState();
}

class _LineBetweenPointsDemoState extends State<LineBetweenPointsDemo> {
  Offset? p1;
  Offset? p2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linha dinâmica entre dois pontos')),
      body: LayoutBuilder(builder: (context, constraints) {
        // inicializa posições relativas na primeira build
        p1 ??= Offset(constraints.maxWidth * 0.25, constraints.maxHeight * 0.5);
        p2 ??= Offset(constraints.maxWidth * 0.75, constraints.maxHeight * 0.5);

        return Stack(
          children: [
            // área de desenho (ocupa tudo)
            SizedBox.expand(
              child: CustomPaint(
                painter: LinePainter(p1!, p2!),
              ),
            ),

            // Ponto 1 - arrastável
            Positioned(
              left: p1!.dx - 16, // centraliza o círculo
              top: p1!.dy - 16,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final nx = (p1!.dx + details.delta.dx)
                        .clamp(0.0, constraints.maxWidth)
                        .toDouble();
                    final ny = (p1!.dy + details.delta.dy)
                        .clamp(0.0, constraints.maxHeight)
                        .toDouble();
                    p1 = Offset(nx, ny);
                  });
                },
                child: _buildHandle(Colors.red),
              ),
            ),

            // Ponto 2 - arrastável
            Positioned(
              left: p2!.dx - 16,
              top: p2!.dy - 16,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final nx = (p2!.dx + details.delta.dx)
                        .clamp(0.0, constraints.maxWidth)
                        .toDouble();
                    final ny = (p2!.dy + details.delta.dy)
                        .clamp(0.0, constraints.maxHeight)
                        .toDouble();
                    p2 = Offset(nx, ny);
                  });
                },
                child: _buildHandle(Colors.green),
              ),
            ),
          ],
        );
      }),
    );
  }

  // widget circular para representar o "nó"
  Widget _buildHandle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0,2), color: Colors.black26)],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Offset p1;
  final Offset p2;
  LinePainter(this.p1, this.p2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // linha direta
    canvas.drawLine(p1, p2, paint);

    // exemplo: desenhar um ponto central (opcional)
    // final center = (p1 + p2) / 2;
    // canvas.drawCircle(center, 6, Paint()..color = Colors.orange);
  }

  @override
  bool shouldRepaint(covariant LinePainter old) {
    // repaint quando os pontos mudarem
    return old.p1 != p1 || old.p2 != p2;
  }
}
