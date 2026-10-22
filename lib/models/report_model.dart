import 'dart:convert';

/// Data object for a report created in the EventVenue Caraga system.
///
/// Activity 10: the record is now stored in PostgreSQL through the REST API,
/// so the model also knows how to read itself from the API JSON.
class ReportModel {
  final int? reportId;
  final String title;
  final String category;
  final String location;
  final String description;
  final String contact;
  final String status;
  final DateTime? createdAt;
  final String reference;

  const ReportModel({
    this.reportId,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.contact,
    this.status = 'open',
    this.createdAt,
    this.reference = '',
  });

  /// Builds a report from the JSON returned by the REST API.
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['report_id'] as int?,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      reference: json['reference'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'location': location,
        'description': description,
        'contact': contact,
      };

  /// The body sent to POST /api/reports.
  Map<String, dynamic> toApiBody() => toJson();

  @override
  String toString() => 'ReportModel($reference, $title)';
}

/// Helper used when the API sends a list of reports.
List<ReportModel> reportListFromJson(String body) {
  final decoded = jsonDecode(body);
  final list = (decoded is Map ? decoded['reports'] : decoded) as List;
  return list
      .map((e) => ReportModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}
