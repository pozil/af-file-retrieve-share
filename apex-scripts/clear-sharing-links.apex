// Clear sharing links
Id docId = '069Wx000000sGxRIAU';
ContentVersion version = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :docId AND IsLatest=true LIMIT 1];
List<ContentDistribution> distributions = [SELECT Id FROM ContentDistribution WHERE ContentVersionId = :version.Id];
System.debug('Removed '+ distributions.size() + ' links for document '+ docId);
System.debug(distributions);
delete distributions;
