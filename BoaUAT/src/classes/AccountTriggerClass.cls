public class AccountTriggerClass {
	
    public static void  insertCustomerToPortalAndExo(List<Account> customerList){
        
        List<Id> customerIdsForPortalSync = new List<Id>();
        List<Id> customerIdsForExoSync = new List<Id>();
        List<Id> supplierIdsForExoSync = new List<Id>();
        for(Account a: customerList){
            //  include retail customers also.
            if(a.Portal_Customer__c == true && a.recordTypeId != System.Label.BoaSupplierCustomer){
                customerIdsForPortalSync.add(a.Id);
            }
            if(a.recordTypeId == System.Label.BoaEnterpriseCustomer){
                customerIdsForExoSync.add(a.Id);
            }
            if(a.recordTypeId == System.Label.BoaSupplierCustomer){
                supplierIdsForExoSync.add(a.Id);
            }
        }
        //on creation if - Portal_Customer__c = true ..send to portal.
        if(!customerIdsForPortalSync.isEmpty()){
           Rest_WebPortalOutbondController.callOutAccount(customerIdsForPortalSync); 
        }
        //always send to EXO and receive accountNumber__c
        if(!customerIdsForExoSync.isEmpty()){
           Rest_ExoOutbondController.callDebitOutAccount(customerIdsForExoSync);
        }
        
        if(!supplierIdsForExoSync.isEmpty()){
           Rest_ExoOutbondController.callOutCreditAccount(supplierIdsForExoSync); 
        }
        
    }
    
    public static void updateCustomerToPortalAndExo(Map<Id,Account> newCustomerMap, Map<Id,Account> oldCustomerMap){
        
        List<Id> customerIdsForPortalSync = new List<Id>();
        List<Id> customerIdsForExoSync = new List<Id>();
        List<Id> supplierIdsForExoSync = new List<Id>();
        // first level ids filteration
        for(Account a : newCustomerMap.values()){
            if(a.Portal_Customer__c){
               customerIdsForPortalSync.add(a.Id); 
            }            
            if(a.RecordTypeId == System.Label.BoaEnterpriseCustomer){
                customerIdsForExoSync.add(a.Id);
            }
            if(a.RecordTypeId == System.Label.BoaSupplierCustomer){
                supplierIdsForExoSync.add(a.Id);
            }
        }
        


		if(!System.isFuture() && !system.isBatch()){
        //refine further by fieldComparator
        if(!customerIdsForPortalSync.isEmpty()){
        	customerIdsForPortalSync = FieldValueComparatorForWebPortal.compareCustomersForWebPortal(newCustomerMap, oldCustomerMap);
            //otherwise first send it to portal
        	if(!customerIdsForPortalSync.isEmpty()){
             	Rest_WebPortalOutbondController.callOutAccount(customerIdsForPortalSync); 
        	}
        }
        if(!customerIdsForExoSync.isEmpty()){
        	customerIdsForExoSync = FieldValueComparatorForExo.compareCustomersForExo(newCustomerMap,oldCustomerMap);
            // and then to Exo
        	if(!customerIdsForExoSync.isEmpty()){
            	Rest_ExoOutbondController.callDebitOutAccount(customerIdsForExoSync); 
        	}
        }
        if(!supplierIdsForExoSync.isEmpty()){
        	supplierIdsForExoSync = FieldValueComparatorForExo.compareSupplierForExo(newCustomerMap,oldCustomerMap);
            if(!supplierIdsForExoSync.isEmpty()){
            	Rest_ExoOutbondController.callOutCreditAccount(supplierIdsForExoSync); 
        	}
        }
        
        } 
                   
    }
    
    public static void calculateRemainingCreditBalance(Map<Id,Account> newCustomerMap, Map<Id,Account> oldCustomerMap){
    	
        for(Account a : newCustomerMap.values()){
            if(oldCustomerMap.get(a.Id).Credit_Limit__c != newCustomerMap.get(a.Id).Credit_Limit__c){
                System.debug('credit limit changed');
                Decimal newAccLimit = newCustomerMap.get(a.Id).Credit_Limit__c;
            	Decimal oldAccLimit = oldCustomerMap.get(a.Id).Credit_Limit__c;
                Decimal difference = 0;
                //difference = oldAccLimit - newAccLimit;
                system.debug('difference ' + difference);
                if(newAccLimit > oldAccLimit){
                    //Addition
                    difference = newAccLimit - oldAccLimit;
                    system.debug('difference addition ' + difference);
                    a.Remaining_Credit_Balance__c += difference;
                }
                if(newAccLimit < oldAccLimit){
                    //Sunstration
                    difference = oldAccLimit - newAccLimit;
                    system.debug('difference sub ' + difference);
                	a.Remaining_Credit_Balance__c -= difference;    
                }
            }    
        }
    }
    
}