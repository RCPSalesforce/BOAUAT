/*
* Description - batch class to push all products in a single go to web site.
* Author - Centelon Team 
*/

public class batchProductUploadToWebSite implements database.Batchable<sObject>,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        string rec = 'SELECT Id from product2 where Bill_of_Material__c = false and is_Hydraulic_Product__c = true';
        //string rec = 'SELECT Id from product2 where wordpress_Id__c = \'\' AND Bill_of_Material__c = false and is_Hydraulic_Product__c = true';
        //string rec = 'SELECT Id,Name FROM Product2 WHERE WordPress_id__c = \'\' AND Bill_of_Material__c = false and is_Hydraulic_Product__c = true';
        //string rec = 'SELECT Id,Name,Stock_Image_1__c,Stock_Image_2__c,Stock_Image_3__c FROM Product2 WHERE WordPress_id__c = \'\' AND  AND Bill_of_Material__c = false and is_Hydraulic_Product__c = true
        system.debug('rec ' + rec);     
        return Database.getQueryLocator(rec);
    }
    
    public void execute(Database.BatchableContext bc, List<product2> scope){
        
       list<id> productIds = new list<id>();
        
        
        for(product2 p : scope){
            productIds.add(p.id);
        }

			Rest_websiteOutboundController.sendProductDetailstoWebSiteTrigger(productIds);
            
        
         
       
    }    
    public void finish(Database.BatchableContext bc){
            
          
    }    

    
}