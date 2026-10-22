import '../models/report_model.dart';

/// Simulated failure thrown by [ReportService] when the demo switch is on.
class ReportSubmissionException implements Exception {
  final String message;
  const ReportSubmissionException(this.message);

  @override
  String toString() => message;
}

/// Simulated backend for the report form (Activity 9).
///
/// The real REST API (PHP + MySQL) is not connected yet, so this service
/// simulates an asynchronous request with [Future.delayed]. Every response
/// here is SIMULATED and must be labeled as such in the evidence report.
class ReportService {
  final List<ReportModel> _savedReports = <ReportModel>[];

  /// Reports already saved in this session.
  List<ReportModel> get savedReports => List<ReportModel>.unmodifiable(_savedReports);

  /// Simulated submit. Returns the saved report.
  /// Throws [ReportSubmissionException] when [simulateFailure] is true.
  Future<ReportModel> submitReport(
    ReportModel report, {
    bool simulateFailure = false,
  }) async {
    // Simulated network latency so the LOADING state is visible.
    await Future<void>.delayed(const Duration(seconds: 3));

    if (simulateFailure) {
      throw const ReportSubmissionException(
        'Simulated server error (HTTP 500). The real REST API is not connected yet.',
      );
    }

    _savedReports.insert(0, report);
    return report;
  }
}
