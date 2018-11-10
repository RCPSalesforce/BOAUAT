public class SendEmailwithAttachmentController {

    @AuraEnabled 
    public static string sendMailMethod(String mMail ,String mCc ,String mSubject ,String mbody, Id recordId, list<string> selectedAttchIds){
        string message = '';
        try{  
        system.debug('RecId APEX -- '+recordId+' -- selectedAttchIds -- '+selectedAttchIds);
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo = mMail.split(';');
        
        mail.setToAddresses(sendTo);
        
        // Step 3: Set list of people who should get the email
        if(string.isNotBlank(mCc)){
        	List<String> sendToCc = mCc.split(';');
        	
        	mail.setCCAddresses(sendToCc);    
        }
        
        
        // Step 3: Set who the email is sent from
        //mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
        //mail.setSenderDisplayName('Invoice Admin'); 
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        if(!selectedAttchIds.isEmpty()){
            for (Attachment a : [select Name, Body, BodyLength from Attachment where Id = :selectedAttchIds ORDER BY CreatedDate])
            {
                system.debug('List of attachment -->'+a);
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(a.Name);
                efa.setBody(a.Body);
                fileAttachments.add(efa);
                system.debug('File Attachments -->'+fileAttachments);
            }
            mail.setFileAttachments(fileAttachments);
        }
        // Step 5. Add your email to the master list
        mails.add(mail);
        
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
            
       //step 7: return message
       message = 'Email Sent successfully.';
       return message;     
      }catch(exception e){
      	  message = 'Something went wrong while sending this message - '+e.getMessage();
          errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'SendEmailwithAttachmentController.sendMailMethod',e.getLineNumber());          
          return message;
      }      
    }
    
    @AuraEnabled
    public static string getAttachments(String recordId){
        list<attachment> attachmentList = [select id,name from attachment where parentId =: recordId order by createddate desc];
        list<optionsWrapper> options = new list<optionsWrapper>();
        for(attachment a: attachmentList){
            optionsWrapper option = new optionsWrapper();
            option.label = a.name;
            option.value = a.Id;
            options.add(option);
        }
        system.debug('options--'+options);
        return json.serialize(options);
        //return options;
    }
    
    public class optionsWrapper{
        public string label;
        public string value;
    }
}