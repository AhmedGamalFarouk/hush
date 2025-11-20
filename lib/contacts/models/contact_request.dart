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
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'receiver_id') required String receiverId,
    @Default(ContactRequestStatus.pending) ContactRequestStatus status,
    String? message,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ContactRequest;

  factory ContactRequest.fromJson(Map<String, dynamic> json) =>
      _$ContactRequestFromJson(json);
}
