import '../models/report_model.dart';
import 'api_client.dart';

/// Simulated failure thrown by [ReportService] when the demo switch is on.
class ReportSubmissionException implements Exception {
  final String message;
  const ReportSubmissionException(this.message);

  @override
  String toString() => message;
}

/// Report service - Activity 10.
///
/// Activity 9 used a simulated delay. From Activity 10 the reports are read
/// from and written to PostgreSQL through the FastAPI REST API:
///   GET  /api/reports   -> list (drives the EMPTY state when it is empty)
///   POST /api/reports   -> create (drives the SUCCESS state)
/// The simulated failure can still be triggered on purpose with the demo
/// switch so the ERROR state and the Retry action can be demonstrated.
class ReportService {
  final ApiClient _api;

  ReportService({ApiClient? api}) : _api = api ?? ApiClient();

  String get baseUrl => _api.baseUrl;

  /// Checks that the API and the database are reachable.
  Future<bool> isBackendOnline() async {
    try {
      final res = await _api.get('/api/health');
      if (res is Map && res['database'] == 'connected') return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Reads every report from PostgreSQL. Throws [ApiException] if the
  /// backend cannot be reached.
  Future<List<ReportModel>> fetchReports() async {
    final res = await _api.get('/api/reports');
    final list = (res is Map ? res['reports'] : res) as List;
    return list
        .map((e) => ReportModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Saves a report. Throws [ReportSubmissionException] when the demo switch
  /// is on, and [ApiException] when the real request fails.
  Future<ReportModel> submitReport(
    ReportModel report, {
    bool simulateFailure = false,
  }) async {
    if (simulateFailure) {
      // Give the loading state a moment so it is visible, then fail.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      throw const ReportSubmissionException(
        'Simulated server error (HTTP 500). Turn the switch off to use the real API.',
      );
    }

    final res = await _api.post('/api/reports', report.toApiBody());
    if (res is Map && res['report'] != null) {
      return ReportModel.fromJson(Map<String, dynamic>.from(res['report'] as Map));
    }
    throw const ApiException('The server did not return the saved report.');
  }
}
