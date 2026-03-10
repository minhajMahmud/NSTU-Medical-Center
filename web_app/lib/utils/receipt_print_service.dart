export 'receipt_print_service_stub.dart'
    if (dart.library.html) 'receipt_print_service_web.dart';

class ReceiptLineItem {
  const ReceiptLineItem({
    required this.code,
    required this.name,
    required this.type,
    required this.amount,
    this.extra = '',
  });

  final String code;
  final String name;
  final String type;
  final double amount;
  final String extra;
}

String buildNstuPaymentReceiptHtml({
  required String title,
  required String patientName,
  required String mobile,
  required String testName,
  required String paymentMethod,
  required String transactionId,
  required String paymentDate,
  required double amount,
  String footerNote = 'Printed from NSTU Medical Center.',
}) {
  return '''
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <title>${_escapeHtml(title)}</title>
    <style>
        @page { margin: 14mm; }
        body { font-family: Arial, Helvetica, sans-serif; color: #0f172a; margin: 0; }
        .sheet { border: 1px solid #e2e8f0; border-radius: 12px; padding: 18px; }
        .brand { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .brand h1 { margin: 0; font-size: 22px; letter-spacing: .4px; }
        .brand p { margin: 0; color: #475569; font-size: 12px; }
        .title { margin: 8px 0 12px 0; font-size: 20px; font-weight: 800; }
        .meta { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 20px; margin-bottom: 12px; }
        .meta div { font-size: 13px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #cbd5e1; padding: 8px; font-size: 13px; }
        th { background: #f1f5f9; text-align: left; }
        .right { text-align: right; font-weight: 700; }
        .footer { margin-top: 12px; color: #64748b; font-size: 12px; }
        @media print { .sheet { border: none; border-radius: 0; padding: 0; } }
    </style>
</head>
<body>
    <div class="sheet">
        <div class="brand">
            <div>
                <h1>NSTU Medical Center</h1>
                <p>Noakhali Science and Technology University</p>
            </div>
            <p>${_escapeHtml(paymentDate)}</p>
        </div>
        <div class="title">${_escapeHtml(title)}</div>
        <div class="meta">
            <div><strong>Patient:</strong> ${_escapeHtml(patientName)}</div>
            <div><strong>Mobile:</strong> ${_escapeHtml(mobile)}</div>
            <div><strong>Test:</strong> ${_escapeHtml(testName)}</div>
            <div><strong>Payment Method:</strong> ${_escapeHtml(paymentMethod)}</div>
            <div><strong>Transaction ID:</strong> ${_escapeHtml(transactionId)}</div>
            <div><strong>Payment Date:</strong> ${_escapeHtml(paymentDate)}</div>
        </div>
        <table>
            <thead>
                <tr><th>Description</th><th style="width: 180px;">Amount (৳)</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td>${_escapeHtml(testName)} payment</td>
                    <td class="right">${amount.toStringAsFixed(2)}</td>
                </tr>
                <tr>
                    <td class="right"><strong>Total</strong></td>
                    <td class="right"><strong>${amount.toStringAsFixed(2)}</strong></td>
                </tr>
            </tbody>
        </table>
        <div class="footer">${_escapeHtml(footerNote)}</div>
    </div>
</body>
</html>
''';
}

String buildNstuLabReceiptHtml({
  required String title,
  required String patientName,
  required String mobile,
  required String invoiceNo,
  required String dateTime,
  required List<ReceiptLineItem> lines,
  String? barcodeSvg,
}) {
  final rows = lines
      .map(
        (line) =>
            '<tr><td>${_escapeHtml(line.code)}</td><td>${_escapeHtml(line.name)}</td><td>${_escapeHtml(line.extra.isEmpty ? '-' : line.extra)}</td><td>${_escapeHtml(line.type)}</td><td class="right">${line.amount.toStringAsFixed(2)}</td></tr>',
      )
      .join();
  final total = lines.fold<double>(0, (sum, line) => sum + line.amount);

  return '''
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <title>${_escapeHtml(title)}</title>
    <style>
        @page { margin: 14mm; }
        body { font-family: Arial, Helvetica, sans-serif; color: #0f172a; margin: 0; }
        .sheet { border: 1px solid #e2e8f0; border-radius: 12px; padding: 18px; }
        .brand { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .brand h1 { margin: 0; font-size: 22px; letter-spacing: .4px; }
        .brand p { margin: 0; color: #475569; font-size: 12px; }
        .meta { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 20px; margin-bottom: 12px; }
        .meta div { font-size: 13px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #cbd5e1; padding: 8px; font-size: 13px; }
        th { background: #f1f5f9; text-align: left; }
        .right { text-align: right; font-weight: 700; }
        .footer { margin-top: 12px; color: #64748b; font-size: 12px; }
        @media print { .sheet { border: none; border-radius: 0; padding: 0; } }
    </style>
</head>
<body>
    <div class="sheet">
        <div class="brand">
            <div>
                <h1>NSTU Medical Center</h1>
                <p>Noakhali Science and Technology University</p>
            </div>
            <p>${_escapeHtml(dateTime)}</p>
        </div>
        <div style="font-size:20px;font-weight:800;margin:8px 0 12px 0;">${_escapeHtml(title)}</div>
        <div class="meta">
            <div><strong>Patient:</strong> ${_escapeHtml(patientName)}</div>
            <div><strong>Mobile:</strong> ${_escapeHtml(mobile)}</div>
            <div><strong>Invoice:</strong> ${_escapeHtml(invoiceNo)}</div>
            <div><strong>Generated:</strong> ${_escapeHtml(dateTime)}</div>
        </div>
        ${barcodeSvg == null ? '' : '<div style="margin:8px 0 12px 0; border:1px solid #e2e8f0; border-radius:8px; padding:8px;">$barcodeSvg</div>'}
        <table>
            <thead>
                <tr><th>Code</th><th>Test Name</th><th>TAT</th><th>Type</th><th>Amount (৳)</th></tr>
            </thead>
            <tbody>
                $rows
                <tr>
                    <td colspan="4" class="right"><strong>Total Due</strong></td>
                    <td class="right"><strong>${total.toStringAsFixed(2)}</strong></td>
                </tr>
            </tbody>
        </table>
        <div class="footer">Printed from NSTU Medical Center lab upload portal.</div>
    </div>
</body>
</html>
''';
}

String _escapeHtml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
