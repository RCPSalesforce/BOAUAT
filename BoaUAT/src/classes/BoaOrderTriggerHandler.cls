public class BoaOrderTriggerHandler implements ITriggerHandler {

    public void BeforeInsert(List<SObject> newItems) {
		Set<Id> oppIds = new Set<Id>();
        for(SObject s: newItems){
            oppIds.add(s.Id);
        }
        List<Opportunity> opportunityList = [SELECT Id,StageName from Opportunity WHERE Id IN: oppIds];
        for(Opportunity opp : opportunityList){
            if(opp.StageName == 'Closed Won'){
                system.debug('Invoiced');
                opp.Web_Portal_Order_Status__c = 'Invoiced';
            }
            else if(opp.StageName == 'Closed Lost'){
                system.debug('Cancelled');
                opp.Web_Portal_Order_Status__c = 'WP-Cancelled';
            }
        }
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        system.debug('Before Update BOA Order');
		List<Opportunity> opportunityList = newItems.values();
        system.debug('opportunityList ' + opportunityList);
        for(Opportunity opp : opportunityList){
            if(opp.StageName == 'Closed Won'){
                system.debug('Invoiced');
                opp.Web_Portal_Order_Status__c = 'Invoiced';
            }
            else if(opp.StageName == 'Closed Lost'){
                system.debug('Cancelled');
                opp.Web_Portal_Order_Status__c = 'WP-Cancelled';
            }
        }
        
    }

    public void BeforeDelete(Map<Id, SObject> oldItems) {
       
    }

    public void AfterInsert(Map<Id, SObject> newItems) {
        
    List<Opportunity> newOrders =  newItems.values();
    BoaOrderTriggerClass.insertBoaOrderToPortalAndExo(newOrders);
    
    }

    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Opportunity> newOrdersMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> oldOrdersMap = new Map<Id,Opportunity>();
        
        List<Opportunity> newOrderList = newItems.values(); 
        for(Opportunity newOrder : newOrderList){
            newOrdersMap.put(newOrder.Id,newOrder);
        }
        
        List<Opportunity> oldOrderList = oldItems.values(); 
        for(Opportunity oldOrder : oldOrderList){
            oldOrdersMap.put(oldOrder.Id,oldOrder);
        }
        
        //
        BoaOrderTriggerClass.updateBoaOrderToPortalAndExo(newOrdersMap,oldOrdersMap);
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {
    }

    public void AfterUndelete(Map<Id, SObject> oldItems) {
    }
    
}