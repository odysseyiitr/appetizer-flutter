import 'dart:convert';
import 'dart:io';
import 'package:appetizer/constants.dart';
import 'package:appetizer/models/failure_model.dart';
import 'package:appetizer/utils/app_exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiUtils {
  static http.Client client = http.Client();

  /// Returns JSON GET response
  static Future<dynamic> get(String uri, {Map<String, String> headers}) async {
    try {
      final response = await client.get(Uri.parse(uri), headers: headers);
      final jsonResponse = ApiUtils.jsonResponse(response);
      return jsonResponse;
    } on UnauthorizedException catch (e) {
      print(e.message);
      throw Failure(Constants.UNAUTHORIZED_EXCEPTION);
    } on SocketException catch (e) {
      print(e.message);
      throw Failure(Constants.NO_INTERNET_CONNECTION);
    } on HttpException catch (e) {
      print(e.message);
      throw Failure(Constants.HTTP_EXCEPTION);
    }
  }

  /// Returns JSON POST response
  static Future<dynamic> post(String uri,
      {Map<String, String> headers, dynamic body}) async {
    try {
      final response = await client.post(Uri.parse(uri),
          headers: headers, body: jsonEncode(body));
      final jsonResponse = ApiUtils.jsonResponse(response);
      return jsonResponse;
    } on UnauthorizedException catch (e) {
      print(e.message);
      throw Failure(Constants.UNAUTHORIZED_EXCEPTION);
    } on SocketException catch (e) {
      print(e.message);
      throw Failure(Constants.NO_INTERNET_CONNECTION);
    } on HttpException catch (e) {
      print(e.message);
      throw Failure(Constants.HTTP_EXCEPTION);
    }
  }

  /// Returns JSON PUT response
  static Future<dynamic> put(String uri,
      {Map<String, String> headers, dynamic body}) async {
    try {
      final response = await client.put(
        Uri.parse(uri),
        headers: headers,
        body: jsonEncode(body),
      );
      final jsonResponse = ApiUtils.jsonResponse(response);
      return jsonResponse;
    } on UnauthorizedException catch (e) {
      print(e.message);
      throw Failure(Constants.UNAUTHORIZED_EXCEPTION);
    } on SocketException catch (e) {
      print(e.message);
      throw Failure(Constants.NO_INTERNET_CONNECTION);
    } on HttpException catch (e) {
      print(e.message);
      throw Failure(Constants.HTTP_EXCEPTION);
    }
  }

  /// Returns JSON PATCH response
  static Future<dynamic> patch(String uri,
      {Map<String, String> headers, dynamic body}) async {
    try {
      final response = await client.patch(Uri.parse(uri),
          headers: headers, body: jsonEncode(body));
      final jsonResponse = ApiUtils.jsonResponse(response);
      return jsonResponse;
    } on UnauthorizedException catch (e) {
      print(e.message);
      throw Failure(Constants.UNAUTHORIZED_EXCEPTION);
    } on SocketException catch (e) {
      print(e.message);
      throw Failure(Constants.NO_INTERNET_CONNECTION);
    } on HttpException catch (e) {
      print(e.message);
      throw Failure(Constants.HTTP_EXCEPTION);
    }
  }

  /// Returns JSON DELETE response
  static Future<dynamic> delete(String uri,
      {Map<String, String> headers}) async {
    try {
      final response = await http.delete(Uri.parse(uri), headers: headers);
      final jsonResponse = ApiUtils.jsonResponse(response);
      return jsonResponse;
    } on UnauthorizedException catch (e) {
      print(e.message);
      throw Failure(Constants.UNAUTHORIZED_EXCEPTION);
    } on SocketException catch (e) {
      print(e.message);
      throw Failure(Constants.NO_INTERNET_CONNECTION);
    } on HttpException catch (e) {
      print(e.message);
      throw Failure(Constants.HTTP_EXCEPTION);
    }
  }

  static dynamic jsonResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        if (response.body == '') return;
        var responseJson = json.decode(response.body);
        print(responseJson);
        return responseJson;
      case 400:
        print(response.body);
        throw BadRequestException(response.body);
      case 401:
        print(response.body);
        throw UnauthorizedException(response.body);
      case 403:
        print(response.body);
        throw ForbiddenException(response.body);
      case 404:
        print(response.body);
        throw NotFoundException(response.body);
      case 409:
        print(response.body);
        throw ConflictException(response.body);
      case 500:
        print(response.body);
        throw InternalServerErrorException(response.body);
      case 503:
        print(response.body);
        throw ServiceUnavailableException(response.body);
      default:
        print(response.body);
        throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}',
        );
    }
  }

  static Future<void> addTokenToHeaders(Map<String, String> headers) async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    headers.addAll({'Authorization': 'Token $token'});
  }
}
