# Tutorial Engine

A reusable spotlight/tutorial engine. It owns tutorial state and persistence;
applications and features own the content, copy, and sequence semantics.

## When to use

Use this package for contextual feature education, replayable walkthroughs, and
spotlights attached to widgets. Use a business feature such as onboarding for
account setup or product-specific onboarding flows.

## Installation

```yaml
dependencies:
  tutorial_engine:
    path: ../../shared/tutorial_engine
```

## Quick start

```dart
final tutorial = TutorialController(
  store: CallbackTutorialStore(
    read: (key) => preferences.getBool(key) ?? false,
    write: (key, value) async {
      await preferences.setBool(key, value);
    },
  ),
);

tutorial.bindSpotlight(featureButtonKey);
tutorial.start('feed.create-task');
```

Render `TutorialLayer` above the app navigator and provide localized content:

```dart
TutorialLayer(
  controller: tutorial,
  contentBuilder: (context, tourId, complete) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FilledButton(onPressed: complete, child: const Text('Done')),
    );
  },
)
```

## Persistence

`MemoryTutorialStore` is suitable for tests. `CallbackTutorialStore` adapts any
key-value storage without coupling the engine to a specific plugin.

## Customization

The package deliberately does not ship product copy or route navigation. Build
multi-step sequencing in the owning feature and use `TutorialController` for
display and seen-state persistence.

## Testing

```bash
flutter test shared/tutorial_engine
```
