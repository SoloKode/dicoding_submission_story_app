import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'login_result.g.dart';

@JsonSerializable()
class LoginResult {
  String userId;
  String name;
  String token;

  LoginResult({
    required this.userId,
    required this.name,
    required this.token,
  });

  @override
  String toString() =>
      'LoginResult(userid: $userId, name: $name, token: $token)';

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
  
  String toJsonString() => json.encode(toJson());

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  factory LoginResult.fromJsonString(String source) =>
      LoginResult.fromJson(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginResult &&
        other.userId == userId &&
        other.name == name &&
        other.token == token;
  }

  @override
  int get hashCode => Object.hash(userId, name, token);
}
