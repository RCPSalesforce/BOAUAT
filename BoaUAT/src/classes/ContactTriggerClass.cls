public class ContactTriggerClass {
    
    public static void  insertContactToPortalAndExo(List<Contact> contactList){
        
        List<Id> contactIdsForPortalSync = new List<Id>();
        List<Id> contactIdsForExoSync = new List<Id>();
        
        for(Contact con: contactList){
          
            if(con.Portal_Contact__c == true){
                contactIdsForPortalSync.add(con.Id);
            }
            if(con.accountId != null){
                //To Do:we need to restrict personal account's conatcts from being sync at this stage.
                contactIdsForExoSync.add(con.Id);
            }
        }
        //
        if(!contactIdsForPortalSync.isEmpty()){
           Rest_WebPortalOutbondController.callOut(contactIdsForPortalSync); 
        }
        //always send to EXO and receive seq number back
        if(!contactIdsForExoSync.isEmpty()){
           Rest_ExoOutbondController.callOutContact(contactIdsForExoSync);
        }
        
    }
    
    public static void updateContactToPortalAndExo(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactMap){
        
        List<Id> contactIdsForPortalSync = new List<Id>();
        List<Id> contactIdsForExoSync = new List<Id>();
        // Ids refinement at first level...
        for(Contact con : newContactMap.values()){
            if(con.Portal_Contact__c){
              contactIdsForPortalSync.add(con.Id);  
            }
            if(con.AccountId != null){
              // To Do:we need to restrict personal account's conatcts from being sync at this stage.
                contactIdsForExoSync.add(con.Id);  
            }
            
        }
        
        if(!System.isFuture() && !System.isBatch()){
        	//further fiteration from fieldcomparator and send to third party systems.
        	if(!contactIdsForPortalSync.isEmpty()){
                contactIdsForPortalSync = FieldValueComparatorForWebPortal.compareContactForWebPortal(newContactMap, oldContactMap);
                if(!contactIdsForPortalSync.isEmpty()){
                	Rest_WebPortalOutbondController.callOut(contactIdsForPortalSync); 
                }    
        	}
        	// and then to Exo
        	if(!contactIdsForExoSync.isEmpty()){
            	contactIdsForExoSync = FieldValueComparatorForExo.compareContactsForExo(newContactMap,oldContactMap);
                if(!contactIdsForExoSync.isEmpty()){
                	Rest_ExoOutbondController.callOutContact(contactIdsForExoSync);     
                }
                
        	}
        
        }
           
    }

}