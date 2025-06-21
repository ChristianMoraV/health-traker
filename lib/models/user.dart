class User {
  final String name;
  final String email;
  final String password;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String objective;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.objective,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'objective': objective,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: '', // No almacenar contraseña en producción
      age: json['age'],
      gender: json['gender'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      activityLevel: json['activityLevel'],
      objective: json['objective'],
    );
  }
}
