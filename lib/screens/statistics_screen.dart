import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';

/// Statistik-Dashboard Screen mit cleveren Insights
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Statistiken & Insights'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final stats = provider.statistics;
          final requests = provider.requests;
          final orders = provider.orders;
          final quotes = provider.quotes;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadStatistics();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UMSATZ HEADER
                  _buildRevenueHeader(stats),
                  
                  const SizedBox(height: 24),

                  // QUICK STATS
                  const _SectionTitle(title: 'Übersicht', icon: Icons.dashboard),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Anfragen',
                          value: '${stats.totalRequests}',
                          icon: Icons.inbox_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Offerten',
                          value: '${stats.sentQuotes}',
                          icon: Icons.send_rounded,
                          color: AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Aufträge',
                          value: '${orders.length}',
                          icon: Icons.work_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Abgelehnt',
                          value: '${stats.rejectedQuotes}',
                          icon: Icons.cancel_rounded,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // CONVERSION FUNNEL
                  const _SectionTitle(title: 'Conversion Funnel', icon: Icons.filter_alt),
                  const SizedBox(height: 12),
                  _buildConversionFunnel(stats),

                  const SizedBox(height: 24),

                  // SMART INSIGHTS
                  const _SectionTitle(title: 'Smarte Insights', icon: Icons.lightbulb),
                  const SizedBox(height: 12),
                  _buildSmartInsights(stats, requests, quotes, orders),

                  const SizedBox(height: 24),

                  // PIPELINE STATUS
                  const _SectionTitle(title: 'Pipeline Status', icon: Icons.timeline),
                  const SizedBox(height: 12),
                  _buildPipelineStatus(stats),

                  const SizedBox(height: 24),

                  // PERFORMANCE METRIKEN
                  const _SectionTitle(title: 'Performance', icon: Icons.speed),
                  const SizedBox(height: 12),
                  _buildPerformanceMetrics(stats, quotes),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // UMSATZ HEADER
  Widget _buildRevenueHeader(stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Gesamtumsatz',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.price(stats.totalRevenue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RevenueSubStat(
                label: 'Ø Offerte',
                value: Formatters.price(stats.averageQuoteValue),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              _RevenueSubStat(
                label: 'Conversion',
                value: '${stats.conversionRate.toStringAsFixed(1)}%',
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              _RevenueSubStat(
                label: 'Aufträge',
                value: '${stats.acceptedQuotes}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CONVERSION FUNNEL
  Widget _buildConversionFunnel(stats) {
    final totalRequests = stats.totalRequests > 0 ? stats.totalRequests : 1;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FunnelStep(
              label: 'Anfragen erhalten',
              count: stats.totalRequests,
              percentage: 100,
              color: AppTheme.primary,
              icon: Icons.inbox,
            ),
            _FunnelConnector(),
            _FunnelStep(
              label: 'Offerten gesendet',
              count: stats.sentQuotes,
              percentage: (stats.sentQuotes / totalRequests * 100),
              color: AppTheme.info,
              icon: Icons.send,
            ),
            _FunnelConnector(),
            _FunnelStep(
              label: 'Aufträge gewonnen',
              count: stats.acceptedQuotes,
              percentage: (stats.acceptedQuotes / totalRequests * 100),
              color: AppTheme.success,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  // SMART INSIGHTS
  Widget _buildSmartInsights(stats, requests, quotes, orders) {
    final insights = <Widget>[];
    
    // Insight 1: Hot Leads
    if (stats.hotLeads > 0) {
      insights.add(_InsightCard(
        icon: Icons.local_fire_department,
        color: Colors.orange,
        title: '${stats.hotLeads} Hot Leads!',
        description: 'Diese Kunden haben die Offerte mehrfach angeschaut - jetzt nachfassen!',
        actionLabel: 'Kontaktieren',
      ));
    }
    
    // Insight 2: Überlegende Kunden
    if (stats.thinkingQuotes > 0) {
      insights.add(_InsightCard(
        icon: Icons.psychology,
        color: AppTheme.statusThinking,
        title: '${stats.thinkingQuotes} überlegen noch',
        description: 'Ein Anruf könnte den Abschluss bringen!',
        actionLabel: 'Nachfassen',
      ));
    }
    
    // Insight 3: Conversion Rate
    if (stats.conversionRate >= 50) {
      insights.add(_InsightCard(
        icon: Icons.emoji_events,
        color: Colors.amber,
        title: 'Top Conversion Rate!',
        description: '${stats.conversionRate.toStringAsFixed(1)}% - überdurchschnittlich gut!',
        actionLabel: null,
      ));
    } else if (stats.conversionRate < 30 && stats.sentQuotes > 0) {
      insights.add(_InsightCard(
        icon: Icons.trending_down,
        color: AppTheme.error,
        title: 'Conversion verbessern',
        description: 'Nur ${stats.conversionRate.toStringAsFixed(1)}% - Preise oder Angebote prüfen?',
        actionLabel: 'Analysieren',
      ));
    }
    
    // Insight 4: Neue Anfragen
    if (stats.pendingRequests > 0) {
      insights.add(_InsightCard(
        icon: Icons.notification_important,
        color: AppTheme.success,
        title: '${stats.pendingRequests} neue Anfragen',
        description: 'Schnelle Reaktion erhöht die Abschlussrate um 50%!',
        actionLabel: 'Bearbeiten',
      ));
    }
    
    // Insight 5: Durchschnittswert
    if (stats.averageQuoteValue > 0) {
      insights.add(_InsightCard(
        icon: Icons.insights,
        color: AppTheme.info,
        title: 'Ø ${Formatters.price(stats.averageQuoteValue)} pro Offerte',
        description: 'Bei ${stats.sentQuotes} Offerten potentielles Volumen: ${Formatters.price(stats.sentQuotes * stats.averageQuoteValue)}',
        actionLabel: null,
      ));
    }

    if (insights.isEmpty) {
      insights.add(_InsightCard(
        icon: Icons.rocket_launch,
        color: AppTheme.primary,
        title: 'Bereit für den Start!',
        description: 'Sobald du Anfragen bearbeitest, erscheinen hier smarte Insights.',
        actionLabel: null,
      ));
    }

    return Column(children: insights);
  }

  // PIPELINE STATUS
  Widget _buildPipelineStatus(stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PipelineRow(
              label: 'Neue Anfragen',
              count: stats.pendingRequests,
              color: AppTheme.statusNew,
              icon: Icons.fiber_new_rounded,
            ),
            const Divider(height: 24),
            _PipelineRow(
              label: 'Offerte gesendet',
              count: stats.sentQuotes - stats.acceptedQuotes - stats.rejectedQuotes - stats.thinkingQuotes,
              color: AppTheme.statusSent,
              icon: Icons.send_rounded,
            ),
            const Divider(height: 24),
            _PipelineRow(
              label: 'Kunde überlegt',
              count: stats.thinkingQuotes,
              color: AppTheme.statusThinking,
              icon: Icons.psychology_rounded,
            ),
            const Divider(height: 24),
            _PipelineRow(
              label: 'Hot Leads',
              count: stats.hotLeads,
              color: AppTheme.warning,
              icon: Icons.local_fire_department,
            ),
          ],
        ),
      ),
    );
  }

  // PERFORMANCE METRIKEN
  Widget _buildPerformanceMetrics(stats, quotes) {
    // Berechne zusätzliche Metriken
    final avgResponseTime = '< 2h'; // Placeholder
    final successRate = stats.sentQuotes > 0 
        ? (stats.acceptedQuotes / stats.sentQuotes * 100).toStringAsFixed(1) 
        : '0';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Erfolgsquote',
                    value: '$successRate%',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.success,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Reaktionszeit',
                    value: avgResponseTime,
                    icon: Icons.speed,
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Offene Pipeline',
                    value: '${stats.pendingRequests + stats.thinkingQuotes}',
                    icon: Icons.hourglass_empty,
                    color: AppTheme.warning,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Abschlüsse',
                    value: '${stats.acceptedQuotes}',
                    icon: Icons.handshake,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// HELPER WIDGETS

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryDark, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _RevenueSubStat extends StatelessWidget {
  final String label;
  final String value;

  const _RevenueSubStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _FunnelStep extends StatelessWidget {
  final String label;
  final int count;
  final double percentage;
  final Color color;
  final IconData icon;

  const _FunnelStep({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text('${percentage.toStringAsFixed(0)}% der Anfragen', style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _FunnelConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Icon(Icons.arrow_downward, color: AppTheme.textHint, size: 20),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String? actionLabel;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: () {},
                child: Text(actionLabel!, style: TextStyle(color: color)),
              ),
          ],
        ),
      ),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _PipelineRow({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
