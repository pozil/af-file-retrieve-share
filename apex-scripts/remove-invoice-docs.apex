// Remove invoice documents
List<ContentDocument> invoices = [SELECT Id FROM ContentDocument WHERE Title LIKE '%Invoice for order%'];
System.debug('Removed '+ invoices.size() + ' invoices');
System.debug(invoices);
delete invoices;