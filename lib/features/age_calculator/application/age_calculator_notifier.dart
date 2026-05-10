import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../domain/models/age_result.dart';

const _unset = Object();

final ageCalculatorProvider =
    NotifierProvider<AgeCalculatorNotifier, AgeCalculatorState>(
      AgeCalculatorNotifier.new,
    );

class AgeCalculatorState {
  const AgeCalculatorState({
    required this.asOfDate,
    this.birthDate,
    this.result,
    this.errorMessage,
  });

  final DateTime? birthDate;
  final DateTime asOfDate;
  final AgeResult? result;
  final String? errorMessage;

  AgeCalculatorState copyWith({
    Object? birthDate = _unset,
    DateTime? asOfDate,
    Object? result = _unset,
    Object? errorMessage = _unset,
  }) {
    return AgeCalculatorState(
      birthDate: birthDate == _unset ? this.birthDate : birthDate as DateTime?,
      asOfDate: asOfDate ?? this.asOfDate,
      result: result == _unset ? this.result : result as AgeResult?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class AgeCalculatorNotifier extends Notifier<AgeCalculatorState> {
  @override
  AgeCalculatorState build() {
    return AgeCalculatorState(asOfDate: AppDateUtils.dateOnly(DateTime.now()));
  }

  void setBirthDate(DateTime date) {
    final birthDate = AppDateUtils.dateOnly(date);
    final asOfDate = AppDateUtils.isAfterDay(birthDate, state.asOfDate)
        ? birthDate
        : state.asOfDate;

    state = state.copyWith(
      birthDate: birthDate,
      asOfDate: asOfDate,
      result: null,
      errorMessage: null,
    );
  }

  void setAsOfDate(DateTime date) {
    state = state.copyWith(
      asOfDate: AppDateUtils.dateOnly(date),
      result: null,
      errorMessage: null,
    );
  }

  void calculate() {
    final birthDate = state.birthDate;
    final asOfDate = state.asOfDate;

    if (birthDate == null) {
      state = state.copyWith(
        result: null,
        errorMessage: 'Select your date of birth first.',
      );
      return;
    }

    if (AppDateUtils.isAfterDay(birthDate, asOfDate)) {
      state = state.copyWith(
        result: null,
        errorMessage: 'Date of birth cannot be after the calculate date.',
      );
      return;
    }

    state = state.copyWith(
      result: AppDateUtils.calculateAge(birthDate, asOfDate),
      errorMessage: null,
    );
  }

  void reset() {
    state = AgeCalculatorState(asOfDate: AppDateUtils.dateOnly(DateTime.now()));
  }
}
