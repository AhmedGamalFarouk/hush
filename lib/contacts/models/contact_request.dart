/// Contact Request Model
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_request.freezed.dart';
part 'contact_request.g.dart';

enum ContactRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
}

@freezed
class ContactRequest with _$ContactRequest {
  const factory ContactRequest({
    required String id,
    required String senderId,
    required String receiverId,
    @Default(ContactRequestStatus.pending) ContactRequestStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ContactRequest;

  factory ContactRequest.fromJson(Map<String, dynamic> json) =>
      _$ContactRequestFromJson(json);
}
