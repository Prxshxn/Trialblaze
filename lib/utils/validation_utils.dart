// validation_utils.dart

class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    // Only allow letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }
    
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    
    if (age > 120) {
      return 'Please enter a valid age';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any non-digit characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanPhone.length < 10) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  static String? validateHikingExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hiking experience is required';
    }
    
    if (value.isEmpty) {
      return 'Please provide more details about your hiking experience';
    }
    
    return null;
  }

  static String? validateResponderType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Responder type is required';
    }
    
    final validTypes = ['medical', 'search', 'rescue', 'police', 'ranger'];
    if (!validTypes.contains(value.toLowerCase())) {
      return 'Please enter a valid responder type';
    }
    
    return null;
  }

  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    
    final validGenders = ['male', 'female', 'other', 'prefer not to say'];
    if (!validGenders.contains(value.toLowerCase())) {
      return 'Please enter a valid gender';
    }
    
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    
    if (value.length < 5) {
      return 'Please enter a valid location';
    }
    
    return null;
  }
}