import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/api_service.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_activity.dart';
import '../models/dashboard_module.dart';

class DashboardRepository {
  Future<DashboardSummary> getSummary() async {
    final http.Response response = await ApiService.get('/api/dashboard/summary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DashboardSummary.fromJson(data);
    } else {
      throw Exception('Failed to load dashboard summary: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<DashboardActivity>> getActivities() async {
    final http.Response response = await ApiService.get('/api/dashboard/activity');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DashboardActivity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dashboard activities: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<DashboardModule>> getModules() async {
    final http.Response response = await ApiService.get('/api/dashboard/modules');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DashboardModule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dashboard modules: ${response.statusCode} - ${response.body}');
    }
  }
}
