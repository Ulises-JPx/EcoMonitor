import 'package:flutter/material.dart';
import 'package:frontend/data/models/sensor_data.dart';
import 'package:frontend/core/utils/time_utils.dart';

class SensorDetailScreen extends StatefulWidget {
  final String backendKey;
  final String displayName;
  final List<SensorData> data;

  const SensorDetailScreen({super.key, required this.backendKey, required this.displayName, required this.data});

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Convert data values to doubles for plotting and build labels
    final data = widget.data;
    final values = data.map((d) {
      final v = d.value;
      if (v is num) return v.toDouble();
      return double.tryParse(d.value?.toString() ?? '') ?? 0.0;
    }).toList();
    final unit = data.isNotEmpty ? data.last.unit : '';
    // X labels: start, mid, end timestamps (short)
    String _short(String ts) {
      try {
        final dt = DateTime.parse(ts).toLocal();
        return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
      } catch (_) {
        return ts;
      }
    }
    final labelsX = <String>[];
    if (data.isNotEmpty) {
      labelsX.add(_short(data.first.timestamp));
      labelsX.add(_short(data[data.length ~/ 2].timestamp));
      labelsX.add(_short(data.last.timestamp));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.displayName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Description: Shows the latest reading and historical values for this sensor.'),
                    const SizedBox(height: 8),
                    Text('Latest value: ${data.isNotEmpty ? data.last.value : '--'} ${data.isNotEmpty ? data.last.unit : ''}'),
                    const SizedBox(height: 4),
                    Text('Timestamp: ${data.isNotEmpty ? data.last.timestamp : '--'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: values.isEmpty
                      ? const Center(child: Text('No hay datos históricos para este sensor'))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Unidad: $unit', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  Text('Puntos: ${values.length}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: (details) {
                                  // compute nearest point index based on tap x
                                  final box = context.findRenderObject() as RenderBox;
                                  final local = box.globalToLocal(details.globalPosition);
                                  final width = box.size.width - 24; // padding accounted
                                  final dx = data.length > 1 ? width / (data.length - 1) : width;
                                  final idx = (local.dx / dx).clamp(0, data.length - 1).round();
                                  final idx2 = idx.clamp(0, data.length - 1);
                                  final d = data[idx2];
                                  showModalBottomSheet(context: context, builder: (_) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text('Value: ${d.value} ${d.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        Text('Time: ${friendlyTimestamp(d.timestamp)}'),
                                      ]),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: CustomPaint(
                                    painter: LineChartPainter(values, unit: unit, labelsX: labelsX),
                                    child: Container(),
                                  ),
                                ),
                              ),
                            ),
                            // X axis labels
                            if (labelsX.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: labelsX.map((l) => Text(l, style: const TextStyle(fontSize: 12, color: Colors.black54))).toList(),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final String unit;
  final List<String> labelsX;
  LineChartPainter(this.values, {this.unit = '', this.labelsX = const []});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    // primary paint replaced later with gradient linePaint

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

  final dx = values.length > 1 ? size.width / (values.length - 1) : size.width;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }

    // draw grid lines and Y labels
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke;
    final labelStyle = TextStyle(fontSize: 11, color: Colors.black54);
    final textPainter = (String text, Offset offset) {
      final tp = TextPainter(text: TextSpan(text: text, style: labelStyle), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, offset);
    };

    for (var i = 0; i <= 4; i++) {
      final yy = size.height * i / 4;
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), gridPaint);
      // compute label value (invert i since y=0 is top)
      final v = (maxV - (range * i / 4));
      textPainter(v.toStringAsFixed(2), Offset(4, yy - 8));
    }

    // draw the line
    final linePaint = Paint()
      ..shader = LinearGradient(colors: [Colors.blue.shade700, Colors.blueAccent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // gradient fill under the line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    final fillPaint = Paint()
      ..shader = LinearGradient(colors: [Colors.blue.withOpacity(0.18), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // draw small dots on points
    final dotPaint = Paint()..color = Colors.blue.shade700;
    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }

    // legend / unit at top-left
    textPainter('Unit: $unit', Offset(6, 6));
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
