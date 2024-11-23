// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
    List<Result>? results;

    UserModel({
        this.results,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    };
}

class Result {
    int? userId;
    String? name;
    String? role;
    String? city;

    Result({
        this.userId,
        this.name,
        this.role,
        this.city,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        userId: json["user_id"],
        name: json["name"],
        role: json["role"],
        city: json["city"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "role": role,
        "city": city,
    };
}
