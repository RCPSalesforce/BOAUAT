public class FieldValueComparatorForExo {
	
    public static List<Id> compareCustomersForExo(Map<Id,Account> newCustomerMap, Map<Id,Account> oldCustomerMap){
    	
        List<Id> customerIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorExo__mdt WHERE
                                       DeveloperName = 'Customer'].Fields__c.split(';');
        System.debug('fieldsToCompare--'+fieldsToCompare);
        for(Account acc: newCustomerMap.values()){
            if(acc.RecordTypeId == System.Label.BoaEnterpriseCustomer){
            	sObject newAcc = newCustomerMap.get(acc.Id);
            	sObject oldAcc = oldCustomerMap.get(acc.Id);
            	for(String field :fieldsToCompare ){
                	system.debug('field--'+field);
                    system.debug('newval--'+newAcc.get(field)+'--oldval'+oldAcc.get(field));
                    if(newAcc.get(field) != oldAcc.get(field)){
                        customerIdsToBeSynced.add(acc.Id);
                    	break;
                	}
            	}    
            }
            	
        }
        
        system.debug('customerIdsToBeSynced--'+customerIdsToBeSynced);
        return customerIdsToBeSynced;
    }
    
    
    public static List<Id> compareSupplierForExo(Map<Id,Account> newCustomerMap, Map<Id,Account> oldCustomerMap){
    	List<Id> supplierIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorExo__mdt WHERE
                                       DeveloperName = 'Supplier'].Fields__c.split(';');
        System.debug('fieldsToCompare--'+fieldsToCompare);
        for(Account acc: newCustomerMap.values()){
            if(acc.RecordTypeId == System.Label.BoaSupplierCustomer){
            	sObject newAcc = newCustomerMap.get(acc.Id);
            	sObject oldAcc = oldCustomerMap.get(acc.Id);
            	for(String field :fieldsToCompare ){
                    if(newAcc.get(field) != oldAcc.get(field)){
                        supplierIdsToBeSynced.add(acc.Id);
                    	break;
                	}
            	}    
            }
            	
        }
        
        return supplierIdsToBeSynced;
    }
    
    
    public static List<Id> compareContactsForExo(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactMap){
    	
        List<Id> contactIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorExo__mdt WHERE
                                       DeveloperName = 'Contact'].Fields__c.split(';');
        System.debug('fieldsToCompare--'+fieldsToCompare);
        for(Contact con: newContactMap.values()){
            if(con.accountId != null){
            	sObject newCon = newContactMap.get(con.Id);
            	sObject oldCon = oldContactMap.get(con.Id);
            	for(String field :fieldsToCompare ){
                	system.debug('field--'+field);
                    system.debug('newval--'+newCon.get(field)+'--oldval'+oldCon.get(field));
                    if(newCon.get(field) != oldCon.get(field)){
                        contactIdsToBeSynced.add(con.Id);
                    	break;
                	}
            	}    
            }
            	
        }
        
        system.debug('contactIdsToBeSynced--'+contactIdsToBeSynced);
        return contactIdsToBeSynced;
    }
   
     public static List<Id> compareSalesOrderForExo(Map<Id,Opportunity> newOrderMap, Map<Id,Opportunity> oldOrderMap){
    	List<Id> salesOrderIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorExo__mdt WHERE
                                       DeveloperName = 'SalesOrder'].Fields__c.split(';');
        System.debug('fieldsToCompare--'+fieldsToCompare);
        for(Opportunity opp: newOrderMap.values()){
            if(opp.RecordTypeId == System.Label.BoaSalesOrderRecordType){
            	sObject newOpp = newOrderMap.get(opp.Id);
            	sObject oldOpp = oldOrderMap.get(opp.Id);
            	for(String field :fieldsToCompare ){
                    if(newOpp.get(field) != oldOpp.get(field)){
                        salesOrderIdsToBeSynced.add(opp.Id);
                    	break;
                	}
            	}    
            }
            	
        }
        
        return salesOrderIdsToBeSynced;
       
    }
    
    
    public static List<Id> comparePurchaseOrderForExo(Map<Id,Opportunity> newOrderMap, Map<Id,Opportunity> oldOrderMap){
    	List<Id> purchaseOrderIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorExo__mdt WHERE
                                       DeveloperName = 'PurchaseOrder'].Fields__c.split(';');
        System.debug('fieldsToCompare--'+fieldsToCompare);
        for(Opportunity opp: newOrderMap.values()){
            if(opp.RecordTypeId == System.Label.BoaPurchaseOrderRecordType){
            	sObject newOpp = newOrderMap.get(opp.Id);
            	sObject oldOpp = oldOrderMap.get(opp.Id);
            	for(String field :fieldsToCompare ){
                    if(newOpp.get(field) != oldOpp.get(field)){
                        purchaseOrderIdsToBeSynced.add(opp.Id);
                    	break;
                	}
            	}    
            }
            	
        }
        
        return purchaseOrderIdsToBeSynced;
       
    }
}