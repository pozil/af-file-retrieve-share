// Generate an invoice
GenerateInvoice.InvoiceRequest request = new GenerateInvoice.InvoiceRequest();
request.orderId = 'O-12345';
List<GenerateInvoice.Invoice> invoices = GenerateInvoice.generateInvoices(new List<GenerateInvoice.InvoiceRequest>{ request });
System.debug(invoices);
