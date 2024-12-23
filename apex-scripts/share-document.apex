// Share a document
GeneratePublicDocumentLink.LinkRequest request = new GeneratePublicDocumentLink.LinkRequest();
request.contentDocumentId = '069Wx000000sGxRIAU';
request.isPasswordProtected = true;

List<GeneratePublicDocumentLink.LinkRequest> requests = new List<GeneratePublicDocumentLink.LinkRequest>{ request };
List<GeneratePublicDocumentLink.Link> links = generatePublicDocumentLink.generatePublicDocumentLinks(requests);
System.debug(links);