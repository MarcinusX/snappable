# snappable

Check out [blog post](https://fidev.io/thanos) describing the package on [Fidev](https://fidev.io).

## Getting Started

### Import it
```dart
import 'package:snappable/snappable.dart';
```

### Wrap any widget in Snappable
```dart
@override
Widget build(BuildContext context) {
  return Snappable(
    child: Text('This whill be snapped'),
  );
}
```
#### Snap with a Key
```dart

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final key = GlobalKey<SnappableState>();

  @override
  Widget build(BuildContext context) {
    return Snappable(
      key: key,
      child: Text('This whill be snapped'),
    );
  }
  
  void snap() {
    key.currentState.snap();
  }
}
```
Undo by `currentState.reset()`.
#### or snap by tap
```dart

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Snappable(
      snapOnTap: true,
      child: Text('This whill be snapped'),
    );
  }
}
```
 Undo by tapping again.
