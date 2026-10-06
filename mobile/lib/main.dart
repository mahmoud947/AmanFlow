import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config.dart';
import 'data/api_client.dart';
import 'data/repository.dart';

void main() {
  runApp(
    AmanFlowApp(
      repository: ApiFinanceRepository(ApiClient(AppConfig.apiBaseUrl)),
    ),
  );
}
