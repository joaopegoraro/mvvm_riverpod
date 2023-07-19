import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class ViewModel<EVENT> extends ChangeNotifier {
  ViewModel() {
    eventStream = eventController.stream.asBroadcastStream();
  }

  @protected
  final StreamController<EVENT> eventController = StreamController<EVENT>();
  Stream<EVENT>? eventStream;

  String? _snackbarMessage;
  String? get snackbarMessage => _snackbarMessage;

  /// Set [snackbarMessage] to [message] and emit the [event]
  @protected
  void showSnackbar(String? message, EVENT event) {
    _snackbarMessage = message;
    emitEvent(event);
  }

  /// Emit the [event] to the [eventController] to notify the subscribers of [eventStream]
  @protected
  void emitEvent(EVENT event) {
    eventController.add(event);
  }

  /// Executes the [block] and then notify the listeners of this [ChangeNotifier]
  @protected
  void updateUi(Function block) {
    block();
    notifyListeners();
  }

  @override
  void dispose() {
    eventStream = null;
    eventController.close();
    super.dispose();
  }
}
