@IsTest
public class Test_ConvertComponentController {

    @testSetup
    static void setup() {
        cadmus__Doc_Config__c dc = new cadmus__Doc_Config__c();
        dc.cadmus__CustomerDocumentConfigId__c = '1234';
        
        insert dc;
    }
    
    static testmethod void initServerTest() {
        cadmus__Doc_Config__c dc = [SELECT Id FROM cadmus__Doc_Config__c LIMIT 1];
        String data = ConvertComponentController.initServer(dc.Id + ',DocConfigID1');
        
        ConvertComponentController.InitData init = (ConvertComponentController.InitData)System.JSON.deserialize(data, ConvertComponentController.InitData.class);
        
        System.assertEquals(1, init.docConfigs.size());
    }
    
    static testmethod void initServerTestEmptyList() {
        String data = ConvertComponentController.initServer('');
        
        ConvertComponentController.InitData init = (ConvertComponentController.InitData)System.JSON.deserialize(data, ConvertComponentController.InitData.class);
        
        System.assertEquals(0, init.docConfigs.size());
    }

    static testmethod void convertTest() {
        cadmus__Doc_Config__c dc = [SELECT Id FROM cadmus__Doc_Config__c LIMIT 1];
        
        cadmus.CadmusHttpCalloutMock.setTestCalloutMockSuccess(dc.Id);
       	Test.startTest();
        String data = ConvertComponentController.convert(dc.Id, dc.Id, 'en_US', null, 'PDF');
        Test.stopTest();
        
        System.assert(!data.contains('ERROR'));
    }

    static testmethod void convertTestError() {
        cadmus__Doc_Config__c dc = [SELECT Id FROM cadmus__Doc_Config__c LIMIT 1];
        
       	Test.startTest();
        String data = ConvertComponentController.convert(dc.Id, dc.Id, 'en_US', null, 'PDF');
        Test.stopTest();
        
        System.assert(data.contains('ERROR'));
    }
}