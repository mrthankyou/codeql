import javascript

/**
 * An operation that sends an email.
 */
abstract class EmailSender extends DataFlow::SourceNode {
  /**
   * Gets a data flow node holding the plaintext version of the email body.
   */
  abstract DataFlow::Node getPlainTextBody();

  /**
   * Gets a data flow node holding the HTML body of the email.
   */
  abstract DataFlow::Node getHtmlBody();

  /**
   * Gets a data flow node holding the address of the email recipient(s).
   */
  abstract DataFlow::Node getTo();

  /**
   * Gets a data flow node holding the address of the email sender.
   */
  abstract DataFlow::Node getFrom();

  /**
   * Gets a data flow node holding the email subject.
   */
  abstract DataFlow::Node getSubject();

  /**
   * Gets a data flow node that refers to the HTML body or plaintext body of the email.
   */
  DataFlow::Node getABody() {
    result = getPlainTextBody() or
    result = getHtmlBody()
  }
}

/**
 * An email-sending call based on the `nodemailer` package.
 */
private class NodemailerEmailSender extends EmailSender, DataFlow::MethodCallNode {
  NodemailerEmailSender() {
    this =
      DataFlow::moduleMember("nodemailer", "createTransport").getACall().getAMethodCall("sendMail")
  }

  override DataFlow::Node getPlainTextBody() { result = getOptionArgument(0, "text") }

  override DataFlow::Node getHtmlBody() { result = getOptionArgument(0, "html") }

  override DataFlow::Node getTo() { result = getOptionArgument(0, "to") }

  override DataFlow::Node getFrom() { result = getOptionArgument(0, "from") }

  override DataFlow::Node getSubject() { result = getOptionArgument(0, "subject") }
}

/**
 * An email-sending call based on the `aws-sdk-v2` package.
 */
private class AmazonSESV2EmailSender extends EmailSender, DataFlow::MethodCallNode {
  AmazonSESV2EmailSender() {
    this =
      API::moduleImport("aws-sdk")
          .getMember("SES")
          .getReturn()
          .getMember(["sendEmail", "sendTemplatedEmail", "sendBulkTemplatedEmail"])
          .getACall()
          .(DataFlow::MethodCallNode)
  }

  override DataFlow::Node getPlainTextBody() {
    result =
      getOptionArgument(0, "Message")
          .(SourceNode)
          .getAPropertyWrite("Body")
          .getRhs()
          .(SourceNode)
          .getAPropertyWrite("Text")
          .getRhs()
          .(SourceNode)
          .getAPropertyWrite("Data")
          .getRhs()
  }

  override DataFlow::Node getHtmlBody() {
    result =
      getOptionArgument(0, "Message")
          .(SourceNode)
          .getAPropertyWrite("Body")
          .getRhs()
          .(SourceNode)
          .getAPropertyWrite("Html")
          .getRhs()
          .(SourceNode)
          .getAPropertyWrite("Data")
          .getRhs() or
    result = getOptionArgument(0, "TemplateData") or
    result = getOptionArgument(0, "DefaultTemplateData") or
    result = getOptionArgument(0, "ReplacementTemplateData")
  }

  override DataFlow::Node getTo() {
    result =
      getOptionArgument(0, "Destination").(SourceNode).getAPropertyWrite("ToAddresses").getRhs() or
    result =
      getOptionArgument(0, "Destinations")
          .(ArrayLiteralNode)
          .getAnElement()
          .(SourceNode)
          .getAPropertyWrite("Destination")
          .getRhs()
          .(SourceNode)
          .getAPropertyWrite("ToAddresses")
          .getRhs()
  }

  override DataFlow::Node getFrom() { result = getOptionArgument(0, "Source") }

  override DataFlow::Node getSubject() {
    result =
      getOptionArgument(0, "Message")
          .(SourceNode)
          .getAPropertyWrite("Subject")
          .getRhs()
          .(SourceNode)
          .getAPropertyWrite("Data")
          .getRhs()
  }
}


/**
 * An email-sending call based on the `aws-sdk-v3` package.
 */
