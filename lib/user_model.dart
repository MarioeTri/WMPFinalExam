class User {
  final int? id;
  final String name;
  final String idNumber;
  final String email;
  final String password;

  User({this.id, required this.name, required this.idNumber, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'id_number': idNumber,
      'email': email,
      'password': password
    };
  }
}
