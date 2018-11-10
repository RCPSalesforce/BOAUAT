public class FieldValueComparatorForWebPortal {
	
    public static List<Id> compareCustomersForWebPortal(Map<Id,Account> newCustomerMap, Map<Id,Account> oldCustomerMap){
        
        List<Id> customerIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorWebPortal__mdt WHERE
                                       DeveloperName = 'Customer'].Fields__c.split(';');
        
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
        
        return customerIdsToBeSynced;
    }
    
    public static List<Id> compareOrderForWebPortal(Map<Id,Opportunity> newOrderMap, Map<Id,Opportunity> oldOrderMap){
    	system.debug('In Order compare web portal');
        List<Id> orderIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorWebPortal__mdt WHERE
                                       DeveloperName = 'SalesOrder'].Fields__c.split(';');
        
        for(Opportunity opp: newOrderMap.values()){
            if(opp.RecordTypeId == System.Label.BoaSalesOrderRecordType){
            	sObject newOpp = newOrderMap.get(opp.Id);
            	sObject oldOpp = oldOrderMap.get(opp.Id);
            	for(String field :fieldsToCompare ){
                	system.debug('field--orderwebportal'+field);
                    system.debug('newval--webporrtal'+newOpp.get(field)+'--oldval'+oldopp.get(field));
                    if(newOpp.get(field) != oldOpp.get(field)){
                        orderIdsToBeSynced.add(opp.Id);
                    	break;
                	}
            	}    
            }
            	
        }
        
        return orderIdsToBeSynced;
    }
    
    public static List<Id> compareContactForWebPortal(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactMap){
    	system.debug('In Contact compare web portal');
        List<Id> contactIdsToBeSynced = new List<Id>();
        List<String> fieldsToCompare = [SELECT DeveloperName,Fields__c FROM FieldComparaorWebPortal__mdt WHERE
                                       DeveloperName = 'Contact'].Fields__c.split(';');
        
        for(Contact con: newContactMap.values()){
            //if(opp.RecordTypeId == System.Label.BoaSalesOrderRecordType){
            	sObject newCon = newContactMap.get(con.Id);
            	sObject oldCon = oldContactMap.get(con.Id);
            	for(String field :fieldsToCompare){
                	system.debug('field--orderwebportal'+field);
                    //system.debug('newval--webporrtal'+newOpp.get(field)+'--oldval'+oldopp.get(field));
                    if(newCon.get(field) != oldCon.get(field)){
                        contactIdsToBeSynced.add(con.Id);
                    	break;
                	}
            	}    
            //}
            	
        }
        
        return contactIdsToBeSynced;
    }
    
    
    
    
}