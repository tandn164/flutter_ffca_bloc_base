import '../utils/serializable.dart';

class BaseResponse<T> {
  BaseResponse({
    this.data,
    this.meta,
  });

  T? data;
  Meta? meta;

  factory BaseResponse.fromJson(Map<String, dynamic> json, Function(Map<String, dynamic>)? create) {
    dynamic data;
    if (json["data"] is T) {
      data = json["data"];
    } else if (create != null) {
      data = create(json["data"]);
    } else {
      data = null;
    }

    return BaseResponse<T>(
      meta: Meta.fromJson(json["meta"]),
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data is Serializable) {
      map['data'] = (data as Serializable).toJson();
    } else {
      map['data'] = data;
    }
    map['meta'] = meta?.toJson();
    return map;
  }
}

class Meta {
  int? code;
  String? msg;
  String? message;
  String? errorCode;

  Meta({this.code, this.message, this.msg, this.errorCode});

  Meta.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    message = json['message'];
    errorCode = json['errorCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    data['message'] = message;
    data['errorCode'] = errorCode;
    return data;
  }
}