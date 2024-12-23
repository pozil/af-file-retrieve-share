/**
 * Action that shares document via public links using ContentDistribution
 * https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdistribution.htm
 */
public with sharing class GeneratePublicDocumentLink {
  // Link is valid for 7 days by default
  private static Integer DEFAULT_LINK_EXPIRY_DAYS = 7;

  @InvocableMethod(
    label='Generate Public Document Link'
    description='Generates a public link for the document with the provided ID.'
  )
  public static List<Link> generatePublicDocumentLinks(
    List<LinkRequest> linkRequests
  ) {
    // Get document IDs
    Set<Id> docIds = new Set<Id>();
    for (LinkRequest linkRequest : linkRequests) {
      docIds.add(linkRequest.contentDocumentId);
    }

    // Retrieve latest doc versions
    Map<Id, ContentVersion> docVersions = new Map<Id, ContentVersion>();
    List<ContentVersion> versions = [
      SELECT Id, Title, ContentDocumentId
      FROM ContentVersion
      WHERE ContentDocumentId IN :docIds AND IsLatest = TRUE
    ];
    for (ContentVersion version : versions) {
      docVersions.put(version.ContentDocumentId, version);
    }

    // Create content distribution records
    List<ContentDistribution> distributions = new List<ContentDistribution>();
    for (LinkRequest linkRequest : linkRequests) {
      // Get latest doc version
      ContentVersion docVersion = docVersions.get(
        linkRequest.contentDocumentId
      );
      // Prepare link expiry date
      DateTime expiryDate = linkRequest.expiryDate ??
        DateTime.now().addDays(DEFAULT_LINK_EXPIRY_DAYS);
      // Prepare content distribution record
      ContentDistribution distribution = new ContentDistribution(
        Name = docVersion.Title,
        ContentVersionId = docVersion.Id,
        PreferencesAllowViewInBrowser = true,
        PreferencesPasswordRequired = linkRequest.isPasswordProtected,
        PreferencesExpires = true,
        ExpiryDate = expiryDate
      );
      distributions.add(distribution);
    }
    insert distributions;

    // Re-fetch distributions to retrieve generated public links and optional passwords
    Set<Id> distIds = new Set<Id>();
    for (ContentDistribution dist : distributions) {
      distIds.add(dist.Id);
    }
    distributions = [
      SELECT DistributionPublicUrl, ExpiryDate, Password
      FROM ContentDistribution
      WHERE Id IN :distIds
    ];

    // Prepare outputs with links
    List<Link> links = new List<Link>();
    for (ContentDistribution dist : distributions) {
      Link link = new Link();
      link.url = dist.DistributionPublicUrl;
      link.expiryDate = dist.ExpiryDate;
      link.password = dist.Password;
      links.add(link);
    }
    return links;
  }

  public class LinkRequest {
    @InvocableVariable(required=true description='Content Document ID.')
    public Id contentDocumentId;

    @InvocableVariable(description='Optional link expiry date.')
    public DateTime expiryDate;

    @InvocableVariable(description='Generate a password for the link.')
    public Boolean isPasswordProtected;
  }

  public class Link {
    @InvocableVariable(description='Public link to the document.')
    public String url;

    @InvocableVariable(
      description='Date after which the public link will expire.'
    )
    public DateTime expiryDate;

    @InvocableVariable(
      description='Password required to access the link to the document.'
    )
    public String password;
  }
}
