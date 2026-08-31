import 'dart:async';

import 'package:ilkersevim_disposables/ilkersevim_disposables.dart';
import 'package:test/test.dart';

void main() {
  group('SubscriptionManager', () {
    test('cancelRegistered cancels and untracks the subscription', () async {
      final SubscriptionManager manager = SubscriptionManager();
      final _CountingSubscription<int> subscription =
          _CountingSubscription<int>();

      manager.register(subscription);
      await manager.cancelRegistered(subscription);
      await manager.dispose();

      expect(subscription.cancelCount, 1);
    });

    test(
      'clear cancels current subscriptions without disposing the manager',
      () async {
        final SubscriptionManager manager = SubscriptionManager();
        final _CountingSubscription<int> first = _CountingSubscription<int>();
        final _CountingSubscription<int> second = _CountingSubscription<int>();

        manager.register(first);
        await manager.clear();
        manager.register(second);
        await manager.dispose();

        expect(manager.isDisposed, isTrue);
        expect(first.cancelCount, 1);
        expect(second.cancelCount, 1);
      },
    );

    test('register after dispose cancels immediately', () async {
      final SubscriptionManager manager = SubscriptionManager();
      final _CountingSubscription<int> subscription =
          _CountingSubscription<int>();

      await manager.dispose();
      manager.register(subscription);

      expect(subscription.cancelCount, 1);
    });
  });
}

class _CountingSubscription<T> implements StreamSubscription<T> {
  int cancelCount = 0;
  bool _isPaused = false;

  @override
  Future<void> cancel() async {
    cancelCount++;
  }

  @override
  Future<E> asFuture<E>([E? futureValue]) =>
      Future<E>.value(futureValue as E);

  @override
  bool get isPaused => _isPaused;

  @override
  void onData(void Function(T data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {
    _isPaused = true;
    resumeSignal?.whenComplete(resume);
  }

  @override
  void resume() {
    _isPaused = false;
  }
}
