class ResponseModel {
  int?    errorCode;
  String? errorMessage;
  Map<String, dynamic> data  = {};
  List<dynamic>        datas = [];
  bool success = false;

  ResponseModel({this.errorCode, this.errorMessage, this.success = false});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    errorCode    = json['error_code'] as int?;
    errorMessage = json['error_message'] as String?;
    data  = {};
    datas = [];
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) data  = json['data'];
      else if (json['data'] is List<dynamic>)   datas = json['data'];
    }
    success = errorCode == 0;
  }
}
