import 'dart:convert';
import 'dart:typed_data';

import '../../core/utils/date_helpers.dart';
import 'reports_provider.dart';

String buildReportCsv(ReportsData data) {
  final buffer = StringBuffer();
  final analytics = data.analytics;

  buffer.writeln('# BookinMan Portfolio Report');
  buffer.writeln('# Generated,${DateHelpers.iso(DateTime.now())}');
  buffer.writeln();

  buffer.writeln('Section,Metric,Value');
  buffer.writeln('Portfolio,Total Disbursed,${analytics.totalDisbursed.amount}');
  buffer.writeln(
    'Portfolio,Total Outstanding,${analytics.totalOutstanding.amount}',
  );
  buffer.writeln('Portfolio,Total Collected,${analytics.totalCollected.amount}');
  buffer.writeln('Portfolio,Expected To Date,${analytics.expectedToDate.amount}');
  buffer.writeln(
    'Portfolio,Collection Rate,${analytics.collectionRate.toStringAsFixed(2)}',
  );
  buffer.writeln('Portfolio,Arrears,${analytics.arrearsOutstanding.amount}');
  buffer.writeln('Portfolio,PAR30,${analytics.par30Outstanding.amount}');
  buffer.writeln(
    'Portfolio,PAR30 Ratio,${analytics.par30Ratio.toStringAsFixed(2)}',
  );
  buffer.writeln('Portfolio,Loans,${analytics.loanCount}');
  buffer.writeln();

  buffer.writeln('Status,Count');
  for (final entry in analytics.statusCounts.entries) {
    buffer.writeln('${entry.key.label},${entry.value}');
  }
  buffer.writeln();

  buffer.writeln('Month,Disbursed,Collected');
  for (final trend in data.trends) {
    buffer.writeln(
      '${trend.label},${trend.disbursed.amount},${trend.collected.amount}',
    );
  }
  buffer.writeln();

  buffer.writeln('Overdue Customer,Phone,Outstanding,LoanId');
  for (final overdue in data.overdueLoans) {
    buffer.writeln(
      '${_csvField(overdue.customerName)},'
      '${_csvField(overdue.phone ?? '')},'
      '${overdue.outstanding.amount},'
      '${overdue.loanId}',
    );
  }

  return buffer.toString();
}

String _csvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

Uint8List buildReportPdf(ReportsData data) {
  final analytics = data.analytics;
  final builder = _PdfBuilder(title: 'BookinMan Portfolio Report');
  builder.add('Generated: ${DateHelpers.format(DateTime.now())}');
  builder.add('');
  builder.add('PORTFOLIO SUMMARY');
  builder.add('Total Disbursed: ${analytics.totalDisbursed.amount.toStringAsFixed(2)}');
  builder.add('Total Outstanding: ${analytics.totalOutstanding.amount.toStringAsFixed(2)}');
  builder.add('Total Collected: ${analytics.totalCollected.amount.toStringAsFixed(2)}');
  builder.add('Expected To Date: ${analytics.expectedToDate.amount.toStringAsFixed(2)}');
  builder.add('Collection Rate: ${(analytics.collectionRate * 100).toStringAsFixed(0)}%');
  builder.add('Arrears: ${analytics.arrearsOutstanding.amount.toStringAsFixed(2)}');
  builder.add('PAR30: ${analytics.par30Outstanding.amount.toStringAsFixed(2)} (${(analytics.par30Ratio * 100).toStringAsFixed(0)}%)');
  builder.add('Loans: ${analytics.loanCount}');
  builder.add('');
  builder.add('STATUS');
  for (final entry in analytics.statusCounts.entries) {
    builder.add('${entry.key.label}: ${entry.value}');
  }
  builder.add('');
  builder.add('MONTHLY TREND (Disbursed / Collected)');
  for (final trend in data.trends) {
    builder.add(
      '${trend.label}: ${trend.disbursed.amount.toStringAsFixed(0)} / '
      '${trend.collected.amount.toStringAsFixed(0)}',
    );
  }
  builder.add('');
  builder.add('OVERDUE LOANS');
  if (data.overdueLoans.isEmpty) {
    builder.add('None');
  } else {
    for (final overdue in data.overdueLoans) {
      builder.add(
        '${overdue.customerName} - ${overdue.outstanding.amount.toStringAsFixed(2)}',
      );
    }
  }
  return builder.build();
}

class _PdfBuilder {
  _PdfBuilder({required this.title});

  final String title;
  final List<String> _lines = [];

  void add(String line) => _lines.add(line);

  Uint8List build() {
    final content = StringBuffer();
    content.writeln('BT');
    content.writeln('/F1 18 Tf');
    content.writeln('50 790 Td');
    content.writeln('(${_escape(title)}) Tj');
    content.writeln('/F1 11 Tf');
    content.writeln('0 -24 Td');
    for (final line in _lines) {
      content.writeln('(${_escape(line)}) Tj');
      content.writeln('0 -16 Td');
    }
    content.writeln('ET');
    final stream = content.toString();

    final objects = <String>[
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
          '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica '
          '/Encoding /WinAnsiEncoding >>',
      '<< /Length ${stream.length} >>\nstream\n$stream\nendstream',
    ];

    const header = '%PDF-1.4\n';
    final buffer = StringBuffer();
    buffer.write(header);
    final offsets = <int>[];
    var byteCount = header.length;
    for (var i = 0; i < objects.length; i++) {
      offsets.add(byteCount);
      final object = '${i + 1} 0 obj\n${objects[i]}\nendobj\n';
      buffer.write(object);
      byteCount += object.length;
    }
    final xrefStart = byteCount;
    buffer.write('xref\n0 ${objects.length + 1}\n');
    buffer.write('0000000000 65535 f \n');
    for (final offset in offsets) {
      buffer.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }
    buffer.write(
      'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n'
      'startxref\n$xrefStart\n%%EOF',
    );

    return Uint8List.fromList(
      latin1.encode(_toLatin1(buffer.toString())),
    );
  }

  static String _escape(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)');

  static String _toLatin1(String value) =>
      String.fromCharCodes(value.runes.map((r) => r < 256 ? r : 63));
}
