import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class MetricsRealtimeSubscription {
  final VoidCallback onRefresh;
  final Duration debounce;
  final Duration pollInterval;
  final RealtimeChannel _channel;
  Timer? _debounceTimer;
  Timer? _pollTimer;
  bool _closed = false;

  MetricsRealtimeSubscription._({
    required this.onRefresh,
    required this.debounce,
    required this.pollInterval,
    required RealtimeChannel channel,
  }) : _channel = channel;

  factory MetricsRealtimeSubscription.forCard({
    required String cardId,
    required VoidCallback onRefresh,
    Duration debounce = const Duration(milliseconds: 450),
    Duration pollInterval = const Duration(seconds: 5),
  }) {
    final subscription = MetricsRealtimeSubscription._(
      onRefresh: onRefresh,
      debounce: debounce,
      pollInterval: pollInterval,
      channel: SupabaseService.client.channel(
        'metrics:card:$cardId:${DateTime.now().microsecondsSinceEpoch}',
      ),
    );

    subscription
      .._watchTable(
        table: 'visit_events',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'card_id',
          value: cardId,
        ),
      )
      .._watchTable(
        table: 'contact_items',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'card_id',
          value: cardId,
        ),
      )
      .._watchTable(
        table: 'social_links',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'card_id',
          value: cardId,
        ),
      )
      .._watchTable(
        table: 'leads',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'card_id',
          value: cardId,
        ),
      )
      .._watchTable(table: 'lead_actions')
      .._subscribe();

    return subscription;
  }

  factory MetricsRealtimeSubscription.forOrganization({
    required String orgId,
    required VoidCallback onRefresh,
    Duration debounce = const Duration(milliseconds: 500),
    Duration pollInterval = const Duration(seconds: 8),
  }) {
    final subscription = MetricsRealtimeSubscription._(
      onRefresh: onRefresh,
      debounce: debounce,
      pollInterval: pollInterval,
      channel: SupabaseService.client.channel(
        'metrics:org:$orgId:${DateTime.now().microsecondsSinceEpoch}',
      ),
    );

    subscription
      .._watchTable(table: 'visit_events')
      .._watchTable(table: 'contact_items')
      .._watchTable(table: 'social_links')
      .._watchTable(table: 'leads')
      .._watchTable(table: 'lead_actions')
      .._watchTable(
        table: 'users',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'org_id',
          value: orgId,
        ),
      )
      .._watchTable(
        table: 'digital_cards',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'org_id',
          value: orgId,
        ),
      )
      .._subscribe();

    return subscription;
  }

  void _watchTable({required String table, PostgresChangeFilter? filter}) {
    _channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      filter: filter,
      callback: (_) => _scheduleRefresh(),
    );
  }

  void _subscribe() {
    _channel.subscribe();
    _scheduleRefresh();
    _pollTimer = Timer.periodic(pollInterval, (_) => _scheduleRefresh());
  }

  void _scheduleRefresh() {
    if (_closed) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      if (_closed) return;
      onRefresh();
    });
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _debounceTimer?.cancel();
    _pollTimer?.cancel();
    unawaited(SupabaseService.client.removeChannel(_channel));
  }
}
