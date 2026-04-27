import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/cleaning_request.dart';
import '../models/quote.dart';
import '../utils/theme.dart';
import '../widgets/request_card.dart';
import 'request_detail_screen.dart';

/// Liste aller Anfragen - mit verbesserter Status-Logik
class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Zaehler fuer jeden Tab
        final newCount = provider.trulyNewRequests.length;
        final pendingCount = provider.pendingQuoteRequests.length + provider.viewedRequests.length;
        final thinkingCount = provider.thinkingRequests.length;
        final acceptedCount = provider.acceptedRequests.length;
        final rejectedCount = provider.rejectedRequests.length;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Anfragen'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                _buildTab('Neu', newCount, Icons.fiber_new_rounded, AppTheme.success),
                _buildTab('Gesendet', pendingCount, Icons.send_rounded, AppTheme.info),
                _buildTab('Überlegt', thinkingCount, Icons.hourglass_empty, AppTheme.warning),
                _buildTab('Angenommen', acceptedCount, Icons.check_circle_rounded, AppTheme.success),
                _buildTab('Abgelehnt', rejectedCount, Icons.cancel_rounded, AppTheme.error),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Neue Anfragen
              _RequestList(
                requests: provider.trulyNewRequests,
                emptyIcon: Icons.inbox_outlined,
                emptyMessage: 'Keine neuen Anfragen',
                emptySubtitle: 'Neue Anfragen erscheinen hier',
              ),
              
              // Tab 2: Offerte gesendet (warten auf Antwort)
              _RequestList(
                requests: [...provider.pendingQuoteRequests, ...provider.viewedRequests],
                emptyIcon: Icons.send_outlined,
                emptyMessage: 'Keine ausstehenden Offerten',
                emptySubtitle: 'Gesendete Offerten warten hier auf Kundenreaktion',
              ),
              
              // Tab 3: Kunde überlegt
              _RequestList(
                requests: provider.thinkingRequests,
                emptyIcon: Icons.hourglass_empty,
                emptyMessage: 'Keine überlegenden Kunden',
                emptySubtitle: 'Kunden die "Ich überlege noch" gewählt haben',
              ),
              
              // Tab 4: Angenommen
              _RequestList(
                requests: provider.acceptedRequests,
                emptyIcon: Icons.check_circle_outline,
                emptyMessage: 'Noch keine angenommenen Offerten',
                emptySubtitle: 'Angenommene Offerten werden zu Aufträgen',
              ),
              
              // Tab 5: Abgelehnt
              _RequestList(
                requests: provider.rejectedRequests,
                emptyIcon: Icons.cancel_outlined,
                emptyMessage: 'Keine abgelehnten Offerten',
                emptySubtitle: 'Abgelehnte Offerten erscheinen hier',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String label, int count, IconData icon, Color accentColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Gefilterte Anfragen-Liste
class _RequestList extends StatelessWidget {
  final List<CleaningRequest> requests;
  final IconData emptyIcon;
  final String emptyMessage;
  final String emptySubtitle;

  const _RequestList({
    required this.requests,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    
    // Nach Datum sortieren (neueste zuerst)
    final sortedRequests = List<CleaningRequest>.from(requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sortedRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 72, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: const TextStyle(fontSize: 14, color: AppTheme.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.initialize();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sortedRequests.length,
        itemBuilder: (context, index) {
          final request = sortedRequests[index];
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
      ),
    );
  }
}
