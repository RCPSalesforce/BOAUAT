@isTest
public class Test_Rest_websiteOutboundController {
	
    public static testMethod void unitTest(){
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.QuantityUnitOfMeasure__c = 'Each';
        p.is_Hydraulic_Product__c = true;
        p.Bill_of_Material__c = false;
        p.IsActive = true;
        
        insert p;
        
		List<id> stockIds = new List<id>();
		stockIds.add(p.Id);
        
        Rest_websiteOutboundController.SFtoWebSite innerObj = new Rest_websiteOutboundController.SFtoWebSite();
        innerObj.sObjectName = 'Product';
        innerObj.sObjectId = p.Id;
        
        List<Rest_websiteOutboundController.SFtoWebSite> classList = new List<Rest_websiteOutboundController.SFtoWebSite>();
        classList.add(innerObj);    
        
        Rest_websiteOutboundController.callerMethod(classList);
		Rest_websiteOutboundController.sendProductDetailstoWebSiteTrigger(stockIds);
		test.startTest();
        batchProductUploadToWebSite b = new batchProductUploadToWebSite();
		Database.executeBatch(b);
		test.stopTest();        
    }
}