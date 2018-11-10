/*
* Description - Class to be used for outbound integration with public web site. 
* Author - Centelon Team 
*/
 


public class Rest_websiteOutboundController {
	
    public class SFtoWebSite{
        
        @InvocableVariable
        public string sObjectName;
        @InvocableVariable
        Public string sObjectId;        
    }
    
    @InvocableMethod
    public static void callerMethod(List<SFtoWebSite> obj){
    	String objName;
        List<Id> sObjIds = new List<Id>();
        for(SFtoWebSite sObj : obj){
            objName = sObj.sObjectName;
            sObjIds.add(sObj.sObjectId);
        }
        
        if(objName == 'Product'){
        	sendProductDetailstoWebSite(sObjIds);	    
        }
    }
    
    //method to send product details to external website
    public static void sendProductDetailstoWebSite(list<id> stockItemIds){
        if(!stockItemIds.isEmpty()){
        	//Rest_websiteOutboundHandler.sendProductDetailsToPublicSite(stockItemIds);
        	callOut(stockItemIds);
        }        
    }
    
    @future(callout=true)
    public static void callOut(List<Id> stockItemIds){
    	Rest_websiteOutboundHandler.sendProductDetailsToPublicSite(stockItemIds);    
    }
    
    //For batch class
    public static void sendProductDetailstoWebSiteTrigger(list<id> stockItemIds){
    	Rest_websiteOutboundHandler.sendProductDetailsToPublicSite(stockItemIds);        
    }
    
}