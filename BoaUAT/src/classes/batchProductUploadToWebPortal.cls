/*
* Description - batch class to push all products in a single go to web portal.
* Author - Centelon Team 
*/

public class batchProductUploadToWebPortal implements database.Batchable<sObject>,Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        string rec = 'SELECT Id from product2 where Bill_of_Material__c = false and is_Hydraulic_Product__c = true'; 
             
        return Database.getQueryLocator(rec);
    }
    
    public void execute(Database.BatchableContext bc, List<product2> scope){
        
       list<id> productIds = new list<id>();
        
        
        for(product2 p : scope){
            productIds.add(p.id);
        }

			Rest_WebPortalOutbondController.sendProductDetailsTrigger(productIds);
            
        
         
       
    }    
    public void finish(Database.BatchableContext bc){
            
          
    }    

    

}