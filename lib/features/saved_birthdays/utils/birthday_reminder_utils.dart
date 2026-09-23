import '../../../core/utils/date_utils.dart';
import '../../age_calculator/models/age_milestone_model.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';

class BirthdayReminderUtils {
  BirthdayReminderUtils._();

  static List<BirthdayLead> applicableLeads(
    DateTime birthDate,
    DateTime now, {
    required List<int> leadDays,
  }) {
    final today = AppDateUtils.dateOnly(now);
    return AgeCalculationUtils.birthdayCountdownLeads(
      birthDate,
      today,
      leadDays: leadDays,
    ).where((lead) => !lead.date.isBefore(today)).toList(growable: false);
  }
}
