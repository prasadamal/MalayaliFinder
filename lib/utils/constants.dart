/// App-wide constants for MalayaliFinder.
class AppConstants {
  AppConstants._();

  static const String appName = 'MalayaliFinder';
  static const String appTagline = 'Find your Mallu tribe 🌴';

  // Detection radius options in km
  static const List<double> radarRanges = [1, 5, 10, 25, 50];
  static const double defaultRadarRange = 10.0;

  // Questionnaire pass threshold (out of 10 questions, need 7 correct)
  static const int questionsRequired = 10;
  static const int minimumCorrectAnswers = 7;

  // Event constraints
  static const int eventMinParticipants = 3;
  static const int eventMaxParticipants = 50;

  // Default centre (Kochi, Kerala) used when location is unavailable
  static const double defaultLat = 9.9312;
  static const double defaultLon = 76.2673;

  // Kerala districts
  static const List<String> keralaDistricts = [
    'Thiruvananthapuram',
    'Kollam',
    'Pathanamthitta',
    'Alappuzha',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Thrissur',
    'Palakkad',
    'Malappuram',
    'Kozhikode',
    'Wayanad',
    'Kannur',
    'Kasaragod',
  ];
}
