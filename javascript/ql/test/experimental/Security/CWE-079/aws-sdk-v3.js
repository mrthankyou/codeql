import {
  SendEmailCommand
  SendTemplatedEmailCommand
  SendBulkTemplatedEmailCommand,
  SESClient
} from "@aws-sdk/client-ses";

const REGION = "eu-west-1";
const sesClient = new SESClient({ region: REGION });

// Send Email
//
const email_params = {
  Destination: {
    ToAddresses: [
      "RECEIVER_ADDRESS",
    ],
  },
  Message: {
    Body: {
      Html: {
        Charset: "UTF-8",
        Data: "HTML_FORMAT_BODY",
      },
      Text: {
        Charset: "UTF-8",
        Data: "TEXT_FORMAT_BODY",
      },
    },
    Subject: {
      Charset: "UTF-8",
      Data: "EMAIL_SUBJECT",
    },
  },
  Source: "SENDER_ADDRESS"
};


const run = async () => {
  try {
    const data = await sesClient.send(new SendEmailCommand(email_params));
    return data;
  } catch (err) { }
};

run();

// Send Templated Email
//
const templated_email_params = {
  Destination: {
    ToAddresses: [
      "RECEIVER_ADDRESS"
    ],
  },
  Source: "SENDER_ADDRESS",
  Template: "TEMPLATE_NAME",
  TemplateData: '{ "REPLACEMENT_TAG_NAME":"' + html_body + '" }',
  ReplyToAddresses: [],
};

const run = async () => {
  try {
    const data = await sesClient.send(new SendTemplatedEmailCommand(templated_email_params));
    return data;
  } catch (err) { }
};
run();


// Send Templated Bulk Email
//
var templated_bulk_email_params = {
  Destinations: [
    {
      Destination: {
        CcAddresses: [
          "RECEIVER_ADDRESSES",
        ],
      },
      ReplacementTemplateData: '{ "REPLACEMENT_TAG_NAME":"REPLACEMENT_VALUE" }',
    },
  ],
  Source: "SENDER_ADDRESS",
  Template: "TEMPLATE",
  DefaultTemplateData: '{ "REPLACEMENT_TAG_NAME":"' + html_body + '" }',
  ReplyToAddresses: [],
};

const run = async () => {
  try {
    const data = await sesClient.send(new SendBulkTemplatedEmailCommand(templated_bulk_email_params));
    console.log("Success.", data);
    return data; // For unit tests.
  } catch (err) {
    console.log("Error", err.stack);
  }
};
run();
