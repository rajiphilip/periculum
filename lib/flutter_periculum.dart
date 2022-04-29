import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_periculum/models/AffordabilityResponse.dart';
import 'package:flutter_periculum/models/CreditScoreResponse.dart';
import 'package:flutter_periculum/models/CustomerIdentificationPayload.dart';
import 'package:flutter_periculum/models/StatementResponse.dart';
import 'package:flutter_periculum/models/StatementTransactionResponse.dart';
import 'package:http/http.dart' as http;

class FlutterPericulum {
  static const MethodChannel _channel = MethodChannel('flutter_periculum');
  static const String BASE_URL = "https://api.insights-periculum.com";

  static Future<String> mobileDataAnalysis({
    required String token,
    String? phoneNumber,
    String? bvn,
    String? statementName,
  }) async {
    Map<String, dynamic> myresponse;

    final String response =
        await _channel.invokeMethod('generateMobileDataAnalysis', {
      'phoneNumber': phoneNumber,
      "bvn": bvn,
      'statementName': statementName,
      "token": token,
    });

    var result = jsonDecode(response);

    if (result != null) {
      myresponse = {"status": true, "data": response};
    } else {
      myresponse = {
        "status": false,
        "msg": result["title"],
      };
    }

    return jsonEncode(myresponse).toString();
  }

  static Future<AffordabilityResponse> affordabilityAnalysis({
    required String token,
    required double dti,
    required int statementKey,
    required int loanTenure,
    int? averageMonthlyTotalExpenses,
    int? averageMonthlyLoanRepaymentAmount,
  }) async {
    Map<String, dynamic> map;

    AffordabilityResponse affordabilityResponse;
    String response =
        await _channel.invokeMethod('generateAffordabilityAnalysis', {
      'token': token,
      'dti': dti,
      'statementKey': statementKey,
      'loanTenure': loanTenure,
      'averageMonthlyTotalExpenses': averageMonthlyTotalExpenses,
      'averageMonthlyLoanRepaymentAmount': averageMonthlyLoanRepaymentAmount,
    });

    var result = json.decode(response);
    map = json.decode(response);
    affordabilityResponse = AffordabilityResponse.fromJson(map);
    return affordabilityResponse;
  }

  static Future<StatementResponse> statementAnalytics({
    required String token,
    required String statementKey,
  }) async {
    Map<String, dynamic> map;
    String response = await _channel.invokeMethod('getStatementAnalytics', {
      'token': token,
      'statementKey': statementKey,
    });

    map = json.decode(response);
    StatementResponse exisitingStatementResponse =
        StatementResponse.fromJson(map);
    debugPrint(exisitingStatementResponse.name);
    return exisitingStatementResponse;
  }

  static Future<List<CreditScoreResponse>> getExisitingCreditScore({
    required String token,
    required String statementKey,
  }) async {
    String response = await _channel.invokeMethod('getExistingCreditScore', {
      'token': token,
      'statementKey': statementKey,
    });

    try {
      List<CreditScoreResponse> responseList;

      responseList = (json.decode(response) as List)
          .map((i) => CreditScoreResponse.fromJson(i))
          .toList();

      return responseList;
    } catch (e) {
      throw '{"status": false, "error": ${e.toString()}}';
    }
  }

  static Future<List<Transaction>> getStatementTransaction({
    required String token,
    required String statementKey,
  }) async {
    String response = await _channel.invokeMethod('getStatementTransaction', {
      'token': token,
      'statementKey': statementKey,
    });

    try {
      List<Transaction> responseList;

      responseList = (json.decode(response) as List)
          .map((i) => Transaction.fromJson(i))
          .toList();

      return responseList;
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<CreditScoreResponse> generateCreditScore({
    required String token,
    required String statementKey,
  }) async {
    final uri = Uri.parse('$BASE_URL/creditscore/$statementKey');

    var client = http.Client();
    Map<String, dynamic> map;
    var response;
    try {
      response = await client.post(
        uri,
        body: jsonEncode({}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var result = response.body;

      map = json.decode(result);
      CreditScoreResponse creditScoreResponse =
          CreditScoreResponse.fromJson(map);
      return creditScoreResponse;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<dynamic> attachCustomerIdentificationInfromation({
    required String token,
    required String statementKey,
    required CustomerIdentificationPayload customerIdentificationPayload,
  }) async {
    final uri = Uri.parse('$BASE_URL/statements/identification');

    var client = http.Client();
    var response;
    var payload =
        customerIdentificationPayloadToJson(customerIdentificationPayload);
    try {
      response = await client.patch(
        uri,
        body: json.encode({
          // "statementKey": 120,
          // "identificationData": [
          //   {"IdentifierName": "bvn", "Value": "111"},
          //   {"IdentifierName": "nin", "Value": "111"}
          // ]
          payload
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint(payload);
      var result = response.statusCode;

      debugPrint(result.toString());

      return result;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw e.toString();
    }
  }
}
