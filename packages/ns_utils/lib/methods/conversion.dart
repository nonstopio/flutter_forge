import '../constants.dart';
import '../src.dart';

///Parse to int or returns [defaultValue]
///
int toInt(
  Object value, {
  int defaultValue = defaultInt,
}) {
  int number = defaultValue;
  try {
    number = toDouble(value).toInt();
  } on Exception catch (e, s) {
    errorLogsNS("toInt", e, s);
  }
  return number;
}

///Parse to double or returns [defaultValue]
///
double toDouble(
  Object value, {
  double defaultValue = defaultDouble,
}) {
  double number = defaultDouble;
  try {
    number = double.parse('$value');
  } on Exception catch (e, s) {
    errorLogsNS("toDouble", e, s);
  }
  return number;
}
