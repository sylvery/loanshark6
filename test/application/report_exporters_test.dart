import 'package:bookinman/application/reports/report_exporters.dart';
import 'package:bookinman/application/reports/reports_provider.dart';
import 'package:bookinman/domain/entities/penalty_policy.dart';
import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:bookinman/domain/services/portfolio_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

ReportsData _sampleData() => ReportsData(
      monthlyCollections: [
        MonthlyCollection(label: 'Jan 2026', amount: Money(100, 'PGK')),
      ],
      overdueLoans: [
        OverdueReportItem(
          customerName: 'Bob Smith',
          phone: null,
          outstanding: Money(50, 'PGK'),
          loanId: 'l1',
          customerId: 'c1',
        ),
      ],
      analytics: PortfolioAnalytics(
        totalDisbursed: Money(1000, 'PGK'),
        totalCollected: Money(300, 'PGK'),
        totalOutstanding: Money(700, 'PGK'),
        arrearsOutstanding: Money(100, 'PGK'),
        par30Outstanding: Money(50, 'PGK'),
        expectedToDate: Money(500, 'PGK'),
        collectedToDate: Money(300, 'PGK'),
        collectionRate: 0.6,
        par30Ratio: 0.07,
        statusCounts: {
          for (final status in LoanStatus.values) status: 0,
          LoanStatus.active: 2,
          LoanStatus.overdue: 1,
        },
        loanCount: 3,
      ),
      trends: [
        MonthlyTrend(
          label: 'Jan 2026',
          disbursed: Money(1000, 'PGK'),
          collected: Money(300, 'PGK'),
        ),
      ],
    );

void main() {
  group('report exporters', () {
    test('builds CSV with portfolio, status and overdue sections', () {
      final csv = buildReportCsv(_sampleData());

      expect(csv, contains('Total Disbursed,1000.0'));
      expect(csv, contains('Collection Rate,0.60'));
      expect(csv, contains('Active,2'));
      expect(csv, contains('Overdue,1'));
      expect(csv, contains('Bob Smith'));
      expect(csv, contains('Jan 2026,1000.0,300.0'));
    });

    test('builds a valid minimal PDF document', () {
      final pdf = buildReportPdf(_sampleData());

      expect(String.fromCharCodes(pdf.sublist(0, 9)), '%PDF-1.4\n');
      expect(String.fromCharCodes(pdf.sublist(pdf.length - 5)), '%%EOF');
      final text = String.fromCharCodes(pdf);
      expect(text, contains('BookinMan Portfolio Report'));
      expect(text, contains('Total Disbursed: 1000.00'));
      expect(text, contains('Bob Smith - 50.00'));
    });
  });
}
