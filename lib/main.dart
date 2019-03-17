import 'package:flutter/material.dart';
import 'package:graph_app/graph.dart';

void main() => runApp(GraphApp());

class GraphApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph App',
      theme: ThemeData.dark(),
      home: GraphPage(),
    );
  }
}

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  TextEditingController textController;
  String formula;

  @override
  void initState() {
    textController = TextEditingController(text: 'x');
    formula = textController.text;
    textController.addListener(() => formula = textController.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: ListView(
        children: <Widget>[
          GraphWidget(
            formula: formula,
            size: Size.square(MediaQuery.of(context).size.width),
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          ),
          TextField(
            controller: textController,
          ),
          RaisedButton(
            onPressed: () => setState(() {}),
            child: Text('DRAW'),
          ),
        ],
      ),
    ));
  }
}
