import 'package:your_app_name/src/utils/network/base_model.dart';

import 'model.dart';

class ResultApiModel extends BaseModel<ResultApiModel> {
  bool? successValue;
  dynamic data;
  dynamic attr;
  dynamic payment;
  PaginationModel? pagination;
  UserModel? user;
  int? id;
  String? messageValue;
  dynamic token;

  ResultApiModel(
      {this.successValue,
      this.messageValue,
      this.data,
      this.pagination,
      this.attr,
      this.payment,
      this.user,
      this.id,
      this.token});

  factory ResultApiModel.fromJson(Map<String, dynamic> json) {
    return ResultApiModel().fromJson(json);
  }

  @override
  ResultApiModel fromJson(Map<String, dynamic> json) {
    UserModel? user;
    PaginationModel? pagination;

    if (json['user'] != null) {
      user = UserModel.fromJson(json['data']);
    }
    if (json['pagination'] != null) {
      pagination = PaginationModel.fromJson(json['pagination']);
    }

    successValue = json['status'] == 'error' ? false : true;
    data = json['data'] ?? '';
    id = json['id'] ?? 0;
    pagination = pagination;
    attr = json['attr'] ?? '';
    payment = json['payment'] ?? '';
    user = user;
    messageValue = json['message'] ?? '';

    return this;
  }

  get success => successValue ?? false;
  get message => messageValue ?? '';

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
