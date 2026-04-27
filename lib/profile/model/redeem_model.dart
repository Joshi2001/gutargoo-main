class RedeemCode {
  final String id;
  final String code;
  final String? description;
  final bool isUsed;
  final DateTime? expiresAt;
  final dynamic reward;

  RedeemCode({
    required this.id,
    required this.code,
    this.description,
    required this.isUsed,
    this.expiresAt,
    this.reward,
  });

  factory RedeemCode.fromJson(Map<String, dynamic> json) {
    return RedeemCode(
      id: json['_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      isUsed: json['isUsed'] ?? json['is_used'] ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      reward: json['reward'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'isUsed': isUsed,
      'expiresAt': expiresAt?.toIso8601String(),
      'reward': reward,
    };
  }
}