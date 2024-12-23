public with sharing class GenerateInvoice {
  @InvocableMethod(
    label='Generate Invoice'
    description='Generates an invoice for an order and stores it in a file.'
  )
  public static List<Invoice> generateInvoices(List<InvoiceRequest> requests) {
    // Fetch and create invoices files
    List<ContentVersion> invoiceFiles = new List<ContentVersion>();
    for (InvoiceRequest request : requests) {
      // Download invoice
      Blob invoiceBlob = downloadInvoice(request.orderId);
      // Prepare invoice file
      ContentVersion cv = new ContentVersion();
      cv.Title = 'Invoice for order ' + request.orderId;
      cv.PathOnClient = request.orderId + '.pdf';
      cv.VersionData = invoiceBlob;
      invoiceFiles.add(cv);
    }
    insert invoiceFiles;

    // Re-fetch content versions to obtain generated document content IDs
    Set<Id> contentVersionIds = new Set<Id>();
    for (ContentVersion invoice : invoiceFiles) {
      contentVersionIds.add(invoice.Id);
    }
    invoiceFiles = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id IN :contentVersionIds
    ];

    // Prepare output
    List<Invoice> invoices = new List<Invoice>();
    for (ContentVersion invoiceFile : invoiceFiles) {
      Invoice invoice = new Invoice();
      invoice.contentDocumentId = invoiceFile.ContentDocumentId;
      invoices.add(invoice);
    }
    return invoices;
  }

  private static Blob downloadInvoice(String orderId) {
    // Prepare API request
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
      'callout:Accounting_Service/orders/' + orderId + '/invoice'
    );
    req.setMethod('GET');
    // Make callout
    Http http = new Http();
    HttpResponse res = http.send(req);
    if (res.getStatusCode() != 200) {
      throw new CalloutException('Bad response: ' + res);
    }
    Blob invoiceBlob = res.getBodyAsBlob();
    return invoiceBlob;
  }

  public class InvoiceRequest {
    @InvocableVariable(
      required=true
      description='Order for which the invoice should be generated.'
    )
    public String orderId;
  }

  public class Invoice {
    @InvocableVariable(description='Document ID that holds the invoice.')
    public Id contentDocumentId;
  }
}
