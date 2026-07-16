class Patient {
  final int? id;
  final String hbaId;
  final String fullName;
  final int? age;
  final String? gender;
  final String? phone;
  final String? address;
  final String? guardianName;
  final String? photoPath; // 💡 डेटाबेस से मैच करने के लिए जोड़ा गया

  Patient({
    this.id,
    required this.hbaId,
    required this.fullName,
    this.age,
    this.gender,
    this.phone,
    this.address,
    this.guardianName,
    this.photoPath, // 💡 यहाँ भी शामिल किया
  });

  // बैकएंड (JSON) से डेटा लेकर ऐप में ऑब्जेक्ट बनाने के लिए
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
      photoPath: json['photo_path'], // 💡 JSON से डेटा रीड करने के लिए
    );
  }

  // ऐप से डेटा बैकएंड (API) पर भेजने के लिए
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'guardian_name': guardianName,
      'photo_path': photoPath, // 💡 बैकएंड को फोटो का पाथ भेजने के लिए
    };

    // 💡 अगर ऑब्जेक्ट में id या hbaId पहले से मौजूद है (जैसे प्रोफाइल अपडेट के समय), तभी JSON में जुड़ेगी
    if (id != null) data['id'] = id;
    if (hbaId.isNotEmpty) data['hba_id'] = hbaId;

    return data;
  }
}
