/// Data object for a report created in the EventVenue Caraga system.
/// In the next phase this maps to the REST API / PostgreSQL table.
class ReportModel {
  final String title;
  final String category;
  final String location;
  final String description;
  final String contact;
  final DateTime createdAt;
  final String reference;

  const ReportModel({
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.contact,
    required this.createdAt,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'location': location,
        'description': description,
        'contact': contact,
        'created_at': createdAt.toIso8601String(),
        'reference': reference,
      };
}
