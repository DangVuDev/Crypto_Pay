import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  final _key = Key.fromSecureRandom(32); // 256-bit key
  final _iv = IV.fromSecureRandom(16); // 128-bit IV

  Future<String> encrypt(String data) async {
    try {
      final encrypter = Encrypter(AES(_key));
      final encrypted = encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  Future<String> decrypt(String encryptedData) async {
    try {
      final encrypter = Encrypter(AES(_key));
      final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: _iv);
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  String generateKeyHash(String key) {
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}