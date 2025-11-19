/// Group Models
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

/// Group metadata
@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
    required String createdBy,
    required int keyVersion,
    @Default([]) List<GroupMember> members,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

/// Group member
@freezed
class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String userId,
    required String displayName,
    required DateTime joinedAt,
    @Default(false) bool isAdmin,
    @Default(true) bool isActive,
  }) = _GroupMember;

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);
}

/// Group creation parameters
class CreateGroupParams {
  final String name;
  final String? description;
  final List<String> memberIds;

  const CreateGroupParams({
    required this.name,
    this.description,
    required this.memberIds,
  });
}
