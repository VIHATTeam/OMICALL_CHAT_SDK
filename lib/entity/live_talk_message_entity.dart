/// created_date : 1686035919145
/// last_updated_date : 1686035919145
/// _id : ""
/// tenant_id : ""
/// is_deleted : false
/// room_id : ""
/// member_type : "system"
/// type : "activity"
/// action : "create_room"
/// content : ""
/// kind : "normal"
/// receiving_group_id : ""
/// uuid : ""
/// guest_info : {"phone":"","full_name":"Steve","email":"","contact_id":"","new_contact":false,"uuid":"","domain":"https","browser":"","ip":"","address":"Ho Chi Minh City","lat":"","lon":"","other_info":{"full_name":"Steve","mail":"","phone_number":""}}

class LiveTalkMessageEntity {
  LiveTalkMessageEntity({
    this.createdDate,
    this.lastUpdatedDate,
    this.id,
    this.tenantId,
    this.isDeleted,
    this.roomId,
    this.memberType,
    this.type,
    this.action,
    this.content,
    this.kind,
    this.receivingGroupId,
    this.uuid,
    this.guestInfo,
    this.multimedias,
  });

  LiveTalkMessageEntity.fromJson(dynamic json) {
    createdDate = json['created_date'];
    lastUpdatedDate = json['last_updated_date'];
    id = json['_id'];
    tenantId = json['tenant_id'];
    isDeleted = json['is_deleted'];
    roomId = json['room_id'];
    memberType = json['member_type'];
    type = json['type'];
    action = json['action'];
    content = json['content'];
    kind = json['kind'];
    receivingGroupId = json['receiving_group_id'];
    uuid = json['uuid'];
    guestInfo = json['guest_info'] != null
        ? GuestInfo.fromJson(json['guest_info'])
        : null;
    if (json['multimedias'] != null) {
      multimedias = [];
      json['multimedias'].forEach((v) {
        multimedias?.add(Multimedias.fromJson(v));
      });
    }
  }

  int? createdDate;
  int? lastUpdatedDate;
  String? id;
  String? tenantId;
  bool? isDeleted;
  String? roomId;
  String? memberType;
  String? type;
  String? action;
  String? content;
  String? kind;
  String? receivingGroupId;
  String? uuid;
  GuestInfo? guestInfo;
  List<Multimedias>? multimedias;

