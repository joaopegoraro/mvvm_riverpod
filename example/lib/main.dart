import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_riverpod/viewmodel.dart';
import 'package:mvvm_riverpod/viewmodel_builder.dart';
import 'package:mvvm_riverpod/viewmodel_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _listenToEvents(
    BuildContext context,
    MyViewModel model,
    MyEvent event,
  ) {
    switch (event) {
      case MyEvent.showSnackbar:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(model.snackbarMessage ?? ""),
        ));
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
