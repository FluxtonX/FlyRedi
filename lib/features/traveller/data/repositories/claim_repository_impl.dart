import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/logging/app_logger.dart';
import '../../models/claim_model.dart';

class ClaimRepositoryImpl {
  final FirebaseFirestore _db;

  ClaimRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<ClaimModel>> getUserClaims(String uid) async {
    AppLogger.firestore('QUERY', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.claimsCollection}');

    final snap = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.claimsCollection)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true)
        .get();

    AppLogger.firestoreResponse(FirestoreConstants.claimsCollection, info: '${snap.docs.length} claims');

    return snap.docs
        .map((d) => ClaimModel.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<ClaimModel> submitClaim({
    required String uid,
    required String flightCode,
    required String airline,
    required String disruptionType,
    Map<String, dynamic>? booking,
  }) async {
    final data = {
      'userId': uid,
      'flightCode': flightCode,
      'airline': airline,
      'disruptionType': disruptionType,
      'status': 'Submitted',
      'progress': 10,
      if (booking != null) 'booking': booking,
      FirestoreConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    };

    AppLogger.firestore('CREATE', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.claimsCollection}');

    final docRef = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.claimsCollection)
        .add(data);

    AppLogger.firestoreResponse(FirestoreConstants.claimsCollection, info: 'created ${docRef.id}');

    return ClaimModel.fromJson({'id': docRef.id, 'userId': uid, ...data});
  }
}
