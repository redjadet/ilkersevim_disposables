import 'dart:async';

import 'package:ilkersevim_disposables/ilkersevim_disposables.dart';

void main() async {
  final DisposableBag bag = DisposableBag();
  final StreamController<int> controller = StreamController<int>();
  bag.trackController(controller);
  bag.addSync(() => print('sync cleanup'));

  final SubscriptionManager subs = SubscriptionManager();
  subs.register(
    controller.stream.listen((final int value) {
      print('got $value');
    }),
  );

  controller.add(1);
  await bag.dispose();
  await subs.dispose();
  print('done');
}
