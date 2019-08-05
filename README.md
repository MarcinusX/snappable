# snappable

Thanos effect library in Flutter

Check out blog post describing the package on Fidev.

## Examples
![Example 1](https://user-images.githubusercontent.com/16286046/62490322-51313680-b7c9-11e9-91f2-1363c292f544.gif)
![Example 2](https://user-images.githubusercontent.com/16286046/62490326-52626380-b7c9-11e9-9ed3-5545e3175cb6.gif)
![Example 3](https://user-images.githubusercontent.com/16286046/62490340-5bebcb80-b7c9-11e9-8bcf-e94c18f25f1b.gif)


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
