# Sample Code for Retrieving and Sharing Files with Agentforce

This repo holds an example of how you can implement two custom Apex actions that let you retrieve an invoice PDF from a third party accounting system (or more generally, a file from any external system) and share it publicly.

Read this blog post [link TBD] to learn more.

## Requirements

This code requires the following:

1. That you have a remote host that serves the invoice PDF. In my case, I wrote a basic HTTP Node server that I deployed on Heroku.
1. That you deploy this code to a Salesforce Org with Agentforce.

## Limitations

There are two important limitations to this solution:

1. This implementation cannot handle files that are larger than the [Apex heap size limit](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm#in_topic_per_transaction_section).
2. Storing documents on the Platform consumes [data storage](https://help.salesforce.com/s/articleView?id=sf.admin_monitorresources.htm&type=5) and you’ll need to schedule some regular cleanup so that you org does not run out of space over time.

## Installation

1. Configure an `Accounting_Service` [External Credential](https://help.salesforce.com/s/articleView?id=sf.nc_named_creds_and_ext_creds.htm&type=5) that points to the server that holds the documents.
1. Optionnaly edit `force-app/main/default/classes/GenerateInvoice.cls` to match your service endpoint that returns the invoice. The default is `/orders/ORDER_Id/invoice` where `ORDER_ID` is the order ID.
1. Deploy the content of this repo to your org:
   ```sh
   sf project deploy start -d force-app
   ```

## Sample Prompts

You can experiment the actions with these sample prompts.

A basic example:

> Get me a shareable password-protected link for the invoice of order O-12345

A more advanced example:

> Draft an email to John Doe with a shareable and password-protected link to his invoice for order O-12345. Thank him for trusting ACME Corp.
