@isTest 
public class TestRest_WebPortal {
    public static testMethod void testGetMethod(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
         
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        request.requestUri ='/services/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createSignup');
        request.addParameter('accountid',acc.Id);
        //request.addParameter('typeOfCustomer', 'Retail Customer');
        request.httpMethod = 'GET';
        Rest_WebPortal.inboundGetRequest();
            
    }
    @isTest(SeeAllData=true)
    public static void testPostMethod(){
        
        account acc = new account(Name = 'Test Name');
        acc.BillingStreet = 'Street';
        acc.BillingCity = 'City';
        acc.BillingCountry = 'Country';
		acc.BillingState = 'State';
        acc.BillingPostalCode = '411027';
		acc.CurrencyIsoCode = 'NZD';        
        insert acc;
        
        account personacc = new account();
        personacc.LastName = 'Test';
        personacc.BillingCity = 'City';
        personacc.BillingCountry = 'Country';
		personacc.BillingState = 'State';
        personacc.BillingPostalCode = '411027'; 
        personacc.RecordTypeId = '0120l000000C6Gf';
        insert personacc;
        
        Contact c = new Contact();
        c.FirstName = 'Name';
        c.LastName = 'Contact Name';
        c.AccountId = acc.Id;
        c.MailingStreet = 'Street';
        c.MailingCity = 'City';
        c.MailingCountry = 'Country';
		c.MailingState = 'State';
        c.MailingPostalCode = '411027';
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.CloseDate = system.today() + 30;
        opp.StageName = 'Prospecting';
        
        insert opp;
        
        Product2 prod = new Product2();
        prod.Name = 'Product 1';
        prod.QuantityUnitOfMeasure__c = 'ASSEMBLY';
		prod.Bill_of_Material__c = true;        
        insert prod;
        
        /*Product2 pBOM = new Product2();
        pBOM.Name = 'Y204_104B_0_104B_0_1041.4';
        pBOM.Bill_of_Material__c = true;
        pBom.BOM_Code_Name__c = 'YKR2SN-04_1,K001-0808_1,K001-1616_1';
        insert pBOM;*/
        
        Pricebook2 pb = new PriceBook2();
        pb.Name = 'Standard PriceBook';
        pb.IsActive = true;
        //pb.IsStandard = true;
        insert pb;
        
        String standardPricebookId = Test.getStandardPricebookId();

        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Pricebook2Id = standardPricebookId;
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 20.50;
        pbe.Standard_Cost__c = 10.10;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        insert pbe;       
        
        
        	OpportunityLineItem lineItem = new OpportunityLineItem();
        	lineItem.OpportunityId = opp.Id;
        	lineItem.PricebookEntryId = pbe.Id;
        	lineItem.Quantity = 10;
        	lineItem.TotalPrice = 200; 
            
        insert lineItem;
        
        Delivery_address__c add = new Delivery_address__c();
        add.Customers__c = acc.id;
        add.Postal_Code__c = '411005';
        add.Street__c = 'Street';
        add.Is_Primary__c = true;
        insert add;
        
        Lead l = new Lead();
        l.lastName = 'Test Name';
        l.company = 'Company';
        l.email = 'test@test2.com';
        l.Number_of_Times_Lead_Visited__c = 3;
        insert l;
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        oppLineItemList.add(lineItem);
        Rest_WebPortalWrappers.signupInformation cs = new Rest_WebPortalWrappers.signupInformation();
        Rest_WebPortalWrappers.creditAformInformation caf = new Rest_WebPortalWrappers.creditAformInformation();        
        Rest_WebPortalWrappers.orderInfo ord = new Rest_WebPortalWrappers.orderInfo();
        Rest_WebPortalWrappers.orderProducts ordProd1 = new Rest_WebPortalWrappers.orderProducts();
        Rest_WebPortalWrappers.orderProducts ordProd2 = new Rest_WebPortalWrappers.orderProducts();
        List<Rest_WebPortalWrappers.orderProducts> ordProdList = new List<Rest_WebPortalWrappers.orderProducts>();
        Rest_WebPortalWrappers.deliveryAddressInfo delAdd = new Rest_WebPortalWrappers.deliveryAddressInfo();
        Rest_WebPortalWrappers.delAddressInfoUpdate updateDelAdd = new Rest_WebPortalWrappers.delAddressInfoUpdate();
        Rest_WebPortalWrappers.addressWrapper addWrap = new Rest_WebPortalWrappers.addressWrapper();
        Rest_WebPortalWrappers.LeadTask lTask = new Rest_WebPortalWrappers.LeadTask();
        Rest_WebPortalWrappers.leadInfo lInfo = new Rest_WebPortalWrappers.leadInfo();      
        Rest_WebPortalWrappers.bomProducts bp = new Rest_WebPortalWrappers.bomProducts();
        List<Rest_WebPortalWrappers.bomProducts> bpList = new List<Rest_WebPortalWrappers.bomProducts>();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        
        //CreateLead Task
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createLeadTask');
        request.requestBody = blob.valueOf(JSON.serialize(cs));        
       
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        //SignupInfo
        
        addWrap.city = 'city';
        addWrap.country = 'country';
        addWrap.postalCode = '411027';
        addWrap.state = 'state';
        addWrap.street = 'street';
        //pAddress.isPrimary = true;
        cs.postalAddress = addWrap;
        cs.deliveryAddress = addWrap;
        
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createSignup');
        request.requestBody = blob.valueOf(JSON.serialize(cs));        
       
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        //CAF form
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createCAForm');
        request.requestBody = blob.valueOf(JSON.serialize(caf));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        //PriceBook2 standardPB = new PriceBook2(Id= Test.getStandardPricebookId(),isActive = true);
        //update standardPB; 
        //Create Order
        ord.billOfMaterial = true;
        ord.customerCurrency = acc.CurrencyIsoCode;
        ordProd1.lineitemdescription = 'Test Description';
        ordProd1.quantity = 30;
        ordProd1.salesprice = 25;
        ordProd1.stockCode = prod.Name;
            
        ordProdList.add(ordProd1);
        ord.orderProductsWrap = ordProdList;
        
        /*ordProd2.lineitemdescription = 'Test Description1';
        ordProd2.quantity = 30;
        ordProd2.salesprice = 25;
        ordProd2.stockCode = prod.Id;
        ordProdList.add(ordProd2);        
        ord.orderProductsWrap = ordProdList;*/
        
        bp.stockCode = 'Y204_104B_0_104B_0_1041.4';
        bp.stockCodewithQuantity = '';
        bp.lineItemDescription = 'test';
        bp.makeAtBoa = false;
        bp.quantity = 1;
        bp.salesprice = 20.20;
        bp.spiral = false;
        bp.totalPrice = 12.12;
        bpList.add(bp);
        ord.bomProducts = bpList;
        
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createOrder');
        request.requestBody = blob.valueOf(JSON.serialize(ord));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        //update order
        ord.salesforceId = opp.Id;
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','updateOrder');
        request.requestBody = blob.valueOf(JSON.serialize(ord));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        //Update delivery address
        updateDelAdd.deliveryAddressId = add.Id;      
        addWrap.city = 'city';
        addWrap.country = 'country';
        addWrap.postalCode = '411027';
        addWrap.state = 'state';
        addWrap.street = 'street';
        addWrap.isPrimary = true;
        updateDelAdd.deliveryAddress = addWrap;
        
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','updateAddress');
        request.requestBody = blob.valueOf(JSON.serialize(updateDelAdd));
        
        request.httpMethod = 'POST';        
        Rest_WebPortal.inboundPostRequest();
        
        
        //delete delivery address
        delAdd.deliveryAddressId = add.id;
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','deleteAddress');
        request.requestBody = blob.valueOf(JSON.serialize(delAdd));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        
        
        //Update Lead
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createLead');
        request.requestBody = blob.valueOf(JSON.serialize(lInfo));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();

		//Enterprise Account
        cs.typeOfCustomer = 'Enterprise Customer';
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createSignup');
        request.requestBody = blob.valueOf(JSON.serialize(cs));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest(); 
        
        //Update Contact
        cs.typeOfCustomer = 'enterprise';
        cs.contactId = c.Id;
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','updateContact');
        request.requestBody = blob.valueOf(JSON.serialize(cs));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
         //Update Contact retail
        cs.typeOfCustomer = 'retail';
        cs.contactId = personacc.Id;
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','updateContact');
        request.requestBody = blob.valueOf(JSON.serialize(cs));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
    }
    
    public static testMethod void testPostMethodTwo(){
        
        Lead l = new Lead();
        l.Company = 'Company';
        l.LastName = 'name';
        l.Email = 'test@test1.com';
        insert l;
        
        /*Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.CloseDate = system.today() + 30;
        opp.StageName = 'Prospecting';
        
        insert opp;
        
        Product2 prod = new Product2();
        prod.Name = 'Product 1';
        prod.QuantityUnitOfMeasure__c = 'ASSEMBLY';
		prod.Bill_of_Material__c = true;        
        insert prod;
        
        Pricebook2 pb = new PriceBook2();
        pb.Name = 'Standard PriceBook';
        pb.IsActive = true;
        //pb.IsStandard = true;
        insert pb;
        
        String standardPricebookId = Test.getStandardPricebookId();

        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Pricebook2Id = standardPricebookId;
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 20.50;
        pbe.Standard_Cost__c = 10.10;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        insert pbe;       
        
        
        	OpportunityLineItem lineItem = new OpportunityLineItem();
        	lineItem.OpportunityId = opp.Id;
        	lineItem.PricebookEntryId = pbe.Id;
        	lineItem.Quantity = 10;
        	lineItem.TotalPrice = 200; 
            
        insert lineItem;
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        oppLineItemList.add(lineItem);*/
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        //Rest_WebPortalWrappers.signupInformation cs = new Rest_WebPortalWrappers.signupInformation();
        Rest_WebPortalWrappers.leadInfo lInfo = new Rest_WebPortalWrappers.leadInfo();
        //Rest_WebPortalWrappers.delAddressInfoUpdate updateDelAdd = new Rest_WebPortalWrappers.delAddressInfoUpdate();
        //Rest_WebPortalWrappers.addressWrapper addWrap = new Rest_WebPortalWrappers.addressWrapper();
        //Rest_WebPortalWrappers.orderInfo ord = new Rest_WebPortalWrappers.orderInfo();
        //Rest_WebPortalWrappers.orderProducts ordProd1 = new Rest_WebPortalWrappers.orderProducts();
        //Rest_WebPortalWrappers.orderProducts ordProd2 = new Rest_WebPortalWrappers.orderProducts();
        //List<Rest_WebPortalWrappers.orderProducts> ordProdList = new List<Rest_WebPortalWrappers.orderProducts>();
        //Rest_WebPortalWrappers.deliveryAddressInfo delAdd = new Rest_WebPortalWrappers.deliveryAddressInfo();
        //Rest_WebPortalWrappers.delAddressInfoUpdate updateDelAdd = new Rest_WebPortalWrappers.delAddressInfoUpdate();
        //Rest_WebPortalWrappers.addressWrapper addWrap = new Rest_WebPortalWrappers.addressWrapper();
        //Rest_WebPortalWrappers.LeadTask lTask = new Rest_WebPortalWrappers.LeadTask();
        //Rest_WebPortalWrappers.leadInfo lInfo = new Rest_WebPortalWrappers.leadInfo();      
        //Rest_WebPortalWrappers.bomProducts bp = new Rest_WebPortalWrappers.bomProducts();
        //List<Rest_WebPortalWrappers.bomProducts> bpList = new List<Rest_WebPortalWrappers.bomProducts>();
        lInfo.email = 'abc@abc.com';
        
        /*//Person Account
        cs.typeOfCustomer = 'Retail Customer';
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createSignup');
        request.requestBody = blob.valueOf(JSON.serialize(cs));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();*/
        
        //Insert Lead
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createLead');
        request.requestBody = blob.valueOf(JSON.serialize(lInfo));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        /*Account acc = new Account();
        acc.Name = 'Test Name';
        insert acc;
        
        Delivery_address__c add = new Delivery_address__c();
        add.Customers__c = acc.id;
        add.Postal_Code__c = '411005';
        add.Street__c = 'Street';
        add.Is_Primary__c = true;
        insert add;
        
        //Update delivery address
        //updateDelAdd.deladdId = add.Id;      
        addWrap.city = 'city';
        addWrap.country = 'country';
        addWrap.postalCode = '411027';
        addWrap.state = 'state';
        addWrap.street = 'street';
        addWrap.isPrimary = true;
        updateDelAdd.deliveryAddress = addWrap;
        updateDelAdd.customerId = acc.Id;
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','updateAddress');
        request.requestBody = blob.valueOf(JSON.serialize(updateDelAdd));
        
        request.httpMethod = 'POST';  
        CustomerController.responseWrapper resWrap = new CustomerController.responseWrapper();
        resWrap.isSuccess = true;
        Rest_WebPortal.inboundPostRequest();
        
         //Create Order
        ord.billOfMaterial = true;
        ord.customerCurrency = acc.CurrencyIsoCode;
        ordProd1.lineitemdescription = 'Test Description';
        ordProd1.quantity = 30;
        ordProd1.salesprice = 25;
        ordProd1.stockCode = prod.Name;
            
        ordProdList.add(ordProd1);
        ord.orderProductsWrap = ordProdList;
        
        /ordProd2.lineitemdescription = 'Test Description1';
        ordProd2.quantity = 30;
        ordProd2.salesprice = 25;
        ordProd2.stockCode = prod.Id;
        ordProdList.add(ordProd2);        
        ord.orderProductsWrap = ordProdList;
        
        bp.stockCode = 'Y204_104B_0_104B_0_1041.4';
        bp.stockCodewithQuantity = '';
        bp.lineItemDescription = 'test';
        bp.makeAtBoa = false;
        bp.quantity = 1;
        bp.salesprice = 20.20;
        bp.spiral = false;
        bp.totalPrice = 12.12;
        bpList.add(bp);
        ord.bomProducts = bpList;
        
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createOrder');
        request.requestBody = blob.valueOf(JSON.serialize(ord));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();*/
       
    }
    
    public static testMethod void negativeTest(){
    	
        Account acc = new Account();
        acc.Name = 'Test name';
        insert acc;
        
        Lead l = new Lead();
        
        Delivery_address__c deladdObj = new Delivery_address__c();
        deladdObj.Customers__c = acc.Id;
        deladdObj.Postal_Code__c = '411027';
        // insert deladdObj;
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        Rest_WebPortalWrappers.leadInfo lInfo = new Rest_WebPortalWrappers.leadInfo();
        Rest_WebPortalWrappers.deliveryAddressInfo delAdd = new Rest_WebPortalWrappers.deliveryAddressInfo();
        Rest_WebPortalWrappers.delAddressInfoUpdate updateDelAdd = new Rest_WebPortalWrappers.delAddressInfoUpdate();
        
        //Lead catchblock
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','createLead');
        request.requestBody = blob.valueOf(JSON.serialize(lInfo));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        
        //delete delivery address
        //delAdd.addressid = add.id;
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','deleteAddress');
        request.requestBody = blob.valueOf(JSON.serialize(delAdd));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
        
        //Update delivery address
        request.requestUri = '/services/apexrest/apexrest/webportal';
        request.addHeader('Content-Type','application/json');
        request.addParameter('apiname','updateAddress');
        request.requestBody = blob.valueOf(JSON.serialize(updateDelAdd));
        
        request.httpMethod = 'POST';
        Rest_WebPortal.inboundPostRequest();
    }
}