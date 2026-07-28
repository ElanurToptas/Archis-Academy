class VoiceModel {
  VoiceModel({
    required this.id,
    required this.userId,
    required this.downloadUrl,
    required this.durationSeconds,
    required this.timestamp,
  });

  final String id;              
  final String userId;         
  final String downloadUrl;     
  final int durationSeconds;    
  final DateTime timestamp;    

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'downloadUrl': downloadUrl,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory VoiceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VoiceModel(
      id: documentId,
      userId: map['userId'] ?? '',
      downloadUrl: map['downloadUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}