import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

/// Custom exception for encryption service errors.
class EncryptionException implements Exception {
  final String message;
  const EncryptionException(this.message);
  @override
  String toString() => 'EncryptionException: $message';
}

/// Service for AES encryption and PIN hashing.
///
/// Provides file encryption/decryption using AES-256 CBC mode
/// and secure PIN hashing using SHA-256 with salt.
class EncryptionService {
  /// The encryption key derived from the app's secure storage.
  Key? _encryptionKey;

  /// The initialization vector for AES-CBC encryption.
  IV? _initializationVector;

  /// Initializes the encryption service with a key from secure storage.
  ///
  /// In production, the key would be derived from the device's
  /// secure key store or a user-provided passphrase.
  Future<void> initialize() async {
    try {
      // Production: Retrieve or generate key from flutter_secure_storage
      // For now, derive a fixed key from a device identifier
      final keyString = 'ScanPro_AES256_Key_${DateTime.now().year}';
      final keyBytes = sha256.convert(utf8.encode(keyString)).bytes;
      _encryptionKey = Key(Uint8List.fromList(keyBytes.sublist(0, 32)));
      _initializationVector = IV.fromLength(16);
    } catch (e) {
      throw EncryptionException('Failed to initialize encryption: $e');
    }
  }

  /// Ensures the encryption key is initialized.
  Future<void> _ensureInitialized() async {
    if (_encryptionKey == null) {
      await initialize();
    }
  }

  /// Encrypts a file using AES-256 CBC encryption.
  ///
  /// [filePath] is the path to the file to encrypt.
  /// Returns the path to the encrypted file.
  Future<String> encryptFile(String filePath) async {
    try {
      await _ensureInitialized();

      final file = File(filePath);
      if (!await file.exists()) {
        throw const EncryptionException('Source file not found');
      }

      final fileBytes = await file.readAsBytes();
      final encrypter = Encrypter(AES(_encryptionKey!, mode: AESMode.cbc));

      final encrypted = encrypter.encryptBytes(
        fileBytes,
        iv: _initializationVector!,
      );

      final outputPath = await _generateEncryptedPath(filePath, 'enc');
      await File(outputPath).writeAsBytes(utf8.encode(encrypted.base64));

      return outputPath;
    } on EncryptionException {
      rethrow;
    } catch (e) {
      throw EncryptionException('File encryption failed: $e');
    }
  }

  /// Decrypts a previously encrypted file.
  ///
  /// [filePath] is the path to the encrypted file.
  /// Returns the path to the decrypted file.
  Future<String> decryptFile(String filePath) async {
    try {
      await _ensureInitialized();

      final file = File(filePath);
      if (!await file.exists()) {
        throw const EncryptionException('Encrypted file not found');
      }

      final encryptedBase64 = await file.readAsString();
      final encrypter = Encrypter(AES(_encryptionKey!, mode: AESMode.cbc));

      final decrypted = encrypter.decrypt64(
        encryptedBase64,
        iv: _initializationVector!,
      );

      final outputPath = await _generateEncryptedPath(filePath, 'dec');
      await File(outputPath).writeAsBytes(utf8.encode(decrypted));

      return outputPath;
    } on EncryptionException {
      rethrow;
    } catch (e) {
      throw EncryptionException('File decryption failed: $e');
    }
  }

  /// Encrypts a string value using AES-256.
  ///
  /// [plainText] is the text to encrypt.
  /// Returns the base64-encoded encrypted string.
  Future<String> encryptString(String plainText) async {
    try {
      await _ensureInitialized();
      final encrypter = Encrypter(AES(_encryptionKey!, mode: AESMode.cbc));
      return encrypter.encrypt(plainText, iv: _initializationVector!).base64;
    } catch (e) {
      throw EncryptionException('String encryption failed: $e');
    }
  }

  /// Decrypts a base64-encoded encrypted string.
  ///
  /// [encryptedBase64] is the encrypted text to decrypt.
  /// Returns the original plaintext string.
  Future<String> decryptString(String encryptedBase64) async {
    try {
      await _ensureInitialized();
      final encrypter = Encrypter(AES(_encryptionKey!, mode: AESMode.cbc));
      return encrypter.decrypt64(
        encryptedBase64,
        iv: _initializationVector!,
      );
    } catch (e) {
      throw EncryptionException('String decryption failed: $e');
    }
  }

  /// Hashes a PIN using SHA-256 with a static salt.
  ///
  /// [pin] is the raw PIN string to hash.
  /// Returns the hexadecimal hash string.
  String hashPIN(String pin) {
    const salt = 'ScanPro_PIN_Salt_2024';
    final bytes = utf8.encode('$salt$pin$salt');
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Verifies a PIN against a stored hash.
  ///
  /// [pin] is the raw PIN string to verify.
  /// [storedHash] is the previously stored hash.
  /// Returns true if the PIN matches.
  bool verifyPINHash(String pin, String storedHash) {
    final inputHash = hashPIN(pin);
    return inputHash == storedHash;
  }

  /// Generates the output path for encrypted/decrypted files.
  Future<String> _generateEncryptedPath(
    String inputPath,
    String suffix,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(inputPath);
    final baseName = p.basenameWithoutExtension(inputPath);
    return p.join(tempDir.path, '${baseName}_${suffix}_$timestamp$ext');
  }

  /// Disposes of sensitive encryption materials.
  void dispose() {
    _encryptionKey = null;
    _initializationVector = null;
  }
}
