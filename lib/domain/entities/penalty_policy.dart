class PenaltyPolicy {
  const PenaltyPolicy({
    this.enabled = false,
    this.flatAmount = 0,
    this.ratePerFortnightPercent = 0,
    this.graceDays = 0,
  });

  final bool enabled;
  final double flatAmount;
  final double ratePerFortnightPercent;
  final int graceDays;

  PenaltyPolicy copyWith({
    bool? enabled,
    double? flatAmount,
    double? ratePerFortnightPercent,
    int? graceDays,
  }) =>
      PenaltyPolicy(
        enabled: enabled ?? this.enabled,
        flatAmount: flatAmount ?? this.flatAmount,
        ratePerFortnightPercent:
            ratePerFortnightPercent ?? this.ratePerFortnightPercent,
        graceDays: graceDays ?? this.graceDays,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'flatAmount': flatAmount,
        'ratePerFortnightPercent': ratePerFortnightPercent,
        'graceDays': graceDays,
      };

  factory PenaltyPolicy.fromJson(Map<String, dynamic> json) => PenaltyPolicy(
        enabled: json['enabled'] as bool? ?? false,
        flatAmount: (json['flatAmount'] as num?)?.toDouble() ?? 0,
        ratePerFortnightPercent:
            (json['ratePerFortnightPercent'] as num?)?.toDouble() ?? 0,
        graceDays: json['graceDays'] as int? ?? 0,
      );

  static const PenaltyPolicy defaultPolicy = PenaltyPolicy();
}
