import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../shared/services/api_service.dart';
import '../../../core/storage/storage_service.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_activity.dart';
import '../models/dashboard_module.dart';

class DashboardRepository {
  final StorageService _storage = Get.find<StorageService>();

  Future<DashboardSummary> getSummary({void Function(DashboardSummary)? onCachedData}) async {
    final cacheKey = 'dashboard_summary';
    final cachedData = _storage.getCache(cacheKey);
    if (cachedData != null && onCachedData != null) {
      try {
        onCachedData(DashboardSummary.fromJson(cachedData));
      } catch (_) {}
    }

    final http.Response response = await ApiService.get('/api/dashboard/summary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _storage.saveCache(cacheKey, data);
      return DashboardSummary.fromJson(data);
    } else {
      throw Exception('Failed to load dashboard summary: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<DashboardActivity>> getActivities({void Function(List<DashboardActivity>)? onCachedData}) async {
    final cacheKey = 'dashboard_activities';
    final cachedData = _storage.getCache(cacheKey);
    if (cachedData != null && onCachedData != null) {
      try {
        final List<dynamic> data = cachedData;
        onCachedData(data.map((json) => DashboardActivity.fromJson(json)).toList());
      } catch (_) {}
    }

    final http.Response response = await ApiService.get('/api/dashboard/activity');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _storage.saveCache(cacheKey, data);
      return data.map((json) => DashboardActivity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dashboard activities: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<DashboardModule>> getModules({void Function(List<DashboardModule>)? onCachedData}) async {
    final cacheKey = 'dashboard_modules';
    final cachedData = _storage.getCache(cacheKey);
    if (cachedData != null && onCachedData != null) {
      try {
        final List<dynamic> data = cachedData;
        onCachedData(data.map((json) => DashboardModule.fromJson(json)).toList());
      } catch (_) {}
    }

    final http.Response response = await ApiService.get('/api/dashboard/modules');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _storage.saveCache(cacheKey, data);
      return data.map((json) => DashboardModule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dashboard modules: ${response.statusCode} - ${response.body}');
    }
  }
}
