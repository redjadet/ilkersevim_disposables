# ilkersevim_disposables

Centralized disposable resource helpers for Dart: a bag for sync/async cleanup,
subscription and timer-handle managers, and the `TimerDisposable` contract.
Dependency-free beyond the Dart SDK.

License: [Apache-2.0](LICENSE). Issues:
[github.com/redjadet/ilkersevim_disposables/issues](https://github.com/redjadet/ilkersevim_disposables/issues).

## Installation

```yaml
dependencies:
  ilkersevim_disposables: ^0.1.0
```

Requires Dart `>=3.12.0`.

## Usage

```dart
import 'package:ilkersevim_disposables/ilkersevim_disposables.dart';

final bag = DisposableBag();
bag.addSync(() { /* cleanup */ });
await bag.dispose();

final subs = SubscriptionManager();
subs.register(stream.listen(...));
await subs.dispose();

final timers = TimerHandleManager();
timers.register(handle);
await timers.dispose();
```

## API

- `mixin TimerDisposable { void dispose(); }`
- `DisposableBag` — register sync/async dispose actions, subscriptions,
  controllers, and `TimerDisposable` handles
- `SubscriptionManager` — track `StreamSubscription`s with clear/dispose
- `TimerHandleManager` — track `TimerDisposable` handles with clear/dispose
