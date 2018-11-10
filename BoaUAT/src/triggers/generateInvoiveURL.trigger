trigger generateInvoiveURL on ContentDocumentLink (before insert) {
	
    Set<Id> objList = New Set<Id>();
    
    for(ContentDocumentLink link : trigger.new){
    	objList.add(link.LinkedEntityId);
        System.debug('ContentDocument.title ' + ContentDocument.title);
        system.debug('link ' + link);
    }
    
    sObject obj;
    
    for(Id objId : objList){
    	obj  = objId.getSObjectType().newSObject(objId);
        System.debug('obj ' +obj);
    }
    //getting object name based on EntityId
    String objName = obj.id.getSObjectType().getDescribe().getName();
    System.debug('objName ' + objName);
    //Uncomment below code when pDF Butler is ready
    if(objName == 'Opportunity'){
        Map<Id, ContentVersion> contentDocumentIdToVersion = new Map<Id, ContentVersion>();
        Set<Id> contentDocumentIds = new Set<Id>();
        List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
        
        for(ContentDocumentLink link : trigger.new){    	
            contentDocumentIds.add(link.ContentDocumentId);    
        }
        
        List<ContentVersion> cvList = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : contentDocumentIds];        
        system.debug('cvList ' + cvList);
        for(ContentVersion cv : cvList){
            contentDocumentIdToVersion.put(cv.ContentDocumentId,cv);    
        }        
        
        for(Id cdId : contentDocumentIds){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Public Link';
            cd.ContentVersionId = contentDocumentIdToVersion.get(cdId).Id;
            distributionsToInsert.add(cd);
        }
        
        if(!distributionsToInsert.isEmpty()){
            //insert contentDelivery
            insert distributionsToInsert;
            system.debug('distributionsToInsert ' + distributionsToInsert);
            distributionsToInsert = [SELECt Id, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId IN:ContentDocumentIds];
			system.debug('distributionsToInsert ' + distributionsToInsert);            
            //fetching opportunity 
            List<Opportunity> oppList = [SELECT id, Invoice_URL__c FROM Opportunity WHERE Id IN :objList];
            system.debug('oppList ' + oppList);
            for(Opportunity opp : oppList){
                //Populating invoice url
				opp.Invoice_URL__c = distributionsToInsert[0].DistributionPublicUrl;
            }
            
            //update opportunity
            update oppList; 
            
        }
    }
}