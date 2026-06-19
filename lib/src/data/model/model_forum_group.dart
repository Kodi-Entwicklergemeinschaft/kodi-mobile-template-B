class ForumGroupModel {
  int? id;
  int? forumId;
  String? forumName;
  String? createdAt;
  String? description;
  String? image;
  int? isPrivate;
  int? cityId;
  List<int>? cityIds;
  bool? isJoined;
  bool? isRequested;
  String? status;

  ForumGroupModel({this.id, this.forumId, this.forumName, this.createdAt, this.description, this.image, this.isPrivate, this.cityId, this.cityIds, this.isJoined, this.isRequested, this.status});

  ForumGroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    forumId = json['forumId'];
    forumName = json['forumName'];
    createdAt = json['createdAt'];
    description = json['description'];
    image = json['image'] ?? 'admin/DefaultForum.jpeg';
    isPrivate = json['isPrivate'];
    cityId = json['cityId'] ?? 0;
    cityIds = json['cityIds'] == null ? [] : List<int>.from(json['cityIds']);
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? '';
    data['forumName'] = forumName ?? '';
    data['createdAt'] = createdAt ?? '';
    data['description'] = description ?? '';
    data['image'] = image ?? 'admin/DefaultForum.jpeg';
    data['isPrivate'] = isPrivate ?? 0;
    data['cityIds'] = cityIds ?? [];
    // active/inactive
    data['status'] = status ?? 'inactive';
    return data;
  }
}

enum GroupStatus {
  active,
  inactive,
}
