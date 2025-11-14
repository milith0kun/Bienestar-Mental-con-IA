import '../constants/app_constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña es demasiado larga';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una minúscula';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }

    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    return null;
  }

  // Journal entry validation
  static String? validateJournalEntry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Escribe algo en tu diario';
    }

    if (value.length > AppConstants.maxJournalEntryLength) {
      return 'La entrada es demasiado larga (máximo ${AppConstants.maxJournalEntryLength} caracteres)';
    }

    return null;
  }

  // Mood note validation
  static String? validateMoodNote(String? value) {
    if (value != null && value.length > AppConstants.maxMoodNoteLength) {
      return 'La nota es demasiado larga (máximo ${AppConstants.maxMoodNoteLength} caracteres)';
    }

    return null;
  }

  // Mood value validation
  static String? validateMoodValue(int? value) {
    if (value == null) {
      return 'Selecciona tu estado de ánimo';
    }

    if (value < AppConstants.minMoodValue || value > AppConstants.maxMoodValue) {
      return 'El valor debe estar entre ${AppConstants.minMoodValue} y ${AppConstants.maxMoodValue}';
    }

    return null;
  }
}
