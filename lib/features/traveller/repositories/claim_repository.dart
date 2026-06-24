import 'dart:convert';
import '../../../shared/services/api_service.dart';
import '../models/claim_model.dart';

class ClaimRepository {
  static Future<List<ClaimModel>> getUserClaims() async {
    try {
      final response = await ApiService.get('/api/claims');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final claims = data.map((json) => ClaimModel.fromJson(json)).toList();
        
        return claims;
      } else {
        throw Exception('Failed to load claims');
      }
    } catch (e) {
      print('ClaimRepository error: $e');
      throw Exception('Failed to load claims: $e');
    }
  }

  static Future<ClaimModel> submitClaim({
    required String flightCode,
    required String airline,
    required String disruptionType,
    Map<String, dynamic>? booking,
  }) async {
    try {
      final response = await ApiService.post('/api/claims', body: {
        'flightCode': flightCode,
        'airline': airline,
        'disruptionType': disruptionType,
        if (booking != null) 'booking': booking,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ClaimModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to submit claim');
      }
    } catch (e) {
      print('ClaimRepository submitClaim error: $e');
      throw Exception('Failed to submit claim: $e');
    }
  }
}
