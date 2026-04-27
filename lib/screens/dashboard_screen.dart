import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';
import 'template_editor_screen.dart';
import 'design_editor_screen.dart';

/// Haupt-Dashboard mit Übersicht
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final stats = provider.statistics;
        final newRequests = provider.newRequests;
        
        return RefreshIndicator(
          onRefresh: () async {
            await provider.initialize();
          },
          child: CustomScrollView(
            slivers: [
              // Header mit Statistiken
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppTheme.primaryDark, AppTheme.primary],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/sr_logo.png',
                                      height: 45,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Text(
                                          'CLEVO Pro',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CLEVO Pro',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'CRM & Offerten-Management',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Design Button
                                  IconButton(
                                    icon: const Icon(Icons.palette, color: Colors.white),
                                    tooltip: 'Offerten-Design',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const DesignEditorScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  // Settings Button
                                  IconButton(
                                    icon: const Icon(Icons.settings, color: Colors.white),
                                    tooltip: 'Vorlage bearbeiten',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const TemplateEditorScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Schnell-Statistiken
                          Row(
                            children: [
                              Expanded(
                                child: _QuickStatItem(
                                  label: 'Neue Anfragen',
                                  value: '${stats.pendingRequests}',
                                  icon: Icons.inbox_rounded,
                                  isHighlight: stats.pendingRequests > 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickStatItem(
                                  label: 'Hot Leads',
                                  value: '${stats.hotLeads}',
                                  icon: Icons.local_fire_department,
                                  isHighlight: stats.hotLeads > 0,
                                  highlightColor: AppTheme.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickStatItem(
                                  label: 'Angenommen',
                                  value: '${stats.acceptedQuotes}',
                                  icon: Icons.check_circle_outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Neue Anfragen Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Neue Anfragen',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (newRequests.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.statusNew,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${newRequests.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Zur Anfragen-Liste navigieren
                          DefaultTabController.of(context).animateTo(1);
                        },
                        child: const Text('Alle ansehen'),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Anfragen-Liste
              if (newRequests.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Keine neuen Anfragen',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Neue Anfragen erscheinen hier',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final request = newRequests[index];
                      final quote = provider.getQuoteForRequest(request.id);
                      
                      return RequestCard(
                        request: request,
                        quote: quote,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestDetailScreen(
                                request: request,
                                quote: quote,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: newRequests.take(5).length,
                  ),
                ),
              
              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Schnell-Statistik Item im Header
class _QuickStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;
  final Color? highlightColor;

  const _QuickStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isHighlight ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(
                color: highlightColor ?? Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: highlightColor ?? Colors.white,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: highlightColor ?? Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