private class AmazonSESV3EmailSender extends EmailSender, DataFlow::MethodCallNode {
  AmazonSESV3EmailSender() {
    this =
      DataFlow::moduleMember("@aws-sdk/client-ses", "SESClient")
          .getAnInvocation()
          .getAMemberCall("send")
          .(DataFlow::MethodCallNode)
  }

  override DataFlow::Node getPlainTextBody() {
    exists(InvokeNode emailCommand |
      emailCommand =
        DataFlow::moduleMember("@aws-sdk/client-ses",
          ["SendEmailCommand", "SendTemplatedEmailCommand", "SendBulkTemplatedEmailCommand"])
            .getAnInvocation() and
      this.getArgument(0) = emailCommand and
      result =
        emailCommand
            .getOptionArgument(0, "Message")
            .(SourceNode)
            .getAPropertyWrite("Body")
            .getRhs()
            .(SourceNode)
            .getAPropertyWrite("Text")
            .getRhs()
            .(SourceNode)
            .getAPropertyWrite("Data")
            .getRhs()
    )
  }

  override DataFlow::Node getHtmlBody() {
    exists(InvokeNode emailCommand |
      emailCommand =
        DataFlow::moduleMember("@aws-sdk/client-ses",
          ["SendEmailCommand", "SendTemplatedEmailCommand", "SendBulkTemplatedEmailCommand"])
            .getAnInvocation() and
      this.getArgument(0) = emailCommand and
      result =
        emailCommand
            .getOptionArgument(0, "Message")
            .(SourceNode)
            .getAPropertyWrite("Body")
            .getRhs()
            .(SourceNode)
            .getAPropertyWrite("Html")
            .getRhs()
            .(SourceNode)
            .getAPropertyWrite("Data")
            .getRhs()
      or
      result = emailCommand.getOptionArgument(0, "TemplateData")
      or
      result = emailCommand.getOptionArgument(0, "DefaultTemplateData")
      or
      result = emailCommand.getOptionArgument(0, "ReplacementTemplateData")
    )
  }

  override DataFlow::Node getTo() {
    exists(InvokeNode emailCommand |
      emailCommand =
        DataFlow::moduleMember("@aws-sdk/client-ses",
          ["SendEmailCommand", "SendTemplatedEmailCommand", "SendBulkTemplatedEmailCommand"])
            .getAnInvocation() and
      this.getArgument(0) = emailCommand and
      result =
        emailCommand
            .getOptionArgument(0, "Destination")
            .(SourceNode)
            .getAPropertyWrite("ToAddresses")
            .getRhs()
      or
      result =
        emailCommand
            .getOptionArgument(0, "Destinations")
            .(ArrayLiteralNode)
            .getAnElement()
            .(SourceNode)
            .getAPropertyWrite("Destination")
            .getRhs()
            .(SourceNode)
            .getAPropertyWrite("ToAddresses")
            .getRhs()
    )
  }

  override DataFlow::Node getFrom() {
    exists(InvokeNode emailCommand |
      emailCommand =
        DataFlow::moduleMember("@aws-sdk/client-ses",
          ["SendEmailCommand", "SendTemplatedEmailCommand", "SendBulkTemplatedEmailCommand"])
            .getAnInvocation() and
      this.getArgument(0) = emailCommand and
      result = emailCommand.getOptionArgument(0, "Source")
    )
  }

  override DataFlow::Node getSubject() {
    exists(InvokeNode emailCommand |
      emailCommand =
        DataFlow::moduleMember("@aws-sdk/client-ses",
          ["SendEmailCommand", "SendTemplatedEmailCommand", "SendBulkTemplatedEmailCommand"])
            .getAnInvocation() and
      this.getArgument(0) = emailCommand and
      result =
        emailCommand
            .getOptionArgument(0, "Message")
            .(SourceNode)
            .getAPropertyWrite("Subject")
            .getRhs()
    )
  }
}

