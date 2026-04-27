import 'package:flutter/material.dart';
import '../models/cleaning_request.dart';
import '../models/quote.dart';

/// Status-Badge Widget für Anfragen und Offerten
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.isSmall = false,
  });

  /// Erstellt Badge für Anfrage-Status
  factory StatusBadge.forRequestStatus(RequestStatus status, {bool isSmall = false}) {
    return StatusBadge(
      label: status.label,
      color: Color(status.color),
      isSmall: isSmall,
    );
  }

  /// Erstellt Badge für Offerten-Status
  factory StatusBadge.forQuoteStatus(QuoteStatus status, {bool isSmall = false}) {
    return StatusBadge(
      label: status.label,
      color: Color(status.color),
      isSmall: isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 6 : 8,
            height: isSmall ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hot Lead Badge (für Offerten mit 3+ Ansichten)
class HotLeadBadge extends StatelessWidget {
  const HotLeadBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'Hot Lead',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Verschmutzungsgrad Badge
class DirtLevelBadge extends StatelessWidget {
  final String level;

  const DirtLevelBadge({super.key, required this.level});

  Color get _color {
    switch (level.toLowerCase()) {
      case 'leicht':
        return const Color(0xFF4CAF50);
      case 'mittel':
        return const Color(0xFFFF9800);
      case 'stark':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
