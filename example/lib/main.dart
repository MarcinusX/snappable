import 'package:flutter/material.dart';
import 'package:snappable/snappable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _snappableKey = GlobalKey<SnappableState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snap'),
      ),
      body: Column(
        children: <Widget>[
          Snappable(
            key: _snappableKey,
            snapOnTap: true,
            child: Card(
              child: Container(
                height: 300,
                width: double.infinity,
                color: Colors.deepPurple,
                alignment: Alignment.center,
                child: Text(
                  'This will be sanpped',
                  style: Theme.of(context).textTheme.title.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
          RaisedButton(
            child: Text('Snap / Reverse'),
            onPressed: () {
              SnappableState state = _snappableKey.currentState;
              if (state.isGone) {
                state.reset();
              } else {
                state.snap();
              }
            },
          )
        ],
      ),
    );
  }
}
