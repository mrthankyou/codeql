var http = require("http"),
    url = require("url"),
    sgMail = require('@sendgrid/mail');

var server = http.createServer(function(req, res) {
	var html_body = req.url;

  sgMail.setApiKey(process.env.SENDGRID_API_KEY);
  const msg = {
    to: 'test@example.com',
    from: 'test@example.com', // Use the email address or domain you verified above
    subject: 'Sending with Twilio SendGrid is Fun',
    text: 'and easy to do anywhere, even with Node.js',
    html: html_body,
  };
  const multiple_recipients_email = {
    to: ['recipient1@example.org', 'recipient2@example.org'],
    from: 'sender@example.org',
    subject: 'Hello world',
    text: 'Hello plain world!',
    html: html_body,
  };

  sgMail.send(msg); // NOT OK
  sgMail.sendMultiple(msg); // NOT OK
});
