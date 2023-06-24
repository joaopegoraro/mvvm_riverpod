<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
# mvvm_riverpod

Very simple implementation of the MVVM architechture using [Riverpod](https://pub.dev/packages/riverpod/install), heavily inspired by the [Stacked](https://pub.dev/packages/stacked) architechture;

## Dependencies

This package needs [Riverpod](https://pub.dev/packages/riverpod/install) for it to function, so you need to install it too.

## Getting started

### With Flutter:

```bash
$ flutter pub add mvvm_riverpod
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  mvvm_riverpod: [latest_version]
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

### Import it

Now in your Dart code, you can use:

```dart
import 'package:mvvm_riverpod/mvvm_riverpod.dart';
```

## Usage

### Examples

Here are small examples that show you how to use the package.

#### Declaring a ViewModel
```dart
// this is optional
enum LoginEvent {
  showSnackbar,
  navigateToHomeScreen,
}

class LoginViewModel extends ViewModel<LoginEvent> {
  LoginViewModel(this._apiService);
  final ApiService _apiService;

  (...)

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void performLogin() {
    updateUi(() => _isLoading = true);

    _apiService.login(_email, _password).catchError((err) {
      showSnackbar(err.message, LoginEvent.showSnackbar);
    }).then((_) {
      emitEvent(LoginEvent.navigateToHomeScreen);
    }).whenComplete(() {
      updateUi(() => _isLoading = false);
    });
  }
}

// The provider of the viewmodel, here you can use Riverpod to 
// inject services into the class
final loginViewModelProvider = ViewModelProviderFactory.create((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LoginViewModel(apiService);
});
```

#### Using a ViewModel
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // Use the ViewModelBuilder to access the model
    body: ViewModelBuilder(
      // Pass in the provider of the viewmodel
      provider: loginViewModelProvider,
      // use the ViewModel in the view
      builder: (context, model) {
        return ListView(
          children: [
            (...)
            MaterialButton(
              onPressed: model.performLogin,
              child: model.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "LOGIN",
                      style: bodyStyle.copyWith(color: Colors.white),
                    ),
            ),
            verticalSpaceLarge,
          ],
        );
      },
    ),
  );
}
```

#### Listening to ViewModel events
The `ViewModelBuilder` has the optional `OnEventEmitted` thas is triggered every time the ViewModel emits an event:
```dart
void _listenToEvents(
  BuildContext context,
  LoginViewModel model,
  LoginEvent event,
) {
  switch (event) {
    case LoginEvent.showSnackbar:
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(model.snackbarMessage),
      ));
    case LoginEvent.navigateToHomeScreen:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ViewModelBuilder(
      provider: loginViewModelProvider,
      // Pass in the callback to be executed 
      // everytime the ViewModel emits an event
      onEventEmitted: _listenToEvents,
      builder: (context, model) { ... },
    ),
  );
}
```

#### Accessing the ViewModel without reacting to its changes

If you don't need the widget tree to rebuild when the ViewModel notify its listeners, or you only need access to its methods and/or listen to its events, you can use the `ViewModelBuilder.nonReactive` constructor:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ViewModelBuilder.nonReactive(
      provider: loginViewModelProvider,
      // Still can listen to the events
      onEventEmitted: _listenToEvents,
      builder: (context, model) { 
          // Here you have access to the model, but 
          // the view wont update when it changes
      },
    ),
  );
}
```

#### Observing the ViewModel lifecycle
The `ViewModelBuilder` has both an `onCreate` and `onDispose` callbacks that are triggered when the ViewModel is created or disposed:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ViewModelBuilder.nonReactive(
      provider: loginViewModelProvider,
      onCreate: (model) {
        // do something when the viewmodel is created
      },
      onDispose: () {
        // do something when the viewmodel is disposed
      },
      onEventEmitted: _listenToEvents,
      builder: (context, model) { ... },
    ),
  );
}

```
