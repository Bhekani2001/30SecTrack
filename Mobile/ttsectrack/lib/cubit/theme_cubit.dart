import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(ThemeMode initialState) : super(initialState);

  void toggleTheme(bool isDark) {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
