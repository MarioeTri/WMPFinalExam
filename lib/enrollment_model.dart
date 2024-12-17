class Enrollment {
  final int userId;
  final String subject;
  final int credits;

  Enrollment({required this.userId, required this.subject, required this.credits});

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'subject': subject,
      'credits': credits
    };
  }
}
