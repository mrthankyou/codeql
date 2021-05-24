import { SMTPClient, SMTPConnection, Message } from 'emailjs';
var http = require("http"),
    url = require("url");

var server = http.createServer(function(req, res) {
	var html_body = req.url;

  const smtp_connection = new SMTPConnection({
  	user: 'user',
  	password: 'password',
  	ssl: false,
  	tls: false,
  	authentication: ['PLAIN'],
  })

	const client = new SMTPClient({
		user: 'user',
		password: 'password',
		host: 'smtp.your-email.com',
		ssl: true,
	});

	const message = {
		text: 'i hope this works',
		from: 'you <username@your-email.com>',
		to: 'someone <someone@your-email.com>, another <another@your-email.com>',
		cc: 'else <else@your-email.com>',
		subject: 'testing emailjs',
		attachment: { data: html_body, alternative: true }
	};

  const message_with_attachment_array = {
    text: 'i hope this works',
    from: 'you <username@your-email.com>',
    to: 'someone <someone@your-email.com>, another <another@your-email.com>',
    cc: 'else <else@your-email.com>',
    subject: 'testing emailjs',
    attachment: [
      { data: html_body, alternative: true }
    ]
  };


  const message_model = new Message({
    text: 'i hope this works',
    from: 'you <username@outlook.com>',
    to: 'someone <someone@your-email.com>, another <another@your-email.com>',
    cc: 'else <else@your-email.com>',
    subject: 'testing emailjs'
  });

  const message_model_with_initialized_attachment = new Message({
    text: 'i hope this works',
    from: 'you <username@outlook.com>',
    to: 'someone <someone@your-email.com>, another <another@your-email.com>',
    cc: 'else <else@your-email.com>',
    subject: 'testing emailjs',
    attachment: { data: html_body, alternative: true }
  });

  message_model.attach({ data: html_body, alternative: true })

	client.send(message, function (err, message) { }); // NOT OK
	client.send(message_with_attachment_array, function (err, message) { }); // NOT OK
  client.sendAsync(message); // NOT OK
  smtp_connection.send(message, function (err, message) { }); // NOT OK
  client.send(message_model, function (err, message) { }); // NOT OK
  client.send(message_model_with_initialized_attachment, function (err, message) { }); // NOT OK
});
