# snappable

Thanos effect library in Flutter

Check out blog post describing the package on Fidev.

## Examples



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

class MyWidget extends StatelessWidget {
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
      snapOntap: true,
      child: Text('This whill be snapped'),
    );
  }
}
```
 Undo by tapping again.