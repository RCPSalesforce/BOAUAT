/*
 * Description : Batch class to update stock prices info to EXO from SF.
 * History : 
 * Initial Version : 24Sept2018 RohitP
*/

public class batchStockPricesUpdateToExo implements database.Batchable<sObject>,Database.AllowsCallouts {

    public list<pricebookentry> start(Database.BatchableContext bc) {
        // getting all customer pricebookentries updated during last 1 hour. 
        return [SELECT Id,Pricebook2Id FROM PriceBookEntry WHERE 
   				LastModifiedDate >:Datetime.now().addMinutes(-65)];
    }
    
    public void execute(Database.BatchableContext bc, List<pricebookentry> scope){
    	List<Id> pbeIdsToUpdateInExo = new List<Id>();
        system.debug('list--'+scope);
        for(PriceBookEntry pbe: scope){
            pbeIdsToUpdateInExo.add(pbe.Id);
        }
        
        if(pbeIdsToUpdateInExo.size() > 0){
        	Rest_ExoOutboundHandler.upsertPriceBookDetailsToEXO(pbeIdsToUpdateInExo);    
        }
        
    }


	public void finish(Database.BatchableContext bc){
         // do nothing   
          
    }        
}