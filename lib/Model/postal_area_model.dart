/// area_name : "Islamabad - Airport New Societies"

class PostalAreaModel {
  PostalAreaModel({
    String? areaName,
  }) {
    _areaName = areaName;
  }

  PostalAreaModel.fromJson(dynamic json) {
    _areaName = json['area_name'];
  }

  String? _areaName;

  PostalAreaModel copyWith({
    String? areaName,
  }) =>
      PostalAreaModel(
        areaName: areaName ?? _areaName,
      );

  String? get areaName => _areaName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['area_name'] = _areaName;
    return map;
  }
}