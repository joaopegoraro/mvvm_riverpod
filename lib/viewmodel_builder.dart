import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_riverpod/viewmodel.dart';
import 'package:mvvm_riverpod/viewmodel_provider.dart';

class ViewModelBuilder<VM extends ViewModel<EVENT>, EVENT>
    extends ConsumerStatefulWidget {
  const ViewModelBuilder({
    super.key,
    required this.provider,
    required this.builder,
    this.onEventEmitted,
    this.onCreate,
    this.onDispose,
  }) : _nonReactive = false;

  /// Constructor that creates a [ViewModel] view that doesn't rebuild when the [ViewModel] calls notifyListeners();
  const ViewModelBuilder.nonReactive({
    super.key,
    required this.provider,
    required this.builder,
    this.onEventEmitted,
    this.onCreate,
    this.onDispose,
  }) : _nonReactive = true;

  /// The [ViewModel] provider
  final ViewModelProvider<VM> provider;

  /// The callback that is called everytime the [ViewModel.eventStream] emits a new value
  final void Function(BuildContext, VM, EVENT)? onEventEmitted;

  /// The callback that is called when the [ViewModel] is created
  final void Function(VM)? onCreate;

  /// The callback that is called when the [ViewModel] is disposed
  final void Function()? onDispose;

  /// Whether or not the [build] method should rebuild when the [ViewModel] calls to notify its listeners
  final bool _nonReactive;

  final Widget Function(BuildContext context, VM value) builder;

  @override
  ConsumerState<ViewModelBuilder> createState() =>
      ViewModelBuilderState<VM, EVENT>();
}

class ViewModelBuilderState<VM extends ViewModel<E>, E>
    extends ConsumerState<ViewModelBuilder<VM, E>> {
  StreamSubscription<E>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    final model = ref.read(widget.provider);
    widget.onCreate?.call(model);
    if (widget.onEventEmitted != null) {
      _eventSubscription = model.eventStream?.listen((event) {
        widget.onEventEmitted?.call(context, model, event);
      });
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._nonReactive) {
      // this watch is needed so the provider is not destroyed after the .read call at initState
      ref.watch(widget.provider.select((_) {}));
      final model = ref.read(widget.provider);
      return widget.builder(context, model);
    }
    final model = ref.watch(widget.provider);
    return widget.builder(context, model);
  }
}
