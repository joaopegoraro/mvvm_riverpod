import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ViewModelProvider<T extends ChangeNotifier>
    = AutoDisposeChangeNotifierProvider<T>;
typedef ViewModelRef<T extends ChangeNotifier>
    = AutoDisposeChangeNotifierProviderRef<T>;

class ViewModelProviderFactory {
  /// Creates a [ChangeNotifierProvider] with autoDispose
  static ViewModelProvider<T> create<T extends ChangeNotifier>(
    T Function(ViewModelRef<T> ref) create,
  ) {
    return ChangeNotifierProvider.autoDispose<T>((ref) {
      return create(ref);
    });
  }
}
