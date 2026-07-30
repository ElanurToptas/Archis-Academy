import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/voice_model.dart';

class VoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadAndSaveVoice({
    required String filePath,
    required String userId,
    required int durationSeconds,
  }) async {
    try {
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final ref = _storage.ref().child('voice_records/$userId/$fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        throw UnimplementedError(
          "Web için dosya yükleme yöntemi ayrıca yapılandırılmalıdır.",
        );
      } else {
        File file = File(filePath);
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      final docRef = _firestore.collection('voices').doc();

      final voiceModel = VoiceModel(
        id: docRef.id,
        userId: userId,
        downloadUrl: downloadUrl,
        durationSeconds: durationSeconds,
        timestamp: DateTime.now(),
      );

      await docRef.set(voiceModel.toMap());


      final localFile = File(filePath);
      if (await localFile.exists()) {
        await localFile.delete();
      }

      debugPrint("Ses başarıyla yüklendi ve kaydedildi!");
    } catch (e) {
      debugPrint("Ses yükleme hatası: $e");
      rethrow;
    }
  }

  Stream<List<VoiceModel>> getVoices(String userId) {
    return _firestore
        .collection('voices')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((e) {
          debugPrint("Kayıtları çekme hatası (stream): $e");
        })
        .map((snapshot) {
          final result = <VoiceModel>[];
          for (final doc in snapshot.docs) {
            try {
              result.add(VoiceModel.fromMap(doc.data(), doc.id));
            } catch (e) {
              debugPrint("Doküman parse hatası (${doc.id}): $e");
              // bozuk dokümanı atla, diğerlerini etkileme
            }
          }
          return result;
        });
  }
}
