@RestResource(urlMapping='/Credit Application Forms/*')

global class SendToDocuSignweb {
    
    global final Credit_Application_Form__c assetal;
    
    global final Attachment attachment;
    global static String envelopeId {get;set;}
    global static String accountId = '73ed93ba-5334-4983-9ba8-1515169d273a';
    global static String userId = 'da3249f7-7f1c-4279-a3d6-989f016889b2';
    global static String password = 'vaibhav939';
    global static string integratorsKey = 'cf12560e-1211-4d73-a374-d8e649d8ae9d';
    global static String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx?op=CreateAndSendEnvelope';
    
    public SendToDocuSignweb(ApexPages.StandardController controller)
    {
        this.assetal = [SELECT Id FROM Credit_Application_Form__c where id = :controller.getRecord().Id  ];
        envelopeId = 'Not sent yet';
        
        //SendNow();
    }
    @HttpPost  
    
    webservice static void SendNow(Id objId)
    {
        String accountName = [SELECT Customer_Name__r.Name FROM Credit_Application_Form__c where id = :objId LIMIT 1].Customer_Name__r.Name;
        system.debug('OBJ ID ---> '+objId);
        DocuSignAPI.APIServiceSoap dsApiSend 
            = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        //Id a = ApexPages.currentPage().getParameters().get('id');
        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        System.debug('Setting authentication to: ' + auth);
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
                                         auth);
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = accountName == null ? 'BOA CreditApplication Form to be Signed ' : 'BOA CreditApplication Form to be Signed ' + accountName;
        envelope.EmailBlurb = 'Please Find the Attachment of BOA Credit Application Form,'+ 
            'This Attachment Needs Digital Signature , ' +
            'Steps To Sign Document  '+
            'Drag and Drop the Signature field to the Document Signature Field ,Date,Name & Drag on the Document';
        envelope.AccountId  = accountId;  
        
        
        // Render the Credit Application Id
        System.debug('Rendering Credit Application Id');
        //PageReference pageRef = new PageReference('/apex/RenderContract');
        //pageRef.getParameters().put('id',opportunity.Id);
        // Blob pdfBlob = pageRef.getContent();     
        Credit_Application_Form__c ab = [SELECT Id, Name , Recipient_1_Email__c ,Recipient_2_Email__c  FROM Credit_Application_Form__c where id = :objId];
        Attachment att = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Parentid = : ab.id ORDER BY LastModifiedDate DESC LIMIT 1];
        Blob pdfBlob = att.Body;
        system.debug(att.body + 'pdfvalue');
        
        
        
        // Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob );
        document.Name = 'BOA CreditApplication Form '+ accountName;
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;
        system.debug('get document');
        // Recipient
        //System.debug('getting the contact');
        //Contact contact = [SELECT email, FirstName, LastName 
        //   from Contact where id = :contract.CustomerSignedId];
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = ab.Recipient_1_Email__c;
        recipient.UserName =  ab.Name;
        system.debug('get recipent 1'+recipient.Email);
        
        DocuSignAPI.Recipient recipient1 = new DocuSignAPI.Recipient();
        recipient.ID = 2;
        recipient.Type_x = 'Signer1';
        recipient.RoutingOrder = 2;
        recipient.Email = ab.Recipient_2_Email__c;
        recipient.UserName =  ab.Name;
        system.debug('get recipent 2'+recipient.Email);

        // This setting seems required or you see the error:
        // "The string '' is not a valid Boolean value. 
        // at System.Xml.XmlConvert.ToBoolean(String s)" 
        recipient.RequireIDLookup = false;      
        
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[1];
        envelope.Recipients.Recipient[0] = recipient;
       envelope.Recipients.Recipient[0] = recipient1;
        system.debug('get envelope');
        
        //recipient.RequireIDLookup = false;      
        
        //envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        //envelope.Recipients.Recipient = new DocuSignAPI.Recipient[2];
        //envelope.Recipients.Recipient[0] = recipient1;
        
        
        // Tab
        /*        .
DocuSignAPI.Tab tab1 = new DocuSignAPI.Tab();
tab1.Type_x = 'SignHere';
tab1.RecipientID = 1;
tab1.DocumentID = 1;
tab1.AnchorTabItem = new DocuSignAPI.AnchorTab();
tab1.AnchorTabItem.AnchorTabString = 'By:';


DocuSignAPI.Tab tab2 = new DocuSignAPI.Tab();
tab2.Type_x = 'DateSigned';
tab2.RecipientID = 1;
tab2.DocumentID = 1;
tab2.AnchorTabItem = new DocuSignAPI.AnchorTab();
tab2.AnchorTabItem.AnchorTabString = 'Date Signed:';

envelope.Tabs = new DocuSignAPI.ArrayOfTab();
envelope.Tabs.Tab = new DocuSignAPI.Tab[2];
envelope.Tabs.Tab[0] = tab1;        
envelope.Tabs.Tab[1] = tab2;        
*/
        System.debug('Calling the API');
        try {
            DocuSignAPI.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
            envelopeId = es.EnvelopeID;
        } catch ( CalloutException e) {
            System.debug('Exception - ' + e );
            envelopeId = 'Exception - ' + e;
            
        }
        System.debug(' ** response ** : ' + envelope ); 
        
    }
}