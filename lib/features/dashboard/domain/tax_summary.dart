class TaxSummary {
  final int totalCount;
  final double totalSpent;
  final double taxSavingsEstimate;
  final Map<String, double> categories;

  TaxSummary({
    required this.totalCount,
    required this.totalSpent,
    required this.taxSavingsEstimate,
    required this.categories,
  });

  factory TaxSummary.fromJson(Map<String, dynamic> json) {
    return TaxSummary(
      totalCount: json['total_count'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      taxSavingsEstimate: (json['tax_savings_estimate'] ?? 0).toDouble(),
      categories: Map<String, double>.from(
        (json['categories'] ?? {}).map((k, v) => MapEntry(k, v.toDouble())),
      ),
    );
  }
}
