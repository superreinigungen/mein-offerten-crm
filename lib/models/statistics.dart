/// Statistik-Modell für Dashboard-Insights
class Statistics {
  final int totalRequests;
  final int pendingRequests;
  final int sentQuotes;
  final int acceptedQuotes;
  final int rejectedQuotes;
  final int thinkingQuotes;
  final double conversionRate;
  final double averageQuoteValue;
  final double totalRevenue;
  final int hotLeads;
  final Map<String, int> rejectionReasons;
  final List<DailyStats> dailyStats;

  Statistics({
    required this.totalRequests,
    required this.pendingRequests,
    required this.sentQuotes,
    required this.acceptedQuotes,
    required this.rejectedQuotes,
    required this.thinkingQuotes,
    required this.conversionRate,
    required this.averageQuoteValue,
    required this.totalRevenue,
    required this.hotLeads,
    required this.rejectionReasons,
    required this.dailyStats,
  });

  factory Statistics.empty() {
    return Statistics(
      totalRequests: 0,
      pendingRequests: 0,
      sentQuotes: 0,
      acceptedQuotes: 0,
      rejectedQuotes: 0,
      thinkingQuotes: 0,
      conversionRate: 0,
      averageQuoteValue: 0,
      totalRevenue: 0,
      hotLeads: 0,
      rejectionReasons: {},
      dailyStats: [],
    );
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalRequests: json['total_requests'] as int? ?? 0,
      pendingRequests: json['pending_requests'] as int? ?? 0,
      sentQuotes: json['sent_quotes'] as int? ?? 0,
      acceptedQuotes: json['accepted_quotes'] as int? ?? 0,
      rejectedQuotes: json['rejected_quotes'] as int? ?? 0,
      thinkingQuotes: json['thinking_quotes'] as int? ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0,
      averageQuoteValue: (json['average_quote_value'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      hotLeads: json['hot_leads'] as int? ?? 0,
      rejectionReasons: Map<String, int>.from(
        json['rejection_reasons'] as Map<String, dynamic>? ?? {},
      ),
      dailyStats: (json['daily_stats'] as List<dynamic>?)
              ?.map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_requests': totalRequests,
      'pending_requests': pendingRequests,
      'sent_quotes': sentQuotes,
      'accepted_quotes': acceptedQuotes,
      'rejected_quotes': rejectedQuotes,
      'thinking_quotes': thinkingQuotes,
      'conversion_rate': conversionRate,
      'average_quote_value': averageQuoteValue,
      'total_revenue': totalRevenue,
      'hot_leads': hotLeads,
      'rejection_reasons': rejectionReasons,
      'daily_stats': dailyStats.map((e) => e.toJson()).toList(),
    };
  }
}

/// Tägliche Statistiken
class DailyStats {
  final DateTime date;
  final int requests;
  final int quotesSent;
  final int accepted;
  final double revenue;

  DailyStats({
    required this.date,
    required this.requests,
    required this.quotesSent,
    required this.accepted,
    required this.revenue,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      requests: json['requests'] as int? ?? 0,
      quotesSent: json['quotes_sent'] as int? ?? 0,
      accepted: json['accepted'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'requests': requests,
      'quotes_sent': quotesSent,
      'accepted': accepted,
      'revenue': revenue,
    };
  }
}
