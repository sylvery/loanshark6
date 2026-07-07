class ReminderPolicy {
  const ReminderPolicy({
    this.enabled = true,
    this.dailyDigest = false,
    this.preDueDays = 2,
    this.overdueRealertDays = 3,
  });

  final bool enabled;
  final bool dailyDigest;
  final int preDueDays;
  final int overdueRealertDays;

  ReminderPolicy copyWith({
    bool? enabled,
    bool? dailyDigest,
    int? preDueDays,
    int? overdueRealertDays,
  }) =>
      ReminderPolicy(
        enabled: enabled ?? this.enabled,
        dailyDigest: dailyDigest ?? this.dailyDigest,
        preDueDays: preDueDays ?? this.preDueDays,
        overdueRealertDays: overdueRealertDays ?? this.overdueRealertDays,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'dailyDigest': dailyDigest,
        'preDueDays': preDueDays,
        'overdueRealertDays': overdueRealertDays,
      };

  factory ReminderPolicy.fromJson(Map<String, dynamic> json) => ReminderPolicy(
        enabled: json['enabled'] as bool? ?? true,
        dailyDigest: json['dailyDigest'] as bool? ?? false,
        preDueDays: json['preDueDays'] as int? ?? 2,
        overdueRealertDays: json['overdueRealertDays'] as int? ?? 3,
      );

  static const ReminderPolicy defaultPolicy = ReminderPolicy();
}
