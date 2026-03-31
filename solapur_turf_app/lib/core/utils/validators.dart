/// Form validation utilities.
class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = num.tryParse(value);
    if (n == null || n <= 0) return '$fieldName must be a positive number';
    return null;
  }

  static String? teamCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Team code is required';
    if (value.trim().length != 8) return 'Team code must be 8 characters';
    return null;
  }
}
