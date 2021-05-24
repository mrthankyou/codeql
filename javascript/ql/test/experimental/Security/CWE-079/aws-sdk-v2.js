var http = require("http"),
    url = require("url"),
    AWS = require('aws-sdk');

var server = http.createServer(function(req, res) {
	var html_body = req.url;
  aws.config.loadFromPath('./config.json');

  // SendEmail with params
  //
  const sender = "Sender Name <sender@example.com>";
  const recipient = "recipient@example.com";
  const configuration_set = "ConfigSet";
  const subject = "Amazon SES Test (AWS SDK for JavaScript in Node.js)";
  const body_text = "Amazon SES Test (SDK for JavaScript in Node.js)\r\n"
                  + "This email was sent with Amazon SES using the "
                  + "AWS SDK for JavaScript in Node.js.";
  const charset = "UTF-8";

  var ses = new AWS.SES();
  
  var email_params = {
    Source: sender,
    Destination: {
      ToAddresses: [
        recipient
      ],
    },
    Message: {
      Subject: {
        Data: subject,
        Charset: charset
      },
      Body: {
        Text: {
          Data: body_text,
          Charset: charset
        },
        Html: {
          Data: html_body,
          Charset: charset
        }
      }
    },
    ConfigurationSetName: configuration_set
  };

  ses.sendEmail(email_params, function(err, data) {}); // NOT OK

  // Send Templated Email
  //
  var templated_email_params = {
    Destination: {
      BccAddresses: [
        'STRING_VALUE'
      ],
      CcAddresses: [
        'STRING_VALUE',
      ],
      ToAddresses: [
        'STRING_VALUE',
      ]
    },
    Source: 'STRING_VALUE',
    Template: 'STRING_VALUE',
    TemplateData: '{"data": "' + html_body + '"}',
    ConfigurationSetName: 'STRING_VALUE',
    ReplyToAddresses: [
      'STRING_VALUE',
    ],
    ReturnPath: 'STRING_VALUE',
    ReturnPathArn: 'STRING_VALUE',
    SourceArn: 'STRING_VALUE',
    Tags: [
      {
        Name: 'STRING_VALUE',
        Value: 'STRING_VALUE'
      },
    ],
    TemplateArn: 'STRING_VALUE'
  };
  ses.sendTemplatedEmail(templated_email_params, function(err, data) {}); // NOT OK


  // Send Templated Bulk Email
  //
  var templated_bulk_email_params = {
    Destinations: [
      {
        Destination: {
          BccAddresses: [
            'STRING_VALUE',
          ],
          CcAddresses: [
            'STRING_VALUE',
          ],
          ToAddresses: [
            'STRING_VALUE',
          ]
        },
        ReplacementTags: [
          {
            Name: 'STRING_VALUE',
            Value: 'STRING_VALUE'
          },
        ],
        ReplacementTemplateData: 'STRING_VALUE'
      },
    ],
    Source: 'STRING_VALUE',
    Template: 'STRING_VALUE',
    ConfigurationSetName: 'STRING_VALUE',
    DefaultTags: [
      {
        Name: 'STRING_VALUE',
        Value: 'STRING_VALUE'
      },
    ],
    DefaultTemplateData: '{"data": "' + html_body + '"}',
    ReplacementTemplateData: '{"data": "' + html_body + '"}',
    ReplyToAddresses: [
      'STRING_VALUE',
    ],
    ReturnPath: 'STRING_VALUE',
    ReturnPathArn: 'STRING_VALUE',
    SourceArn: 'STRING_VALUE',
    TemplateArn: 'STRING_VALUE'
  };

  ses.sendBulkTemplatedEmail(templated_bulk_email_params, function(err, data) { }); // NOT OK
});
