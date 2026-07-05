class Patient {
  final int? id;
  final String hbaId;
  final String fullName;
  final int? age;
  final String? gender;
  final String? phone;
  final String? address;
  final String? guardianName;

  Patient({
    this.id,
    required this.hbaId,
    required this.fullName,
    this.age,
    this.gender,
    this.phone,
    this.address,
    this.guardianName,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      hbaId: json['hba_id'] ?? '',
      fullName: json['full_name'] ?? '',
      age: json['age'],
      gender: json['gender'],
      phone: json['phone'],
      address: json['address'],
      guardianName: json['guardian_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'guardian_name': guardianName,
    };
  }
}
