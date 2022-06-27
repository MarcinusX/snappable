# snappable

Thanos effect library in Flutter

Check out [blog post](https://fidev.io/thanos) describing the package on [Fidev](https://fidev.io).

## Examples
![Example 1](https://user-images.githubusercontent.com/16286046/62490322-51313680-b7c9-11e9-91f2-1363c292f544.gif)
![Example 2](https://user-images.githubusercontent.com/16286046/62490326-52626380-b7c9-11e9-9ed3-5545e3175cb6.gif)
![Example 3](https://user-images.githubusercontent.com/16286046/62490340-5bebcb80-b7c9-11e9-8bcf-e94c18f25f1b.gif)


## Getting Started

### Import it
```dart
import 'package:snappable/snappable.dart';
```

#### Snap with a Key
```dart

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _snappableKey = GlobalKey<SnappableState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap'),
      ),
      body: Column(
        children: <Widget>[
          Snappable(
            key: _snappableKey,
            snapOnTap: true,
            onSnapped: () => print("Snapped!"),
            child: Card(
              child: Container(
                height: 300,
                width: double.infinity,
                color: Colors.deepPurple,
                alignment: Alignment.center,
                child: Text(
                  'This will be sanpped',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
          RaisedButton(
            child: const Text('Snap / Reverse'),
            onPressed: () {
              SnappableState state = _snappableKey.currentState!;
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
 ```
