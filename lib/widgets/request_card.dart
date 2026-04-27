import 'package:flutter/material.dart';
import '../models/cleaning_request.dart';
import '../models/quote.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import 'status_badge.dart';

/// Karte für eine Anfrage in der Liste
class RequestCard extends StatelessWidget {
  final CleaningRequest request;
  final Quote? quote;
  final VoidCallback? onTap;

  const RequestCard({
    super.key,
    required this.request,
    this.quote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNew = request.status == RequestStatus.newRequest;
    final isHotLead = quote?.isHotLead ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: isNew
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppTheme.statusNew,
                      width: 4,
                    ),
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
                      child: Text(
                        _getInitials(request.customerName),
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Name + Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  request.customerName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              if (isHotLead) ...[
                                const SizedBox(width: 8),
                                const HotLeadBadge(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Details Row
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    // Zimmer
                    _InfoChip(
                      icon: Icons.home_outlined,
                      label: Formatters.roomCount(request.roomCount),
                    ),
                    // Fläche
                    _InfoChip(
                      icon: Icons.square_foot_outlined,
                      label: request.areaRange,
                    ),
                    // Verschmutzung
                    _InfoChip(
                      icon: Icons.cleaning_services_outlined,
                      label: request.dirtLevel.getOverallLevel(),
                      color: _getDirtLevelColor(request.dirtLevel.getOverallLevel()),
                    ),
                    // Datum
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: Formatters.date(request.cleaningDate),
                    ),
                  ],
                ),
                
                // Zusatzleistungen
                if (request.additionalServices.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: request.additionalServices.take(3).map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          service.label.split(' ')[0],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.accent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Footer: Status + Zeitstempel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge.forRequestStatus(request.status, isSmall: true),
                    Row(
                      children: [
                        if (quote != null && quote!.viewCount > 0) ...[
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppTheme.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${quote!.viewCount}x angeschaut',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textHint,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.relativeTime(request.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  Color _getDirtLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'leicht':
        return AppTheme.success;
      case 'mittel':
        return AppTheme.warning;
      case 'stark':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }
}

/// Info-Chip für Details
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppTheme.textSecondary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
