/// Formats an invoice id into the shared display format used for both the
/// invoice number heading and the "Job No." on the inspection report.
String formatInvoiceNumber(String invoiceId) =>
    'INV-#${invoiceId.substring(0, 8).toUpperCase()}';
