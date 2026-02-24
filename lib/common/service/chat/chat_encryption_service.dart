import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

/// Client-side E2E encryption service.
///
/// Uses AES-256-GCM for message encryption.
/// Per-conversation keys are stored in flutter_secure_storage.
/// The server never sees plaintext content — only ciphertext.
class ChatEncryptionService {
  static final ChatEncryptionService instance = ChatEncryptionService._();
  ChatEncryptionService._();

  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 12; // 96 bits for GCM
  static const int _tagLength = 16; // 128-bit auth tag
  static const int _encryptionVersion = 1;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SecureRandom _secureRandom = _initSecureRandom();

  /// Current encryption version
  int get encryptionVersion => _encryptionVersion;

  // ─── Key Management ───

  /// Generate a new random AES-256 key and store it for the conversation.
  Future<String> generateConversationKey(String conversationId) async {
    final key = _generateRandomBytes(_keyLength);
    final keyBase64 = base64Encode(key);
    await _storage.write(
      key: _storageKey(conversationId),
      value: keyBase64,
    );
    return keyBase64;
  }

  /// Store a conversation key received from key exchange.
  Future<void> storeConversationKey(
      String conversationId, String keyBase64) async {
    await _storage.write(
      key: _storageKey(conversationId),
      value: keyBase64,
    );
  }

  /// Get the stored key for a conversation.
  Future<String?> getConversationKey(String conversationId) async {
    return _storage.read(key: _storageKey(conversationId));
  }

  /// Check if a conversation has an encryption key.
  Future<bool> hasConversationKey(String conversationId) async {
    final key = await _storage.read(key: _storageKey(conversationId));
    return key != null && key.isNotEmpty;
  }

  /// Delete the encryption key for a conversation (when encryption is disabled).
  Future<void> deleteConversationKey(String conversationId) async {
    await _storage.delete(key: _storageKey(conversationId));
  }

  // ─── Encrypt / Decrypt ───

  /// Encrypt plaintext using AES-256-GCM with the conversation key.
  /// Returns base64-encoded ciphertext (IV + ciphertext + tag).
  Future<String?> encrypt(String conversationId, String plaintext) async {
    try {
      final keyBase64 = await getConversationKey(conversationId);
      if (keyBase64 == null) return null;

      final key = base64Decode(keyBase64);
      final iv = _generateRandomBytes(_ivLength);
      final plaintextBytes = utf8.encode(plaintext);

      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          true, // encrypt
          AEADParameters(
            KeyParameter(Uint8List.fromList(key)),
            _tagLength * 8, // tag length in bits
            Uint8List.fromList(iv),
            Uint8List(0), // no additional data
          ),
        );

      final ciphertext =
          cipher.process(Uint8List.fromList(plaintextBytes));

      // Combine: IV (12) + ciphertext+tag
      final result = Uint8List(iv.length + ciphertext.length);
      result.setAll(0, iv);
      result.setAll(iv.length, ciphertext);

      return base64Encode(result);
    } catch (e) {
      return null;
    }
  }

  /// Decrypt base64-encoded ciphertext (IV + ciphertext + tag) using AES-256-GCM.
  Future<String?> decrypt(String conversationId, String ciphertextBase64) async {
    try {
      final keyBase64 = await getConversationKey(conversationId);
      if (keyBase64 == null) return null;

      final key = base64Decode(keyBase64);
      final data = base64Decode(ciphertextBase64);

      if (data.length < _ivLength + _tagLength) return null;

      final iv = data.sublist(0, _ivLength);
      final ciphertextWithTag = data.sublist(_ivLength);

      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false, // decrypt
          AEADParameters(
            KeyParameter(Uint8List.fromList(key)),
            _tagLength * 8,
            Uint8List.fromList(iv),
            Uint8List(0),
          ),
        );

      final plaintext = cipher.process(Uint8List.fromList(ciphertextWithTag));
      return utf8.decode(plaintext);
    } catch (e) {
      return null;
    }
  }

  // ─── Helpers ───

  String _storageKey(String conversationId) => 'e2e_key_$conversationId';

  List<int> _generateRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _secureRandom.nextUint8();
    }
    return bytes;
  }

  static SecureRandom _initSecureRandom() {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }
}