/**
 * An email-sending call based on the `emailjs` package.
 */
 private class EmailJSEmailSender extends EmailSender, DataFlow::MethodCallNode {
   EmailJSEmailSender() {
     this =
       DataFlow::moduleMember("emailjs", "SMTPClient")
           .getAnInvocation()
           .getAMemberCall(["send", "sendAsync"])
   }

   override DataFlow::Node getPlainTextBody() {
     result = getOptionArgument(0, "text")
     or
     result = getMessageModelAttributeValue("text")
   }

   override DataFlow::Node getHtmlBody() {
     exists(DataFlow::Node attachment |
       attachment = getArgument(0).(SourceNode).getAPropertyWrite("attachment").getRhs() and
       (
         result =
           attachment
               .(DataFlow::ArrayLiteralNode)
               .getAnElement()
               .(SourceNode)
               .getAPropertyWrite("data")
               .getRhs() or
         result = attachment.(SourceNode).getAPropertyWrite("data").getRhs()
       )
     )
     or
     result =
       getMessageModelAttributeValue("attachment")
           .(DataFlow::ArrayLiteralNode)
           .getAnElement()
           .(SourceNode)
           .getAPropertyWrite("data")
           .getRhs()
     or
     result =
       getMessageModelAttributeValue("attachment").(SourceNode).getAPropertyWrite("data").getRhs()
     or
     // Finds cases where Message#attach is used to attach the html and with the message model eventually passed to the sink
     exists(API::Node messageNode, DataFlow::MethodCallNode attachCall |
       messageNode = API::moduleImport("emailjs").getMember("Message") and
       messageNode.getReturn().getAUse() = getArgument(0) and
       attachCall.getCalleeName() = "attach" and
       result = attachCall.getArgument(0).(SourceNode).getAPropertyWrite("data").getRhs() and
       messageNode.getReturn().getAUse() = attachCall.getReceiver()
     )
   }

   override DataFlow::Node getTo() {
     result = getOptionArgument(0, "to")
     or
     result = getMessageModelAttributeValue("to")
   }

   override DataFlow::Node getFrom() {
     result = getOptionArgument(0, "from")
     or
     result = getMessageModelAttributeValue("from")
   }

   override DataFlow::Node getSubject() {
     result = getOptionArgument(0, "subject")
     or
     result = getMessageModelAttributeValue("subject")
   }

   DataFlow::Node getMessageModelAttributeValue(string propertyName) {
     exists(API::Node messageNode, DataFlow::Node messageInvocationArgument |
       messageNode = API::moduleImport("emailjs").getMember("Message") and
       messageNode.getReturn().getAUse() = getArgument(0) and
       messageInvocationArgument = messageNode.getAnInvocation().getParameter(0).getInducingNode() and
       (
         result = messageInvocationArgument.(SourceNode).getAPropertyWrite(propertyName).getRhs() or
         result = messageInvocationArgument.(SourceNode).getAPropertyWrite(propertyName).getRhs()
       )
     )
   }
 }


/**
* An email-sending call based on the `sendgrid` package.
*/

private class SendGridEmailSender extends EmailSender, DataFlow::MethodCallNode {
  SendGridEmailSender() {
    this =
      DataFlow::moduleMember("@sendgrid/mail", ["send", "sendMultiple"])
          .getACall()
          .(DataFlow::MethodCallNode)
  }

  override DataFlow::Node getPlainTextBody() { result = getOptionArgument(0, "text") }

  override DataFlow::Node getHtmlBody() { result = getOptionArgument(0, "html") }

  override DataFlow::Node getTo() { result = getOptionArgument(0, "to") }

  override DataFlow::Node getFrom() { result = getOptionArgument(0, "from") }

  override DataFlow::Node getSubject() { result = getOptionArgument(0, "subject") }
}


/**
* An email-sending call based on the `node-sendmail` package.
*/
private class NodeSendMailEmailSender extends EmailSender, DataFlow::CallNode {
  NodeSendMailEmailSender() {
    this = DataFlow::moduleImport("sendmail").getAnInvocation().getACall()
  }

  override DataFlow::Node getPlainTextBody() { result = getOptionArgument(0, "text") }

  override DataFlow::Node getHtmlBody() { result = getOptionArgument(0, "html") }

  override DataFlow::Node getTo() { result = getOptionArgument(0, "to") }

  override DataFlow::Node getFrom() { result = getOptionArgument(0, "from") }

  override DataFlow::Node getSubject() { result = getOptionArgument(0, "subject") }
}
