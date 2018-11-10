/*
* Description - Class will work as a generic rest resource for web portal as well as mobile app. From here request will be
				further directed to proper class using REst_WebPortalHandler
* Author - Centelon Team 
*/ 

@RestResource(urlMapping='/webportal')
global class Rest_WebPortal{
    
 @HttpGet
    global static string inboundGetRequest() {
        RestRequest req = RestContext.request;
        string apiName = req.params.get('apiname');
        String accountId = req.params.get('accountid');
        
        string response; 
        
        //RESTNRCMobileApp NMA = new RESTNRCMobileApp();
        //response = NMA.inboundGetRequestRouter(apiName,userId,rego);
        
        return response;   
       
    }      
    
    @HttpPost
    global static string inboundPostRequest() {
        
        String requestBody;
        requestBody = System.RestContext.request.requestBody.toString();
        
        string apiName = system.RestContext.request.params.get('apiname');
        system.debug('apiName--' +apiName); 
        
        string response;
        
        Rest_WebPortalHandler wph = new Rest_WebPortalHandler();
        response = wph.inboundPostRequestRouter(apiName, requestBody);
        return response; 
         
    }
    
    /*@HttpPatch
    global static string inboundPatchRequest(){    	
        String requestBody;
        requestBody = System.RestContext.request.requestBody.toString();
        Restrequest req = RestContext.request;
        String apiname = req.params.get('apiname');
        String custid = req.params.get('id');
        String response;
        Rest_WebPortalHandler wph = new Rest_WebPortalHandler();
        response = wph.inboundPatchRequestRouter(apiname, requestbody);        
        return response;
    }*/
}