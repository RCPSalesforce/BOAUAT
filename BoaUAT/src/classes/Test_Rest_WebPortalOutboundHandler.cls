@isTest
public class Test_Rest_WebPortalOutboundHandler {
	
    public static testMethod void unitTest(){
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        delivery_Address__c da = new Delivery_Address__c();
        da.Customers__c = a.Id;
        da.Postal_Code__c = '1022';
        insert da;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'Last Name';
        insert c;
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.QuantityUnitOfMeasure__c = 'PACK';
        p.is_Hydraulic_Product__c = true;
        p.Bill_of_Material__c = false;
        insert p;
        
        Pricebook2 pb = new PriceBook2();
        pb.Name = 'Standard PriceBook';
        pb.IsActive = true;
        pb.CurrencyIsoCode = 'NZD';
        //pb.IsStandard = true;
        insert pb;

		String standardPricebookId = Test.getStandardPricebookId();

        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Pricebook2Id = standardPricebookId;
        //pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id = p.Id;
        pbe.UnitPrice = 20.50;
        pbe.Standard_Cost__c = 10.10;
        //pbe.UseStandardPrice = false;        
        pbe.IsActive = true;
        pbe.CurrencyIsoCode = 'NZD';
        insert pbe; 
        
        PriceBookEntry customPriceBookEntry = new PriceBookEntry();
        customPriceBookEntry.Product2Id=p.Id;
        customPriceBookEntry.Pricebook2Id=pb.Id;
        customPriceBookEntry.UnitPrice=5000;
        customPriceBookEntry.IsActive=true;
        insert customPriceBookEntry;
        
        List<Id> conIds = new List<Id>();
        conIds.add(c.Id);
        List<Id> prodIds = new List<Id>();
        prodIds.add(p.Id);
        
        web_portal_creds__c cred = new web_portal_creds__c();
        cred.Name = 'email';
        cred.Value__c = 'salesforce.integration@centelon.com';
        insert cred;
        
        web_portal_creds__c cred1 = new web_portal_creds__c();
        cred1.Name = 'endpoint';
        cred1.Value__c = 'https://dev-portal-api.boa.co.nz';
        insert cred1;
        
        web_portal_creds__c cred2 = new web_portal_creds__c();
        cred2.Name = 'password';
        cred2.Value__c = 'Password@123';
        insert cred2;
        
        web_portal_creds__c cred3 = new web_portal_creds__c();
        cred3.Name = 'x-api-key';
        cred3.Value__c = 'boatestappkey';
        insert cred3;
        
        session_Tokens__c st = new session_Tokens__c();
        st.Name = 'web_portal';
        st.token__c = 'yrYAhSJ29rSEIMU08Qv36ZsBV3GU4bBW';
        insert st;
        
        Rest_WebPortalOutboundHandler.SendContactupdatesToPortal(conIds);
        Rest_WebPortalOutboundHandler.sendProductDetailsToPortal(prodIds);
    }
}