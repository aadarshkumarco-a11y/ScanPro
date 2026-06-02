import 'package:scanpro/features/qr_scanner/domain/entities/qr_result.dart';

/// Data model for [QrResult], extending the domain entity with
/// JSON and Hive serialization support.
class QrResultModel extends QrResult {
  const QrResultModel({
    required super.id,
    required super.data,
    required super.type,
    required super.createdAt,
  });

  /// Creates a [QrResultModel] from a domain [QrResult] entity.
  factory QrResultModel.fromEntity(QrResult entity) {
    return QrResultModel(
      id: entity.id,
      data: entity.data,
      type: entity.type,
      createdAt: entity.createdAt,
    );
  }

  /// Creates a [QrResultModel] from a JSON map.
  factory QrResultModel.fromJson(Map<String, dynamic> json) {
    return QrResultModel(
      id: json['id'] as String,
      data: json['data'] as String,
      type: _typeFromString(json['type'] as String),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  /// Creates a [QrResultModel] from a Hive box entry.
  factory QrResultModel.fromHive(Map<dynamic, dynamic> map) {
    return QrResultModel(
      id: map['id'] as String,
      data: map['data'] as String,
      type: _typeFromString(map['type'] as String),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'type': _typeToString(type),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'data': data,
      'type': _typeToString(type),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts this model back to a domain [QrResult] entity.
  QrResult toEntity() {
    return QrResult(
      id: id,
      data: data,
      type: type,
      createdAt: createdAt,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  static QrDataType _typeFromString(String value) {
    switch (value) {
      case 'url':
        return QrDataType.url;
      case 'text':
        return QrDataType.text;
      case 'wifi':
        return QrDataType.wifi;
      case 'contact':
        return QrDataType.contact;
      case 'email':
        return QrDataType.email;
      case 'phone':
        return QrDataType.phone;
      case 'sms':
        return QrDataType.sms;
      default:
        return QrDataType.text;
    }
  }

  static String _typeToString(QrDataType type) {
    switch (type) {
      case QrDataType.url:
        return 'url';
      case QrDataType.text:
        return 'text';
      case QrDataType.wifi:
        return 'wifi';
      case QrDataType.contact:
        return 'contact';
      case QrDataType.email:
        return 'email';
      case QrDataType.phone:
        return 'phone';
      case QrDataType.sms:
        return 'sms';
    }
  }
}
