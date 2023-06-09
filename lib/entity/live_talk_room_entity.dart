import 'package:livetalk_sdk/entity/live_talk_message_entity.dart';

/// created_date : 1686196706918
/// last_updated_date : 1686278932131
/// _id : "648151e2f7110a47aeac21d4"
/// create_by : {"id":"","name":"Steve2","contact_id":"","avatar_url":""}
/// tenant_id : "64098e3928a39964ce42a36c"
/// is_deleted : false
/// guest_info : {"phone":"0961046446","full_name":"Steve2","email":"","contact_id":"","new_contact":false,"uuid":"0961046446","domain":"https://omicall.com","browser":"","ip":"","address":"Vietnam","lat":"0.0","lon":"0.0","other_info":{"full_name":"Steve2","phone_number":"0961046446","mail":""}}
/// last_message : {"content":"oh","member_type":"agent","created_date":1686278932118,"created_by":{"id":"64098e3928a39964ce42a36f","name":"devtestcallbot","contact_id":"64098e3c709404243c414545","avatar_url":""}}
/// status : "active"
/// uuid : "0961046446"
/// name : "Steve2"
/// name_unsigned : "Steve2"
/// members : [{"contact_id":"64098e3c709404243c414545","agent_id":"64098e3928a39964ce42a36f","full_name":"devtestcallbot","avatar":"","gender":"male","status":"online","sip_user":"100"}]
/// total_unread : 0
/// unread_ids : []
/// has_member : true
/// version : 21
/// change_receiving_at : 1686196706897
/// change_receiving_timeout : 30
/// waiting_time : 30
/// receiving_group_members : ["64098e3c709404243c414545"]
/// auto_expired : true

class LiveTalkRoomEntity {
  LiveTalkRoomEntity({
    this.createdDate,
    this.lastUpdatedDate,
    this.id,
    this.createBy,
    this.tenantId,
    this.isDeleted,
    this.guestInfo,
    this.lastMessage,
    this.status,
    this.uuid,
    this.name,
    this.nameUnsigned,
    this.members,
    this.totalUnread,
    this.hasMember,
    this.version,
    this.changeReceivingAt,
    this.changeReceivingTimeout,
    this.waitingTime,
    this.receivingGroupMembers,
    this.autoExpired,
  });

  LiveTalkRoomEntity.fromJson(dynamic json) {
    createdDate = json['created_date'];
    lastUpdatedDate = json['last_updated_date'];
    id = json['_id'];
    createBy =
        json['create_by'] != null ? CreateBy.fromJson(json['create_by']) : null;
    tenantId = json['tenant_id'];
    isDeleted = json['is_deleted'];
    guestInfo = json['guest_info'] != null
        ? GuestInfo.fromJson(json['guest_info'])
        : null;
    lastMessage = json['last_message'] != null
        ? LiveTalkMessageEntity.fromJson(json['last_message'])
        : null;
    status = json['status'];
    uuid = json['uuid'];
    name = json['name'];
    nameUnsigned = json['name_unsigned'];
    if (json['members'] != null) {
      members = [];
      json['members'].forEach((v) {
        members?.add(Members.fromJson(v));
      });
    }
    totalUnread = json['total_unread'];
    hasMember = json['has_member'];
    version = json['version'];
    changeReceivingAt = json['change_receiving_at'];
    changeReceivingTimeout = json['change_receiving_timeout'];
    waitingTime = json['waiting_time'];
    receivingGroupMembers = json['receiving_group_members'] != null
        ? json['receiving_group_members'].cast<String>()
        : [];
    autoExpired = json['auto_expired'];
  }

  int? createdDate;
  int? lastUpdatedDate;
  String? id;
  CreateBy? createBy;
  String? tenantId;
  bool? isDeleted;
  GuestInfo? guestInfo;
  LiveTalkMessageEntity? lastMessage;
  String? status;
  String? uuid;
  String? name;
  String? nameUnsigned;
  List<Members>? members;
  int? totalUnread;
  bool? hasMember;
  int? version;
  int? changeReceivingAt;
  int? changeReceivingTimeout;
  int? waitingTime;
  List<String>? receivingGroupMembers;
  bool? autoExpired;

