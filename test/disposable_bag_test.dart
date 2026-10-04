import 'dart:async';

import 'package:ilkersevim_disposables/ilkersevim_disposables.dart';
import 'package:test/test.dart';

void main() {
  group('DisposableBag', () {
    test(
      'untrack prevents a registered callback from running on clear',
      () async {
        final DisposableBag bag = DisposableBag();
        var disposed = false;

        final Object token = bag.addSync(() {
          disposed = true;
        });
        bag.untrack(token);

        await bag.clear();

        expect(disposed, isFalse);
      },
    );

    test(
      'untracked subscription is not cancelled again during clear',
      () async {
        final DisposableBag bag = DisposableBag();
        final _CountingSubscription<int> subscription =
            _CountingSubscription<int>();

        bag.trackSubscription(subscription);
        bag.untrackSubscription(subscription);
        await subscription.cancel();
        await bag.clear();

        expect(subscription.cancelCount, 1);
      },
    );

    test(
      'dispose cancels tracked subscriptions in reverse registration order',
      () async {
        final DisposableBag bag = DisposableBag();
        final List<String> cancelOrder = <String>[];
        final _CountingSubscription<int> first = _CountingSubscription<int>(
          onCancel: () => cancelOrder.add('first'),
        );
        final _CountingSubscription<int> second = _CountingSubscription<int>(
          onCancel: () => cancelOrder.add('second'),
        );

        bag.trackSubscription(first);
        bag.trackSubscription(second);

        await bag.dispose();

        expect(cancelOrder, <String>['second', 'first']);
      },
    );

    test('trackSubscription after dispose cancels immediately', () async {
      final DisposableBag bag = DisposableBag();
      final _CountingSubscription<int> subscription =
          _CountingSubscription<int>();

      await bag.dispose();
      bag.trackSubscription(subscription);

      expect(subscription.cancelCount, 1);
    });

    test('trackController after dispose closes immediately', () async {
      final DisposableBag bag = DisposableBag();
      final StreamController<int> controller = StreamController<int>();

      await bag.dispose();
      bag.trackController(controller);
      await pumpEventQueue();

      expect(controller.isClosed, isTrue);
    });

    test('trackTimer after dispose disposes immediately', () async {
      final DisposableBag bag = DisposableBag();
      final _CountingTimerDisposable handle = _CountingTimerDisposable();

      await bag.dispose();
      bag.trackTimer(handle);

      expect(handle.disposeCount, 1);
    });
  });
}

class _CountingTimerDisposable implements TimerDisposable {
  int disposeCount = 0;

  @override
  void dispose() {
    disposeCount++;
  }
}

class _CountingSubscription<T> implements StreamSubscription<T> {
  _CountingSubscription({this.onCancel});

  final void Function()? onCancel;
  int cancelCount = 0;
  bool _isPaused = false;

  @override
  Future<void> cancel() async {
    cancelCount++;
    onCancel?.call();
  }

  @override
  Future<E> asFuture<E>([E? futureValue]) => Future<E>.value(futureValue as E);

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
    if (resumeSignal != null) {
      unawaited(resumeSignal.whenComplete(resume));
    }
  }

  @override
  void resume() {
    _isPaused = false;
  }
}
