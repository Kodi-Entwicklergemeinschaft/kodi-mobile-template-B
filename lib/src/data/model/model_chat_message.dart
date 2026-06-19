enum MessageStatus { sending, sent, failed }

class ChatMessageModel {
  int? id;
  int? forumId;
  int? forumMemberId;
  String? message;
  String? encryptedMessage;
  String? decryptedMessage;
  String? createdAt;
  int? forumKeyId;
  int? senderId;
  String? avatarUrl;
  bool? isImage;
  String? imageUrl;
  int? userId;
  String? username;
  String? firstname;
  String? lastname;
  String? loggedInUserProfileImage;
  int? listingId;
  String? senderType;
  String? parentMessage;
  int? parentId;
  String? parentUsername;
  List<Reactions>? reactions;
  String? fileUrl;

  // New properties for optimistic UI
  MessageStatus? status;
  String? tempId; // Temporary ID for local messages
  String? errorMessage;

  ChatMessageModel({
    this.id,
    this.userId,
    this.forumId,
    this.forumMemberId,
    this.message,
    this.encryptedMessage,
    this.decryptedMessage, // Initialize text in the constructor
    this.createdAt,
    this.forumKeyId,
    this.senderId,
    this.avatarUrl,
    this.isImage,
    this.imageUrl,
    this.username,
    this.firstname,
    this.lastname,
    this.loggedInUserProfileImage,
    this.listingId,
    this.senderType,
    this.parentMessage,
    this.parentId,
    this.parentUsername,
    this.reactions,
    this.fileUrl,
    this.status,
    this.tempId,
    this.errorMessage,
  });

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    forumId = json['forumId'];
    forumMemberId = json['forumMemberId'];
    message = json['message'];
    encryptedMessage = json['encryptedMessage'];
    decryptedMessage = json['decryptedMessage'];
    if (json['createdAt'] != null) {
      // Parse the UTC string and convert it to local time
      final utcDate = DateTime.parse(json['createdAt'] as String);
      createdAt = utcDate.toLocal().toIso8601String();
    }
    forumKeyId = json['forumKeyId'];
    senderId = json['senderId'];
    avatarUrl = json['avatarUrl'];
    isImage = json['isImage'];
    imageUrl = json['imageUrl'];
    username = json['username'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    loggedInUserProfileImage = json['loggedInUserProfileImage'];
    listingId = json['listingId'];
    senderType = json['senderType'];
    parentMessage = json['parentMessage'];
    parentId = json['parentId'];
    parentUsername = json['parentUsername'];
    if (json['reactions'] != null) {
      reactions = <Reactions>[];
      json['reactions'].forEach((v) {
        reactions!.add(Reactions.fromJson(v));
      });
    }
    fileUrl = json['fileUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['forumId'] = forumId;
    data['forumMemberId'] = forumMemberId;
    data['message'] = message;
    data['encryptedMessage'] = encryptedMessage;
    data['decryptedMessage'] = decryptedMessage;
    data['createdAt'] = createdAt;
    data['forumKeyId'] = forumKeyId;
    data['senderId'] = senderId;
    data['avatarUrl'] = avatarUrl;
    data['isImage'] = isImage;
    data['imageUrl'] = imageUrl;
    data['username'] = username;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['loggedInUserProfileImage'] = loggedInUserProfileImage;
    data['listingId'] = listingId;
    data['senderType'] = senderType;
    data['parentMessage'] = parentMessage;
    data['parentId'] = parentId;
    data['parentUsername'] = parentUsername;
    if (reactions != null) {
      data['reactions'] = reactions!.map((v) => v.toJson()).toList();
    }
    data['fileUrl'] = fileUrl;
    return data;
  }

  // Implement the copyWith method
  ChatMessageModel copyWith({
    int? id,
    int? forumId,
    int? forumMemberId,
    String? message,
    String? encryptedMessage,
    String? decryptedMessage,
    String? createdAt,
    int? forumKeyId,
    int? senderId,
    String? avatarUrl,
    bool? isImage,
    String? imageUrl,
    int? userId,
    String? username,
    String? firstname,
    String? lastname,
    String? loggedInUserProfileImage,
    int? listingId,
    String? senderType,
    String? parentMessage,
    int? parentId,
    String? parentUsername,
    List<Reactions>? reactions,
    String? fileUrl,
    MessageStatus? status,
    String? tempId,
    String? errorMessage,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      forumId: forumId ?? this.forumId,
      forumMemberId: forumMemberId ?? this.forumMemberId,
      message: message ?? this.message,
      encryptedMessage: encryptedMessage ?? this.encryptedMessage,
      decryptedMessage: decryptedMessage ?? this.decryptedMessage,
      createdAt: createdAt ?? this.createdAt,
      forumKeyId: forumKeyId ?? this.forumKeyId,
      senderId: senderId ?? this.senderId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isImage: isImage ?? this.isImage,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      loggedInUserProfileImage:
          loggedInUserProfileImage ?? this.loggedInUserProfileImage,
      listingId: listingId ?? this.listingId,
      senderType: senderType ?? this.senderType,
      parentMessage: parentMessage ?? this.parentMessage,
      parentId: parentId ?? this.parentId,
      parentUsername: parentUsername ?? this.parentUsername,
      reactions: reactions ?? this.reactions,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      tempId: tempId ?? this.tempId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class Reactions {
  int? userId;
  int? reaction;
  String? username;

  Reactions({this.userId, this.reaction, this.username});

  Reactions.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    reaction = json['reaction'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() =>
      {'userId': userId, 'reaction': reaction, 'username': username};
}
