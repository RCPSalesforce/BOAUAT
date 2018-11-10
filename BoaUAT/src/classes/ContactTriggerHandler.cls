public class ContactTriggerHandler implements ITriggerHandler {
	
    public void BeforeInsert(List<SObject> newItems) {
		
        
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {		
        
    }

    public void BeforeDelete(Map<Id, SObject> oldItems) {
       
    }

    public void AfterInsert(Map<Id, SObject> newItems) {
    List<Contact> newContacts = newItems.values();
    List<Account> updateAccoutnts = new List<Account>();
        //sync with external systems first
        ContactTriggerClass.insertContactToPortalAndExo(newContacts);
        
        // to update account as portal account 
        for(Contact con: newContacts){
            if(con.AccountId != null && con.Portal_Contact__c){
                Account updAccount = new Account(Id=con.AccountId,portal_customer__c=true);
                updateAccoutnts.add(updAccount);
            }
        }    
    	
        if(!updateAccoutnts.isEmpty()){
            update updateAccoutnts;
        }
    }

    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
		Map<Id,Contact> newContactMap = new Map<Id,Contact>();
        Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
        
        List<Contact> newContactList = newItems.values(); 
        for(Contact newContact : newContactList){
            newContactMap.put(newContact.Id,newContact);
        }
        
        List<Contact> oldContactList = oldItems.values(); 
        for(Contact oldContact : oldContactList){
            oldContactMap.put(oldContact.Id,oldContact);
        }
        //
        ContactTriggerClass.updateContactToPortalAndExo(newContactMap,oldContactMap);
		
        for(Contact con : newContactList){            
        	if(con.AccountId != null && con.Portal_Contact__c == true){
                //if(con.Account.Portal_Customer__c != true){
                //	con.Account.Portal_Customer__c = true;    
                //}	    
            }                
        }        
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {
    }

    public void AfterUndelete(Map<Id, SObject> oldItems) {
    }
}