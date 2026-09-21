import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Loads and caches India states + cities from a local asset.
class IndiaLocations {
  IndiaLocations._();

  static const _assetPath = 'assets/data/india_states_cities.json';

  static Map<String, List<String>>? _byState;
  static List<String>? _states;

  static bool get isReady => _byState != null;

  static Future<void> ensureLoaded() async {
    if (_byState != null) return;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _byState = {};
        _states = [];
        return;
      }
      final map = <String, List<String>>{};
      for (final entry in decoded.entries) {
        final state = entry.key.toString().trim();
        if (state.isEmpty) continue;
        final cities = <String>{};
        final value = entry.value;
        if (value is List) {
          for (final item in value) {
            final city = item.toString().trim();
            if (city.isNotEmpty) cities.add(city);
          }
        }
        map[state] = cities.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
      final states = map.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      _byState = map;
      _states = states;
    } catch (e, st) {
      debugPrint('IndiaLocations load failed: $e\n$st');
      _byState = {};
      _states = [];
    }
  }

  static List<String> get states => List.unmodifiable(_states ?? const []);

  static List<String> citiesOf(String? state) {
    if (state == null || state.isEmpty) return const [];
    final map = _byState;
    if (map == null) return const [];
    return List.unmodifiable(map[state] ?? const []);
  }

  static bool hasState(String? state) {
    if (state == null || state.isEmpty) return false;
    return _byState?.containsKey(state) ?? false;
  }

  static bool hasCity(String? state, String? city) {
    if (city == null || city.isEmpty) return false;
    return citiesOf(state).contains(city);
  }

  /// Case-insensitive state lookup (e.g. from pincode API).
  static String? matchState(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final needle = name.trim().toLowerCase();
    for (final state in states) {
      if (state.toLowerCase() == needle) return state;
    }
    return null;
  }

  /// Normalize city/district names for pincode API comparison.
  static String normalizePlace(String? name) {
    if (name == null) return '';
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// True when [selected] matches any candidate (exact or contains either way).
  static bool placeMatches(String? selected, Iterable<String?> candidates) {
    final needle = normalizePlace(selected);
    if (needle.isEmpty) return false;
    for (final candidate in candidates) {
      final hay = normalizePlace(candidate);
      if (hay.isEmpty) continue;
      if (hay == needle || hay.contains(needle) || needle.contains(hay)) {
        return true;
      }
    }
    return false;
  }
}
