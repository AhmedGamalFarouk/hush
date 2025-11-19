// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactRequestImpl _$$ContactRequestImplFromJson(Map<String, dynamic> json) =>
    _$ContactRequestImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      status:
          $enumDecodeNullable(_$ContactRequestStatusEnumMap, json['status']) ??
          ContactRequestStatus.pending,
      message: json['message'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ContactRequestImplToJson(
  _$ContactRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'status': _$ContactRequestStatusEnumMap[instance.status]!,
  'message': instance.message,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$ContactRequestStatusEnumMap = {
  ContactRequestStatus.pending: 'pending',
  ContactRequestStatus.accepted: 'accepted',
  ContactRequestStatus.rejected: 'rejected',
};
