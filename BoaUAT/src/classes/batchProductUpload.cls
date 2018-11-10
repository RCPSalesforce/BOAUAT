/*
* Description - batch class to push all products in a single go to web portal.
* Author - Centelon Team 
*/
public class batchProductUpload implements database.Batchable<sObject>,Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        string rec = 'SELECT Id from product2'; 
             
        return Database.getQueryLocator(rec);
    }
    
    public void execute(Database.BatchableContext bc, List<product2> scope){
        
       list<id> productIds = new list<id>();
        
        
        for(product2 p : scope){
            productIds.add(p.id);
        }

			Rest_WebPortalOutbondController.sendProductDetails(productIds);
            
        
         
       
    }    
    public void finish(Database.BatchableContext bc){
            
          
    }    

    

}