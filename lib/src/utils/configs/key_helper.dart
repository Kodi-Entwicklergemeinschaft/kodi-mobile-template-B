import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

class KeyHelper {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
  );

  static Future<void> generateAndStoreRSAKeyPair(String userId) async {
    var keyPair = await RSA.generate(2048);
    await storePublicKey(userId, keyPair.publicKey);
    await storePrivateKey(userId, keyPair.privateKey);
  }

  static Future<bool> checkIfKeyExists(String userId) async {
    final publicKey = await _storage.read(key: 'publicKey_$userId');
    final privateKey = await _storage.read(key: 'privateKey_$userId');
    return publicKey != null && privateKey != null;
  }

  // Store public key
  static Future<void> storePublicKey(String userId, String publicKey) async {
    await _storage.write(key: 'publicKey_$userId', value: publicKey);
  }

  // Store private key
  static Future<void> storePrivateKey(String userId, String privateKey) async {
    await _storage.write(key: 'privateKey_$userId', value: privateKey);
  }

  // Retrieve public key
  static Future<String> getPublicKey(String userId) async {
    final publicKey = await _storage.read(key: 'publicKey_$userId');
    if (publicKey == null) {
      throw Exception("Public key not found in secure storage");
    }
    return publicKey;
  }

  // Retrieve private key as a PEM-encoded string
  static Future<String> getPrivateKey(String userId) async {
    final privateKey = await _storage.read(key: 'privateKey_$userId');
    if (privateKey == null) {
      throw Exception("Private key not found in secure storage");
    }
    return privateKey;
  }

  // Retrieve forum key from secure storage
  static Future<String?> getForumKey({
    required String forumId,
    required int groupKeyVersion,
  }) async {
    final key = 'forumKey_${forumId}_$groupKeyVersion';
    return await _storage.read(key: key);
  }

  // Store decrypted forum AES key in secure storage
  static Future<void> storeDecryptedForumAesKey(
      String forumId, String aesKey) async {
    await _storage.write(key: 'decryptedForumAesKey_$forumId', value: aesKey);
  }

  // Retrieve decrypted forum AES key from secure storage
  static Future<String?> getDecryptedForumAesKey(String forumId) async {
    return await _storage.read(key: 'decryptedForumAesKey_$forumId');
  }

  // Store forum key in secure storage
  static Future<void> storeForumKey({
    required String forumId,
    required String groupKeyVersion,
    required String encryptedForumAesKey,
  }) async {
    final key = 'forumKey_${forumId}_$groupKeyVersion';
    await _storage.write(key: key, value: encryptedForumAesKey);
  }

  static Future<int?> getStoredForumKeyVersion(String forumId) async {
    final keys = await _storage.readAll();
    int? lastVersion;

    for (String key in keys.keys) {
      if (key.startsWith('forumKey_${forumId}_')) {
        final currentVersionString = key.split('_').last;
        final currentVersion = int.tryParse(currentVersionString);

        if (currentVersion != null) {
          if (lastVersion == null || currentVersion > lastVersion) {
            lastVersion = currentVersion;
          }
        }
      }
    }

    return lastVersion;
  }

  // Retrieve stored encrypted forum AES key from secure storage
  static Future<String?> getStoredEncryptedForumAesKey(
      String forumId, String groupKeyVersion) async {
    final key = 'forumKey_${forumId}_$groupKeyVersion';
    return await _storage.read(key: key);
  }

  // Decrypt AES key using user's private key
  static String decryptAESKey(
      String encryptedForumAesKey, RSAPrivateKey userPrivateKey) {
    const decoder = Base64Decoder();
    final encryptedBytes = decoder.convert(encryptedForumAesKey);

    final cipher = RSAEngine()
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(userPrivateKey));

    final decryptedBytes = cipher.process(encryptedBytes);
    return base64Encode(decryptedBytes);
  }

  // Decrypt message using the forum AES key
  static String decryptMessage(String encryptedMessage, String forumAesKey) {
    final parts = encryptedMessage.split(':');

    final aesKey = base64.decode(forumAesKey);

    final ivBytes = base64.decode(parts[0]);
    final encryptedData = parts[1];
    final encryptedBytes = base64.decode(encryptedData);
    final iv = encrypt.IV(ivBytes);
    final encrypted = encrypt.Encrypted(encryptedBytes);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key(aesKey), mode: encrypt.AESMode.cbc));

    final decryptedBytes = encrypter.decryptBytes(encrypted, iv: iv);
    return utf8.decode(decryptedBytes);
  }
}
