class ApiConfig {
  static const String baseUrl = 'https://api.petpeeves.com/v1';
  
  // Measurement endpoints
  static String getMeasurements(String petId) => '/pets/$petId/measurements';
  static String getMeasurement(String petId, String measurementId) => '/pets/$petId/measurements/$measurementId';
  static String addMeasurement(String petId) => '/pets/$petId/measurements';
  static String updateMeasurement(String petId, String measurementId) => '/pets/$petId/measurements/$measurementId';
  static String deleteMeasurement(String petId, String measurementId) => '/pets/$petId/measurements/$measurementId';
} 