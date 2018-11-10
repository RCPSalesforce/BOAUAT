public class BoaOrderTriggerClass {
	
	public static void  insertBoaOrderToPortalAndExo(List<Opportunity> opportunityList){
    	List<Id> salesOrderIdsForPortalSync = new List<Id>();
        List<Id> salesOrderIdsForExoSync = new List<Id>();
        List<Id> purchaseOrderIdsForExoSync = new List<Id>();
        System.debug('after insert trigger');
        for(Opportunity opp: opportunityList){
            //sales order for portal customers
            if(opp.account.Portal_Customer__c == true && opp.recordTypeId == System.Label.BoaSalesOrderRecordType){
                salesOrderIdsForPortalSync.add(opp.Id);
            }
            // sales order with closed won
            if(opp.recordTypeId == System.Label.BoaSalesOrderRecordType && opp.stageName == 'Closed Won'){
                salesOrderIdsForExoSync.add(opp.Id);
            }
            // purchase order with closed won
            if(opp.recordTypeId == System.Label.BoaPurchaseOrderRecordType && opp.stageName == 'Closed Won'){
                purchaseOrderIdsForExoSync.add(opp.Id);
            }
        }
        //
        if(!salesOrderIdsForPortalSync.isEmpty()){
           Rest_WebPortalOutbondController.callOutBoaOrder(salesOrderIdsForPortalSync); 
        }
        //
        if(!salesOrderIdsForExoSync.isEmpty()){
           Rest_ExoOutbondController.callOutBoaOrderSales(salesOrderIdsForExoSync);
        }
        //
        if(!purchaseOrderIdsForExoSync.isEmpty()){
           Rest_ExoOutbondController.callOutBoaOrderPurchase(purchaseOrderIdsForExoSync); 
        }
    }
    

	public static void updateBoaOrderToPortalAndExo(Map<Id,Opportunity> newOrdersMap, Map<Id,Opportunity> oldOrdersMap){
        //
        List<Id> salesOrderIdsForPortalSync = new List<Id>();
        List<Id> salesOrderIdsForExoSync = new List<Id>();
        List<Id> purchaseOrderIdsForExoSync = new List<Id>();
        System.debug('after update trigger');
        
        for(Opportunity opp : newOrdersMap.values()){
            system.debug('BoaSalesOrderRecordType');
            if(opp.recordTypeId == System.Label.BoaSalesOrderRecordType){
                system.debug('BoaSalesOrderRecordType');
                salesOrderIdsForPortalSync.add(opp.Id);
            }
            // sales order with closed won
            if(opp.recordTypeId == System.Label.BoaSalesOrderRecordType && opp.stageName == 'Closed Won'){
                salesOrderIdsForExoSync.add(opp.Id);
            }
            // purchase order with closed won
            if(opp.recordTypeId == System.Label.BoaPurchaseOrderRecordType && opp.stageName == 'Closed Won'){
                purchaseOrderIdsForExoSync.add(opp.Id);
            }
            
            
        }
        
        
        if(!System.isFuture() && !System.isBatch()){
        	if(!salesOrderIdsForPortalSync.isEmpty()){
           		salesOrderIdsForPortalSync = FieldValueComparatorForWebPortal.compareOrderForWebPortal(newOrdersMap, oldOrdersMap);
                if(!salesOrderIdsForPortalSync.isEmpty()){
                	Rest_WebPortalOutbondController.callOutBoaOrder(salesOrderIdsForPortalSync);     
                }
        	}
        	//
        	if(!salesOrderIdsForExoSync.isEmpty()){
           		salesOrderIdsForExoSync = FieldValueComparatorForExo.compareSalesOrderForExo(newOrdersMap,oldOrdersMap);
                if(!salesOrderIdsForExoSync.isEmpty()){
                	Rest_ExoOutbondController.callOutBoaOrderSales(salesOrderIdsForExoSync);    
                }
        	}
        	//
        	if(!purchaseOrderIdsForExoSync.isEmpty()){
           		purchaseOrderIdsForExoSync = FieldValueComparatorForExo.comparePurchaseOrderForExo(newOrdersMap,oldOrdersMap);
                if(!purchaseOrderIdsForExoSync.isEmpty()){
                	system.debug('purchaseOrderIdsForExoSync--'+purchaseOrderIdsForExoSync);
                    Rest_ExoOutbondController.callOutBoaOrderPurchase(purchaseOrderIdsForExoSync);     
                }
        	}	
        }
           
    }
}