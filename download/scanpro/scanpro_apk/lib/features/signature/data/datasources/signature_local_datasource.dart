import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/signature.dart';
import '../models/signature_model.dart';

/// Local data source for signatures using Hive for persistence.
///
/// Handles CRUD operations on signatures stored in a Hive box.
/// All methods throw [CacheException] on failure so that the
/// repository implementation can convert them to [Failure]s.
class SignatureLocalDatasource {
  SignatureLocalDatasource({
    required Box<dynamic> signaturesBox,
  }) : _box = signaturesBox;

  final Box<dynamic> _box;
  static const _uuid = Uuid();

  // ── Create ────────────────────────────────────────────────────────

  /// Saves a [Signature] to the Hive box.
  ///
  /// If the signature has no ID, a new one is generated.
  /// If the signature is marked as default, any previously default
  /// signature will have its default flag cleared.
  Future<SignatureModel> saveSignature(Signature signature) async {
    try {
      final id = signature.id.isEmpty ? _uuid.v4() : signature.id;
      final now = DateTime.now();

      // If this is the new default, clear the old default.
      if (signature.isDefault) {
        await _clearDefaultFlag();
      }

      final model = SignatureModel(
        id: id,
        name: signature.name,
        imageData: signature.imageData,
        createdAt: signature.createdAt != now ? signature.createdAt : now,
        isDefault: signature.isDefault,
      );

      await _box.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to save signature: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Read ──────────────────────────────────────────────────────────

  /// Retrieves all signatures from the Hive box.
  ///
  /// Returns an empty list if no signatures are found.
  /// Ordered by most recent first.
  List<SignatureModel> getSignatures() {
    try {
      final signatures = <SignatureModel>[];

      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is Map) {
          signatures.add(
            SignatureModel.fromHive(Map<dynamic, dynamic>.from(value)),
          );
        }
      }

      // Sort by most recently created first.
      signatures.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return signatures;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read signatures: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves a single signature by [id].
  ///
  /// Throws [CacheException] if not found.
  SignatureModel getSignatureById(String id) {
    try {
      final value = _box.get(id);
      if (value == null) {
        throw CacheException(
          message: 'Signature with id "$id" not found.',
          code: 1001,
        );
      }
      if (value is Map) {
        return SignatureModel.fromHive(Map<dynamic, dynamic>.from(value));
      }
      throw CacheException(
        message: 'Corrupted data for signature "$id".',
        code: 1004,
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read signature: ${e.toString()}',
        code: 1003,
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────

  /// Deletes a signature by [id].
  Future<void> deleteSignature(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete signature: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Default Management ────────────────────────────────────────────

  /// Sets the signature with [id] as the default.
  ///
  /// Clears the default flag from any other signature.
  Future<SignatureModel> setDefaultSignature(String id) async {
    try {
      // Clear existing default.
      await _clearDefaultFlag();

      // Set new default.
      final model = getSignatureById(id);
      final updated = SignatureModel(
        id: model.id,
        name: model.name,
        imageData: model.imageData,
        createdAt: model.createdAt,
        isDefault: true,
      );

      await _box.put(id, updated.toHive());
      return updated;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to set default signature: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Clears the default flag from all signatures.
  Future<void> _clearDefaultFlag() async {
    try {
      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is Map) {
          final map = Map<dynamic, dynamic>.from(value);
          if (map['isDefault'] == true) {
            map['isDefault'] = false;
            await _box.put(key, map);
          }
        }
      }
    } catch (e) {
      // Silently ignore errors during flag clearing.
    }
  }
}
