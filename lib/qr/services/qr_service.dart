/// QR Service
/// Generate and parse QR codes for user add and session join
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final qrServiceProvider = Provider<QRService>((ref) {
  return QRService();
});

enum QRCodeType {
  user, // User profile QR (ID + public key)
  anonymousSession, // Anonymous session QR
}

class QRService {
  // ===========================================================================
  // USER QR CODES
  // ===========================================================================

  /// Generate user QR data
  /// Format: {"type":"user","id":"uuid","username":"name","publicKey":"base64"}
  String generateUserQRData({
    required String userId,
    required String username,
    String? publicKey,
  }) {
    final data = {
      'type': 'user',
      'id': userId,
      'username': username,
      if (publicKey != null) 'publicKey': publicKey,
    };

    return jsonEncode(data);
  }

  /// Parse user QR data
  UserQRData? parseUserQRData(String qrData) {
    try {
      final json = jsonDecode(qrData) as Map<String, dynamic>;

      if (json['type'] != 'user') {
        return null;
      }

      return UserQRData(
        userId: json['id'] as String,
        username: json['username'] as String,
        publicKey: json['publicKey'] as String?,
      );
    } catch (e) {
      // Failed to parse user QR data
      return null;
    }
  }

  // ===========================================================================
  // ANONYMOUS SESSION QR CODES
  // ===========================================================================

  /// Generate anonymous session QR data
  /// Format: {"type":"session","id":"uuid","key":"base64","expiry":"iso8601"}
  String generateSessionQRData({
    required String sessionId,
    required String sessionKey,
    DateTime? expiry,
  }) {
    final data = {
      'type': 'session',
      'id': sessionId,
      'key': sessionKey,
      if (expiry != null) 'expiry': expiry.toIso8601String(),
    };

    return jsonEncode(data);
  }

  /// Parse anonymous session QR data
  SessionQRData? parseSessionQRData(String qrData) {
    try {
      final json = jsonDecode(qrData) as Map<String, dynamic>;

      if (json['type'] != 'session') {
        return null;
      }

      return SessionQRData(
        sessionId: json['id'] as String,
        sessionKey: json['key'] as String,
        expiry: json['expiry'] != null
            ? DateTime.parse(json['expiry'] as String)
            : null,
      );
    } catch (e) {
      // Failed to parse session QR data
      return null;
    }
  }

  // ===========================================================================
  // GENERIC QR PARSING
  // ===========================================================================

  /// Parse any QR code and determine type
  QRParseResult? parseQRCode(String qrData) {
    try {
      final json = jsonDecode(qrData) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'user':
          final userData = parseUserQRData(qrData);
          return userData != null ? QRParseResult.user(userData) : null;

        case 'session':
          final sessionData = parseSessionQRData(qrData);
          return sessionData != null
              ? QRParseResult.session(sessionData)
              : null;

        default:
          return null;
      }
    } catch (e) {
      // Failed to parse QR code
      return null;
    }
  }
}

// ===========================================================================
// DATA MODELS
// ===========================================================================

class UserQRData {
  final String userId;
  final String username;
  final String? publicKey;

  const UserQRData({
    required this.userId,
    required this.username,
    this.publicKey,
  });
}

class SessionQRData {
  final String sessionId;
  final String sessionKey;
  final DateTime? expiry;

  const SessionQRData({
    required this.sessionId,
    required this.sessionKey,
    this.expiry,
  });
}

class QRParseResult {
  final QRCodeType type;
  final UserQRData? userData;
  final SessionQRData? sessionData;

  const QRParseResult._({required this.type, this.userData, this.sessionData});

  factory QRParseResult.user(UserQRData data) {
    return QRParseResult._(type: QRCodeType.user, userData: data);
  }

  factory QRParseResult.session(SessionQRData data) {
    return QRParseResult._(
      type: QRCodeType.anonymousSession,
      sessionData: data,
    );
  }
}
