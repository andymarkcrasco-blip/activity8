import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_state_view.dart';
import '../widgets/app_text_field.dart';

/// The four essential asynchronous UI responses required in Activity 9.
enum ReportUiState { idle, loading, success, empty, error }

/// Activity 9 - Report Form screen for the EventVenue Caraga system.
///
/// A user (client or vendor) files a report about a venue listing,
/// a booking problem, or a suggestion. The form reuses the shared
/// widgets from Activity 8 (app_button.dart, app_text_field.dart)
/// and shows four real asynchronous responses:
/// LOADING -> SUCCESS | ERROR, and EMPTY when no reports exist.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Input controllers (defined here, reused by the shared AppTextField).
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();

  final ReportService _reportService = ReportService();

  String? _category;
  String? _location;

  /// Demo switch so the group can reproduce the ERROR state live.
  bool _simulateFailure = false;

  ReportUiState _uiState = ReportUiState.idle;
  String _message = '';
  List<ReportModel> _reports = <ReportModel>[];

  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _refreshReports() {
    setState(() {
      _reports = _reportService.savedReports;
      if (_reports.isEmpty && _uiState != ReportUiState.loading) {
        _uiState = ReportUiState.empty;
      }
    });
  }

  /// Validates the form, then runs the simulated async submit.
  Future<void> submitReport() async {
    // Prevent duplicate submissions.
    if (_uiState == ReportUiState.loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _uiState = ReportUiState.loading;
      _message = 'Sending your report to the EventVenue Caraga team...';
    });

    try {
      final report = ReportModel(
        title: _titleCtrl.text.trim(),
        category: _category!,
        location: _location!,
        description: _descriptionCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        createdAt: DateTime.now(),
        reference: 'EV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      );

      // Simulated async request (Future.delayed) - the real REST API
      // (PHP + MySQL) will replace this in the next phase.
      await _reportService.submitReport(
        report,
        simulateFailure: _simulateFailure,
      );

      if (!mounted) return;
      setState(() {
        _uiState = ReportUiState.success;
        _message =
            'Report ${report.reference} saved successfully (simulated response).';
      });
      _formKey.currentState!.reset();
      _titleCtrl.clear();
      _descriptionCtrl.clear();
      _contactCtrl.clear();
      setState(() {
        _category = null;
        _location = null;
        _reports = _reportService.savedReports;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uiState = ReportUiState.error;
        _message = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _uiState == ReportUiState.loading;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Report an Issue',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            'EventVenue Caraga - submit a report about a venue, a booking, or a suggestion.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // ---------------- FORM ----------------
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Shared widget reused from Activity 8 (login_screen.dart).
                AppTextField(
                  label: 'Report Title',
                  controller: _titleCtrl,
                  prefixIcon: Icons.title,
                  helperText: 'Minimum 5 characters',
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Report title is required';
                    if (value.length < 5) {
                      return 'Report title must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.reportCategories
                      .map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: isLoading ? null : (v) => setState(() => _category = v),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please choose a category' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _location,
                  decoration: const InputDecoration(
                    labelText: 'Location (Caraga Region)',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.reportLocations
                      .map((l) => DropdownMenuItem<String>(
                            value: l,
                            child: Text(l),
                          ))
                      .toList(),
                  onChanged: isLoading ? null : (v) => setState(() => _location = v),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please choose a location' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Description',
                  controller: _descriptionCtrl,
                  maxLines: 4,
                  prefixIcon: Icons.description,
                  helperText: 'Describe the problem, at least 10 characters',
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Description is required';
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Contact Number (optional)',
                  controller: _contactCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isNotEmpty && value.length < 7) {
                      return 'Enter a valid contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _simulateFailure,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _simulateFailure = v),
                  title: const Text('Simulate API failure (demo only)'),
                  subtitle: const Text(
                    'Turn on to demonstrate the ERROR state and the Retry action.',
                  ),
                ),
                const SizedBox(height: 8),
                // Shared widget reused from Activity 8 (login_screen.dart).
                AppButton(
                  label: 'Submit Report',
                  icon: Icons.send,
                  isLoading: isLoading,
                  onPressed: submitReport,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),

          // ---------------- STATE RESPONSES ----------------
          Text('Response',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          _buildStateView(),

          const SizedBox(height: 20),
          Text('Submitted Reports (${_reports.length})',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (_reports.isEmpty)
            const AppCard(
              title: 'Empty',
              body: 'No report records yet. Submit a report above to fill this list.',
              icon: Icons.inbox,
            )
          else
            ..._reports.map(
              (r) => AppCard(
                title: '${r.reference} - ${r.title}',
                body:
                    '${r.category}\n${r.location}\n${r.description}\nContact: ${r.contact.isEmpty ? 'N/A' : r.contact}',
                icon: Icons.report_problem,
              ),
            ),

          const SizedBox(height: 16),
          AppButton(
            label: 'Back to Home',
            icon: Icons.home,
            isOutlined: true,
            onPressed: () => context.go(AppConstants.homeRoute),
          ),
        ],
      ),
    );
  }

  /// Builds the visible response for the current [ReportUiState].
  Widget _buildStateView() {
    switch (_uiState) {
      case ReportUiState.loading:
        return const AppStateView(
          kind: AppStateKind.loading,
          icon: Icons.hourglass_top,
          title: 'LOADING - Submitting your report',
          message:
              'Simulated async request is pending. Please wait and do not submit twice.',
        );

      case ReportUiState.success:
        return AppStateView(
          kind: AppStateKind.success,
          icon: Icons.check_circle,
          title: 'SUCCESS - Report submitted',
          message: _message,
          actionLabel: 'Submit another report',
          onAction: () => setState(() {
            _uiState = _reports.isEmpty
                ? ReportUiState.empty
                : ReportUiState.success;
            _message = '';
          }),
        );

      case ReportUiState.error:
        return AppStateView(
          kind: AppStateKind.error,
          icon: Icons.error_outline,
          title: 'ERROR - Report was not submitted',
          message: '$_message\nCorrect the problem or press Retry.',
          actionLabel: 'Retry',
          onAction: submitReport,
        );

      case ReportUiState.empty:
      case ReportUiState.idle:
        return const AppStateView(
          kind: AppStateKind.empty,
          icon: Icons.inbox,
          title: 'EMPTY - No report records',
          message:
              'There are no reports to display yet. Fill in the form above to create the first one.',
        );
    }
  }
}
