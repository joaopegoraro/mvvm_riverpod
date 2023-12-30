# mvvm_riverpod
[![pub package](https://img.shields.io/pub/v/mvvm_riverpod)](https://pub.dev/packages/mvvm_riverpod)

Very simple implementation of the MVVM architecture using 
[Riverpod](https://pub.dev/packages/riverpod/install), heavily inspired by the 
[Stacked](https://pub.dev/packages/stacked) architecture;

## Dependencies

This package needs [Riverpod](https://pub.dev/packages/riverpod/install) for it 
to function, so you need to install it too.

## Getting started

### With Flutter:

```bash
$ flutter pub add mvvm_riverpod
```

This will add a line like this to your package's pubspec.yaml (and run an 
implicit flutter pub get):

```yaml
dependencies:
  mvvm_riverpod: [latest_version]
```

Alternatively, your editor might support flutter pub get. Check the docs for 
your editor to learn more.

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
    // You can use the updateUi method to execute a block of code
    // that will call notifyListeners() at the end of it
    updateUi(() => _isLoading = true);

    _apiService.login(_email, _password).catchError((err) {
      // You can use the showSnackbar method to update the inherited
      // snackbarMessage field and emit an event, presumably one 
      // that will show a snackbar in the view
      showSnackbar(err.message, LoginEvent.showSnackbar);
    }).then((_) {
      // You can use the emitEvent method to emit an event to the ViewModel
      // eventStream that will be listened to inside the ViewModelBuilder
      // that you will see in the next example
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

#### Using a ViewModel with a Builder
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
                  ? const CircularProgressIndicator()
                  : Text("LOGIN"),
            ),
          ],
        );
      },
    ),
  );
}
```

#### Listening to ViewModel events
The `ViewModelBuilder` has the optional `OnEventEmitted` callback that is 
triggered every time the ViewModel emits an event:
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

If you don't need the widget tree to rebuild when the ViewModel notifies its 
listeners, or you only need access to its methods and/or listen to its events, 
you can use the `ViewModelBuilder.nonReactive` constructor:

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
The `ViewModelBuilder` has both an `onCreate` and `onDispose` callbacks that 
are triggered when the ViewModel is created or disposed:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ViewModelBuilder(
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

### Using a ViewModel with a Widget
If you feel a Widget is less verbose than a Builder like `ViewModelBuilder`, you can
use the `ViewModelWidget` to simplify things. But beware, the entire `Widget` will be 
rebuilt whenever the `ViewModel` updates, unless `reactive` is set to false. Also, if you 
plan on using `Snackbars` or similar `Scaffold` dependent components, make sure there is at 
least one `Scaffold` above the widget.

```dart
class MyWidget extends ViewModelWidget<MyViewModel, MyEvent> {
  const MyAppWithWidget({super.key});

  // this is optional, by default it is true
  @override
  bool get reactive => true;

  @override
  ViewModelProvider<MyViewModel> get provider => myViewModelProvider;

  // this is also optional
  @override
  void onEventEmitted(BuildContext context, MyViewModel model, MyEvent event) {
    switch (event) {
      case MyEvent.showSnackbar:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(model.snackbarMessage ?? ""),
          ),
        );
    }
  }

  @override
  Widget buildWidget(BuildContext context, MyViewModel model) {
    return Center(
      child: TextButton(
        onPressed: model.doSomething,
        child: model.isLoading
            ? const CircularProgressIndicator()
            : const Text("DO SOMETHING"),
      ),
    );
  }
}
```
