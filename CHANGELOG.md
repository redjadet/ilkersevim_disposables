# Changelog

## 0.1.4

- Fix `DisposableBag.trackSubscription`, `trackController`, and `trackTimer`
  leaking resources when called after the bag has been disposed (they now
  clean up immediately, matching `addSync` / `addAsync` and the managers).

## 0.1.3

- Raise minimum SDK to Dart `>=3.13.0`.
- Pin CI to Dart 3.13.2 stable.

## 0.1.2

- Explain how grouped, idempotent cleanup prevents resource leaks.
- Rewrite package metadata around subscription, timer, controller, and callback
  ownership.

## 0.1.1

- Patch release for OIDC publish verification.

## 0.1.0

- Initial release: `TimerDisposable`, `DisposableBag`, `SubscriptionManager`,
  and `TimerHandleManager`.