  LiveTalkRoomEntity copyWith({
    int? createdDate,
    int? lastUpdatedDate,
    String? id,
    CreateBy? createBy,
    String? tenantId,
    bool? isDeleted,
    GuestInfo? guestInfo,
    LiveTalkMessageEntity? lastMessage,
    String? status,
    String? uuid,
    String? name,
    String? nameUnsigned,
    List<Members>? members,
    int? totalUnread,
    bool? hasMember,
    int? version,
    int? changeReceivingAt,
    int? changeReceivingTimeout,
    int? waitingTime,
    List<String>? receivingGroupMembers,
    bool? autoExpired,
  }) =>
      LiveTalkRoomEntity(
        createdDate: createdDate ?? this.createdDate,
        lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
        id: id ?? this.id,
        createBy: createBy ?? this.createBy,
        tenantId: tenantId ?? this.tenantId,
        isDeleted: isDeleted ?? this.isDeleted,
        guestInfo: guestInfo ?? this.guestInfo,
        lastMessage: lastMessage ?? this.lastMessage,
        status: status ?? this.status,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        nameUnsigned: nameUnsigned ?? this.nameUnsigned,
        members: members ?? this.members,
        totalUnread: totalUnread ?? this.totalUnread,
        hasMember: hasMember ?? this.hasMember,
        version: version ?? this.version,
        changeReceivingAt: changeReceivingAt ?? this.changeReceivingAt,
        changeReceivingTimeout:
            changeReceivingTimeout ?? this.changeReceivingTimeout,
        waitingTime: waitingTime ?? this.waitingTime,
        receivingGroupMembers:
            receivingGroupMembers ?? this.receivingGroupMembers,
        autoExpired: autoExpired ?? this.autoExpired,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['created_date'] = createdDate;
    map['last_updated_date'] = lastUpdatedDate;
    map['_id'] = id;
    if (createBy != null) {
      map['create_by'] = createBy?.toJson();
    }
    map['tenant_id'] = tenantId;
    map['is_deleted'] = isDeleted;
    if (guestInfo != null) {
      map['guest_info'] = guestInfo?.toJson();
    }
    if (lastMessage != null) {
      map['last_message'] = lastMessage?.toJson();
    }
    map['status'] = status;
    map['uuid'] = uuid;
    map['name'] = name;
    map['name_unsigned'] = nameUnsigned;
    if (members != null) {
      map['members'] = members?.map((v) => v.toJson()).toList();
    }
    map['total_unread'] = totalUnread;
    map['has_member'] = hasMember;
    map['version'] = version;
    map['change_receiving_at'] = changeReceivingAt;
    map['change_receiving_timeout'] = changeReceivingTimeout;
    map['waiting_time'] = waitingTime;
    map['receiving_group_members'] = receivingGroupMembers;
    map['auto_expired'] = autoExpired;
    return map;
  }
}

/// contact_id : "64098e3c709404243c414545"
/// agent_id : "64098e3928a39964ce42a36f"
/// full_name : "devtestcallbot"
/// avatar : ""
/// gender : "male"
/// status : "online"
/// sip_user : "100"

class Members {
  Members({
    this.contactId,
    this.agentId,
    this.fullName,
    this.avatar,
    this.gender,
    this.status,
    this.sipUser,
  });

  Members.fromJson(dynamic json) {
    contactId = json['contact_id'];
    agentId = json['agent_id'];
    fullName = json['full_name'];
    avatar = json['avatar'];
    gender = json['gender'];
    status = json['status'];
    sipUser = json['sip_user'];
  }

  String? contactId;
  String? agentId;
  String? fullName;
  String? avatar;
  String? gender;
  String? status;
  String? sipUser;

  Members copyWith({
    String? contactId,
    String? agentId,
    String? fullName,
    String? avatar,
    String? gender,
    String? status,
    String? sipUser,
  }) =>
      Members(
        contactId: contactId ?? this.contactId,
        agentId: agentId ?? this.agentId,
        fullName: fullName ?? this.fullName,
        avatar: avatar ?? this.avatar,
        gender: gender ?? this.gender,
        status: status ?? this.status,
        sipUser: sipUser ?? this.sipUser,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['contact_id'] = contactId;
    map['agent_id'] = agentId;
    map['full_name'] = fullName;
    map['avatar'] = avatar;
    map['gender'] = gender;
    map['status'] = status;
    map['sip_user'] = sipUser;
    return map;
  }
}

class CreatedBy {
  CreatedBy({
    this.id,
    this.name,
    this.contactId,
    this.avatarUrl,
  });

  CreatedBy.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    contactId = json['contact_id'];
    avatarUrl = json['avatar_url'];
  }

  String? id;
  String? name;
  String? contactId;
  String? avatarUrl;

  CreatedBy copyWith({
    String? id,
    String? name,
    String? contactId,
    String? avatarUrl,
  }) =>
      CreatedBy(
        id: id ?? this.id,
        name: name ?? this.name,
        contactId: contactId ?? this.contactId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['contact_id'] = contactId;
    map['avatar_url'] = avatarUrl;
    return map;
  }
}

class OtherInfo {
  OtherInfo({
    this.fullName,
    this.phoneNumber,
    this.mail,
  });

  OtherInfo.fromJson(dynamic json) {
    fullName = json['full_name'];
    phoneNumber = json['phone_number'];
    mail = json['mail'];
  }

  String? fullName;
  String? phoneNumber;
  String? mail;

  OtherInfo copyWith({
    String? fullName,
    String? phoneNumber,
    String? mail,
  }) =>
      OtherInfo(
        fullName: fullName ?? this.fullName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        mail: mail ?? this.mail,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['full_name'] = fullName;
    map['phone_number'] = phoneNumber;
    map['mail'] = mail;
    return map;
  }
}

/// id : ""
/// name : "Steve2"
/// contact_id : ""
/// avatar_url : ""

class CreateBy {
  CreateBy({
    this.id,
    this.name,
    this.contactId,
    this.avatarUrl,
  });

  CreateBy.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    contactId = json['contact_id'];
    avatarUrl = json['avatar_url'];
  }

  String? id;
  String? name;
  String? contactId;
  String? avatarUrl;

  CreateBy copyWith({
    String? id,
    String? name,
    String? contactId,
    String? avatarUrl,
  }) =>
      CreateBy(
        id: id ?? this.id,
        name: name ?? this.name,
        contactId: contactId ?? this.contactId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['contact_id'] = contactId;
    map['avatar_url'] = avatarUrl;
    return map;
  }
}
