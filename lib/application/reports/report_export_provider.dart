import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/date_helpers.dart';
import 'report_exporters.dart';
import 'reports_provider.dart';

enum ReportFormat { csv, pdf }

enum ReportExportStatus { idle, exporting, done, error }

class ReportExportState {
  const ReportExportState({
    this.status = ReportExportStatus.idle,
    this.path,
    this.error,
  });

  final ReportExportStatus status;
  final String? path;
  final String? error;

  ReportExportState copyWith({
    ReportExportStatus? status,
    String? path,
    String? error,
  }) =>
      ReportExportState(
        status: status ?? this.status,
        path: path ?? this.path,
        error: error ?? this.error,
      );
}

final reportExportProvider =
    StateNotifierProvider<ReportExportController, ReportExportState>(
  (ref) => ReportExportController(ref),
);

class ReportExportController extends StateNotifier<ReportExportState> {
  ReportExportController(this._ref) : super(const ReportExportState());

  final Ref _ref;

  Future<void> export(ReportsData data, ReportFormat format) async {
    state = const ReportExportState(status: ReportExportStatus.exporting);
    try {
      final bytes = format == ReportFormat.csv
          ? Uint8List.fromList(utf8.encode(buildReportCsv(data)))
          : buildReportPdf(data);
      final directory = await getApplicationDocumentsDirectory();
      final stamp = DateHelpers.iso(DateTime.now()).replaceAll('-', '');
      final extension = format == ReportFormat.csv ? 'csv' : 'pdf';
      final file =
          File('${directory.path}/bookinman_report_$stamp.$extension');
      await file.writeAsBytes(bytes);
      state = state.copyWith(
        status: ReportExportStatus.done,
        path: file.path,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ReportExportStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> open(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
