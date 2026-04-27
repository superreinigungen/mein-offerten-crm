import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/order.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        final pendingOrders = provider.pendingOrders;
        final completedOrders = provider.completedOrders;
        final todaysOrders = provider.todaysOrders;
        final cancelledOrders = provider.orders.where((o) => o.status == OrderStatus.cancelled).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Aufträge'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                _buildTab('Anstehend', pendingOrders.length, Icons.schedule_rounded, AppTheme.warning),
                _buildTab('Heute', todaysOrders.length, Icons.today_rounded, Colors.orange),
                _buildTab('Erledigt', completedOrders.length, Icons.check_circle_rounded, AppTheme.success),
                _buildTab('Storniert', cancelledOrders.length, Icons.cancel_rounded, AppTheme.error),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Anstehende Aufträge
              _OrderList(
                orders: pendingOrders,
                emptyIcon: Icons.work_outline,
                emptyMessage: 'Keine anstehenden Aufträge',
                emptySubtitle: 'Neue Aufträge erscheinen hier',
              ),
              
              // Tab 2: Heutige Aufträge
              _OrderList(
                orders: todaysOrders,
                emptyIcon: Icons.today_outlined,
                emptyMessage: 'Keine Aufträge für heute',
                emptySubtitle: 'Heute geplante Aufträge erscheinen hier',
              ),
              
              // Tab 3: Erledigte Aufträge
              _OrderList(
                orders: completedOrders,
                emptyIcon: Icons.check_circle_outline,
                emptyMessage: 'Noch keine erledigten Aufträge',
                emptySubtitle: 'Abgeschlossene Aufträge erscheinen hier',
              ),
              
              // Tab 4: Stornierte Aufträge
              _OrderList(
                orders: cancelledOrders,
                emptyIcon: Icons.cancel_outlined,
                emptyMessage: 'Keine stornierten Aufträge',
                emptySubtitle: 'Stornierte Aufträge erscheinen hier',
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

/// Gefilterte Auftrags-Liste
class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final IconData emptyIcon;
  final String emptyMessage;
  final String emptySubtitle;

  const _OrderList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    
    // Nach Datum sortieren (nächste zuerst)
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => a.cleaningDate.compareTo(b.cleaningDate));

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // RefreshIndicator IMMER anzeigen (auch bei leerer Liste)
    return RefreshIndicator(
      onRefresh: () async {
        await provider.initialize();
      },
      child: sortedOrders.isEmpty
          ? ListView(
              // Wichtig: physics damit Pull-to-Refresh funktioniert
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
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
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                final order = sortedOrders[index];
                return _OrderCard(order: order);
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  
  const _OrderCard({required this.order});
  
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final isToday = _isToday(order.cleaningDate);
    final daysUntil = order.cleaningDate.difference(DateTime.now()).inDays;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (order.status) {
      case OrderStatus.inProgress:
        statusColor = Colors.purple;
        statusText = 'In Arbeit';
        statusIcon = Icons.cleaning_services;
        break;
      case OrderStatus.confirmed:
        statusColor = AppTheme.info;
        statusText = 'Bestätigt';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.completed:
        statusColor = AppTheme.success;
        statusText = 'Erledigt';
        statusIcon = Icons.done_all;
        break;
      case OrderStatus.cancelled:
        statusColor = AppTheme.error;
        statusText = 'Storniert';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.warning;
        statusText = 'Ausstehend';
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: Colors.orange, width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.orange : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isToday ? 'HEUTE!' : daysUntil < 0 ? 'vor ${-daysUntil} Tagen' : 'in $daysUntil Tagen',
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.grey.shade700,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Inhalt
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(order.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Address
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(child: Text(order.address, style: TextStyle(color: Colors.grey.shade700))),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Datum
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(Formatters.date(order.cleaningDate), style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 12),

                // Info Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip('CHF ${order.price.toStringAsFixed(0)}', Colors.green),
                    _infoChip('${order.rooms} Zi.', AppTheme.primaryDark),
                    if (order.assignedTeam != null && order.assignedTeam!.isNotEmpty)
                      _infoChip(order.assignedTeam!, Colors.purple),
                    if (order.estimatedHours != null)
                      _infoChip('~${order.estimatedHours}h', Colors.grey.shade600),
                  ],
                ),

                // Services
                if (order.additionalServices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: order.additionalServices.take(3).map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(service, style: const TextStyle(fontSize: 11, color: AppTheme.accent)),
                      );
                    }).toList(),
                  ),
                ],

                // Divider und Aktionen
                const Divider(height: 24),
                
                // Offerte anzeigen Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openHtmlOfferte(context, order),
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Gesendete Offerte anzeigen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      side: BorderSide(color: AppTheme.primaryDark.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                // Action Buttons nur fuer nicht-erledigte
                if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Anrufen'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _completeOrder(context, order, provider),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Erledigt'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _openHtmlOfferte(BuildContext context, Order order) {
    // Zeige Dialog mit Offerte-Vorschau (konsistent mit request_detail_screen.dart)
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primary],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Offerte Vorschau',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: _getStatusColor(order.status),
                child: Text(
                  _getStatusText(order.status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kunde + Datum
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kunde', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              Text(order.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Reinigungstermin', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              Text(Formatters.date(order.cleaningDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Objekt-Informationen
                      const Text('Objekt-Informationen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                      const SizedBox(height: 12),
                      _dialogInfoRow('Adresse', order.address),
                      _dialogInfoRow('Objekttyp', order.propertyType),
                      _dialogInfoRow('Zimmer', '${order.rooms}'),
                      _dialogInfoRow('Fläche', '${order.squareMeters ?? 'ca. 80'} m²'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Leistungsumfang
                      const Text('Leistungsumfang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                      const SizedBox(height: 8),
                      ...order.services.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      )),
                      if (order.additionalServices.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...order.additionalServices.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle, color: AppTheme.info, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text('$s (Zusatz)', style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        )),
                      ],
                      const SizedBox(height: 20),
                      // Preis Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text('VEREINBARTER PREIS', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text('CHF ${order.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                            const SizedBox(height: 4),
                            const Text('Inkl. MwSt. • Mit Abnahmegarantie', style: TextStyle(fontSize: 11, color: Color(0xFF388E3C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer Button
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Schließen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return AppTheme.success;
      case OrderStatus.inProgress:
        return const Color(0xFF9C27B0);
      case OrderStatus.confirmed:
        return AppTheme.info;
      case OrderStatus.cancelled:
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return '✅ AUFTRAG ERLEDIGT';
      case OrderStatus.inProgress:
        return '🧹 IN ARBEIT';
      case OrderStatus.confirmed:
        return '✅ BESTÄTIGT';
      case OrderStatus.cancelled:
        return '❌ STORNIERT';
      default:
        return '⏳ AUSSTEHEND';
    }
  }

  void _completeOrder(BuildContext context, Order order, AppProvider provider) {
    provider.completeOrder(order.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auftrag erledigt!'), backgroundColor: Colors.green),
    );
  }

}
