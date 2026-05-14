class OrganizerRequest {
  final String id;
  final String uid;
  final String organizationName;
  final String email;
  final String phone;
  final bool phoneVerified;
  final String status; // submitted, under_review, approved, rejected
  final String submittedAt; // ISO
  final String? university;
  final String? experience;

  OrganizerRequest({
    required this.id,
    required this.uid,
    required this.organizationName,
    required this.email,
    required this.phone,
    required this.phoneVerified,
    required this.status,
    required this.submittedAt,
    this.university,
    this.experience,
  });

  factory OrganizerRequest.fromJson(String id, Map<String, dynamic> json) =>
      OrganizerRequest(
        id: id,
        uid: json['uid'] as String? ?? '',
        organizationName: json['organizationName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        phoneVerified: json['phoneVerified'] as bool? ?? false,
        status: json['status'] as String? ?? 'submitted',
        submittedAt: json['submittedAt'] as String? ?? '',
        university: json['university'] as String?,
        experience: json['experience'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'organizationName': organizationName,
    'email': email,
    'phone': phone,
    'phoneVerified': phoneVerified,
    'status': status,
    'submittedAt': submittedAt,
    if (university != null) 'university': university,
    if (experience != null) 'experience': experience,
  };
}