  LiveTalkMessageEntity copyWith({
    int? createdDate,
    int? lastUpdatedDate,
    String? id,
    String? tenantId,
    bool? isDeleted,
    String? roomId,
    String? memberType,
    String? type,
    String? action,
    String? content,
    String? kind,
    String? receivingGroupId,
    String? uuid,
    GuestInfo? guestInfo,
  }) =>
      LiveTalkMessageEntity(
        createdDate: createdDate ?? this.createdDate,
        lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        isDeleted: isDeleted ?? this.isDeleted,
        roomId: roomId ?? this.roomId,
        memberType: memberType ?? this.memberType,
        type: type ?? this.type,
        action: action ?? this.action,
        content: content ?? this.content,
        kind: kind ?? this.kind,
        receivingGroupId: receivingGroupId ?? this.receivingGroupId,
        uuid: uuid ?? this.uuid,
        guestInfo: guestInfo ?? this.guestInfo,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['created_date'] = createdDate;
    map['last_updated_date'] = lastUpdatedDate;
    map['_id'] = id;
    map['tenant_id'] = tenantId;
    map['is_deleted'] = isDeleted;
    map['room_id'] = roomId;
    map['member_type'] = memberType;
    map['type'] = type;
    map['action'] = action;
    map['content'] = content;
    map['kind'] = kind;
    map['receiving_group_id'] = receivingGroupId;
    map['uuid'] = uuid;
    if (guestInfo != null) {
      map['guest_info'] = guestInfo?.toJson();
    }
    if (multimedias != null) {
      map['multimedias'] = multimedias?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// phone : ""
/// full_name : "Steve"
/// email : ""
/// contact_id : ""
/// new_contact : false
/// uuid : ""
/// domain : "https"
/// browser : ""
/// ip : ""
/// address : "Ho Chi Minh City"
/// lat : ""
/// lon : ""
/// other_info : {"full_name":"Steve","mail":"","phone_number":""}

class GuestInfo {
  GuestInfo({
    this.phone,
    this.fullName,
    this.email,
    this.contactId,
    this.newContact,
    this.uuid,
    this.domain,
    this.browser,
    this.ip,
    this.address,
    this.lat,
    this.lon,
    this.otherInfo,
  });

  GuestInfo.fromJson(dynamic json) {
    phone = json['phone'];
    fullName = json['full_name'];
    email = json['email'];
    contactId = json['contact_id'];
    newContact = json['new_contact'];
    uuid = json['uuid'];
    domain = json['domain'];
    browser = json['browser'];
    ip = json['ip'];
    address = json['address'];
    lat = json['lat'];
    lon = json['lon'];
    otherInfo = json['other_info'] != null
        ? OtherInfo.fromJson(json['other_info'])
        : null;
  }

  String? phone;
  String? fullName;
  String? email;
  String? contactId;
  bool? newContact;
  String? uuid;
  String? domain;
  String? browser;
  String? ip;
  String? address;
  String? lat;
  String? lon;
  OtherInfo? otherInfo;

  GuestInfo copyWith({
    String? phone,
    String? fullName,
    String? email,
    String? contactId,
    bool? newContact,
    String? uuid,
    String? domain,
    String? browser,
    String? ip,
    String? address,
    String? lat,
    String? lon,
    OtherInfo? otherInfo,
  }) =>
      GuestInfo(
        phone: phone ?? this.phone,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        contactId: contactId ?? this.contactId,
        newContact: newContact ?? this.newContact,
        uuid: uuid ?? this.uuid,
        domain: domain ?? this.domain,
        browser: browser ?? this.browser,
        ip: ip ?? this.ip,
        address: address ?? this.address,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        otherInfo: otherInfo ?? this.otherInfo,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phone;
    map['full_name'] = fullName;
    map['email'] = email;
    map['contact_id'] = contactId;
    map['new_contact'] = newContact;
    map['uuid'] = uuid;
    map['domain'] = domain;
    map['browser'] = browser;
    map['ip'] = ip;
    map['address'] = address;
    map['lat'] = lat;
    map['lon'] = lon;
    if (otherInfo != null) {
      map['other_info'] = otherInfo?.toJson();
    }
    return map;
  }
}

/// full_name : "Steve"
/// mail : ""
/// phone_number : ""

class OtherInfo {
  OtherInfo({
    this.fullName,
    this.mail,
    this.phoneNumber,
  });

  OtherInfo.fromJson(dynamic json) {
    fullName = json['full_name'];
    mail = json['mail'];
    phoneNumber = json['phone_number'];
  }

  String? fullName;
  String? mail;
  String? phoneNumber;

  OtherInfo copyWith({
    String? fullName,
    String? mail,
    String? phoneNumber,
  }) =>
      OtherInfo(
        fullName: fullName ?? this.fullName,
        mail: mail ?? this.mail,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['full_name'] = fullName;
    map['mail'] = mail;
    map['phone_number'] = phoneNumber;
    return map;
  }
}

/// name : ""
/// url : ""
/// content_type : "application/octet-stream"
/// size : 188398

class Multimedias {
  Multimedias({
    this.name,
    this.url,
    this.contentType,
    this.size,
  });

  Multimedias.fromJson(dynamic json) {
    name = json['name'];
    url = json['url'];
    contentType = json['content_type'];
    size = json['size'];
  }

  String? name;
  String? url;
  String? contentType;
  int? size;

  Multimedias copyWith({
    String? name,
    String? url,
    String? contentType,
    int? size,
  }) =>
      Multimedias(
        name: name ?? this.name,
        url: url ?? this.url,
        contentType: contentType ?? this.contentType,
        size: size ?? this.size,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['url'] = url;
    map['content_type'] = contentType;
    map['size'] = size;
    return map;
  }
}
