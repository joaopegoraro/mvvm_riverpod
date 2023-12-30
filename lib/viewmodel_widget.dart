import 'package:flutter/material.dart';
import 'package:mvvm_riverpod/viewmodel.dart';
import 'package:mvvm_riverpod/viewmodel_builder.dart';
import 'package:mvvm_riverpod/viewmodel_provider.dart';

abstract class ViewModelWidget<VM extends ViewModel<EVENT>, EVENT>
    extends StatelessWidget {
  const ViewModelWidget({super.key});

  /// The [ViewModel] provider
  abstract final ViewModelProvider<VM> provider;

  /// Whether or not to rebuild when the [ViewModel] calls notifyListeners();
  final bool reactive = true;

  /// The callback that is called everytime the [ViewModel.eventStream] emits a new value
  void onEventEmitted(BuildContext context, VM model, EVENT event) {}

  Widget buildWidget(BuildContext context, VM model);

  @override
  Widget build(BuildContext context) {
    if (reactive) {
      return ViewModelBuilder(
          provider: provider,
          onEventEmitted: onEventEmitted,
          builder: buildWidget);
    } else {
      return ViewModelBuilder.nonReactive(
          provider: provider,
          onEventEmitted: onEventEmitted,
          builder: buildWidget);
    }
  }
}
