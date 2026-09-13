class Validators {
  Validators._();

  static String? required(
    String? value, {
    String field = 'Field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  static String? positiveNumber(
    String? value, {
    String field = 'Value',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    final number = double.tryParse(value);

    if (number == null || number <= 0) {
      return '$field must be greater than zero';
    }

    return null;
  }
}
