const SENDMAIL = require('sendmail');

var sendmail = SENDMAIL();

sendmail({
    from: 'no-reply@yourdomain.com',
    to: 'test@qq.com, test@sohu.com, test@163.com ',
    subject: 'test sendmail',
    html: 'Mail of test sendmail ',
    text: 'Text version of email'
  }, function(err, reply) {
    console.log(err && err.stack);
    console.dir(reply);
});
