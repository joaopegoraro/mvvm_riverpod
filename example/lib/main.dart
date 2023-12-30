// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

void main() {
  // change this to test the Widget or the Builder
  const useWidget = true;
  if (useWidget) {
    // When you are using a top-level widget
    // to observe the ViewModel, make sure there is a Scaffold
    // above it, otherwise Snackbars or other context dependent
    // components may not work
    runApp(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MyAppWithWidget(),
          ),
        ),
      ),
    );
  } else {
    runApp(
      const ProviderScope(
        child: MyAppWithBuilder(),
      ),
    );
  }
}

class MyAppWithBuilder extends StatelessWidget {
  const MyAppWithBuilder({super.key});

  void _listenToEvents(
    BuildContext context,
    MyViewModel model,
    MyEvent event,
  ) {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ViewModelBuilder(
          provider: myViewModelProvider,
          onEventEmitted: _listenToEvents,
          builder: (context, model) {
            return Center(
              child: TextButton(
                onPressed: model.doSomething,
                child: model.isLoading
                    ? const CircularProgressIndicator()
                    : const Text("DO SOMETHING"),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyAppWithWidget extends ViewModelWidget<MyViewModel, MyEvent> {
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

enum MyEvent {
  showSnackbar,
}

class MyViewModel extends ViewModel<MyEvent> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void doSomething() {
    updateUi(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 3)).whenComplete(() {
      updateUi(() => _isLoading = false);
      showSnackbar("Something was done!", MyEvent.showSnackbar);
    });
  }
}

final myViewModelProvider = ViewModelProviderFactory.create((ref) {
  return MyViewModel();
});
