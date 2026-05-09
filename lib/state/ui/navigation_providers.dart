import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global bottom navigation index shared across all screens.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

