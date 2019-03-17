import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Point {
  double x;
  double y;

  Point(this.x, this.y);

  toOffset(Size size, {Step step = const Step()}) =>
      Offset(size.width / 2 + x * step.x, size.height / 2 - y * step.y);

  operator -(Point p) => Point(x, y - p.y);

  operator +(Point p) => Point(x, y + p.y);

  operator *(double t) => Point(x, y * t);
}

class Step {
  final double x;
  final double y;

  const Step({this.x = 30, this.y = 30});
}

class Graph {
  List<Point> points;

  Graph(this.points);

  get isEmpty => points.isEmpty;

  operator [](int i) => points[i];

  operator -(Graph other) =>
      Graph(List.generate(points.length, (i) => this[i] - other[i]));

  operator +(Graph other) =>
      Graph(List.generate(points.length, (i) => this[i] + other[i]));

  operator *(double t) =>
      Graph(List.generate(points.length, (i) => this[i] * t));
}

class GraphWidget extends StatefulWidget {
  final String formula;
  final Size size;
  final Duration duration;
  final Curve curve;

  GraphWidget({this.formula, this.size, this.duration, this.curve, Key key})
      : super(key: key);

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget>
    with SingleTickerProviderStateMixin {
  Tween<Graph> tween;
  AnimationController ctrl;
  Animation<Graph> animation;
  CurvedAnimation curved;

  double _eval(Expression exp, double x) => exp.evaluate(EvaluationType.REAL,
      ContextModel()..bindVariable(Variable('x'), Number(x)));

  Graph _getGraph(String formula) {
    var g = Graph(<Point>[]);
    try {
      Expression exp = Parser().parse(formula);
      double width = widget.size.width;
      double x = width * (-0.5);
      while (x <= width / 2) {
        g.points.add(Point(x, _eval(exp, x)));
        x += 0.1;
      }
    } catch (e) {}
    return g;
  }

  @override
  void initState() {
    ctrl = AnimationController(duration: widget.duration, vsync: this);
    curved = CurvedAnimation(parent: ctrl, curve: widget.curve);
    tween = ConstantTween<Graph>(_getGraph(widget.formula));
    animation = tween.animate(curved);
    super.initState();
  }

  @override
  void didUpdateWidget(GraphWidget oldWidget) {
    ctrl.reset();
    tween = Tween<Graph>(begin: tween.end, end: _getGraph(widget.formula));
    animation = tween.animate(curved);
    ctrl.forward();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => CustomPaint(
            size: widget.size,
            painter: _GPainter(animation.value,
                axesColor: theme.secondaryHeaderColor,
                graphColor: theme.accentColor),
          ),
    );
  }
}

class _GPainter extends CustomPainter {
  Graph graph;
  Color axesColor;
  Color graphColor;

  _GPainter(this.graph, {this.axesColor, this.graphColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = axesColor..strokeWidth = 1.0;
    var width = size.width;
    var x = width / 2;
    canvas
      ..drawLine(Offset(x, 0), Offset(x, width), paint)
      ..drawLine(Offset(0, x), Offset(width, x), paint);

    try {
      graph.points
          .map((point) => point.toOffset(size))
          .where((offset) => size.contains(offset))
          .reduce((p1, p2) {
        canvas.drawLine(p1, p2,
            Paint()
              ..color = graphColor
              ..strokeWidth = 1.0);
        return p2;
      });
    } catch (e) {}
  }

  @override
  bool shouldRepaint(old) => true;
}
