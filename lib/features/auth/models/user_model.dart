/// Pure data model — no business logic, no network calls.
class UserModel {
  final String id;
  final String? orgId;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final String? jobTitle;
  final bool emailVerified;
  final DateTime? createdAt;
  final String role; // 'admin' | 'default'
  final bool isActive;

  const UserModel({
    required this.id,
    this.orgId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    this.jobTitle,
    this.emailVerified = false,
    this.createdAt,
    this.role = 'default',
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      orgId: json['org_id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      phone: json['phone'] as String?,
      jobTitle: json['job_title'] as String?,
      role: json['role'] as String? ?? 'default',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (orgId != null) 'org_id': orgId,
    'name': name,
    'email': email,
    if (photoUrl != null) 'photo_url': photoUrl,
    if (phone != null) 'phone': phone,
    if (jobTitle != null) 'job_title': jobTitle,
    'role': role,
    'is_active': isActive,
  };

  UserModel copyWith({
    String? id,
    String? orgId,
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    String? jobTitle,
    bool? emailVerified,
    DateTime? createdAt,
    String? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAdmin => role == 'admin';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
