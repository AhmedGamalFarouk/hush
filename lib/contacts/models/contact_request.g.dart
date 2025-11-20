// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactRequestImpl _$$ContactRequestImplFromJson(Map<String, dynamic> json) =>
    _$ContactRequestImpl(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status:
          $enumDecodeNullable(_$ContactRequestStatusEnumMap, json['status']) ??
          ContactRequestStatus.pending,
      message: json['message'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ContactRequestImplToJson(
  _$ContactRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sender_id': instance.senderId,
  'receiver_id': instance.receiverId,
  'status': _$ContactRequestStatusEnumMap[instance.status]!,
  'message': instance.message,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$ContactRequestStatusEnumMap = {
  ContactRequestStatus.pending: 'pending',
  ContactRequestStatus.accepted: 'accepted',
  ContactRequestStatus.rejected: 'rejected',
};
