public class Rest_outboundCaller {
    
    public static string loginToWebPortal(){
        string authToken;
        httpRequest loginreq = new httpRequest();
        loginreq.setEndpoint(web_portal_creds__c.getValues('endpoint').value__c + '/auth/logIn');
        loginreq.setMethod('POST');
        loginreq.setHeader('Content-Type','application/json');
        loginreq.setHeader('x-api-key',web_portal_creds__c.getValues('x-api-key').value__c);
        loginreq.setBody('{"email":"'+web_portal_creds__c.getValues('email').value__c+'","password":"'+web_portal_creds__c.getValues('password').value__c+'"}');
        
        http http = new http();
        httpResponse res = http.send(loginreq);
        
        system.debug('res--'+res);
        
        string response = res.getBody();
        JSONParser parser = JSON.createParser(response);
        system.debug('parser--'+parser);		
        while (parser.nextToken() != null) {
            // Start at the string response.
            while (parser.nextToken() != null) {
                if(parser.getCurrentName() == 'sessionID' ){
                    parser.nextValue();
                    authToken = parser.getText();
                    
                }     
            }
            
            
        }
        
        
        
        system.debug('authToken--'+authToken);
        return authToken;
    }
   


public static void updatewebportalAccessToken(string accessToken){
    // get access token and store it in custom settings for further reference.
    session_Tokens__c webportalAccessToken = session_Tokens__c.getInstance('web_portal');
    webportalAccessToken.token__c = accessToken;
    update webportalAccessToken;
} 


/* 
public static Rest_webPortalWrappers.genericOutboundResponseWrapper postContactUpdateRequest(string accessToken,string body){

Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();

httpRequest req = new httpRequest();
req.setEndpoint(web_portal_creds__c.getValues('endpoint').value__c + '/salesforce/sync/user/activate');    

req.setMethod('POST');
req.setHeader('Content-Type','application/json');
req.setHeader('x-api-key',web_portal_creds__c.getValues('x-api-key').value__c);
string bearerToken;
if(string.isBlank(accessToken)){
bearerToken = 'bearer '+session_Tokens__c.getValues('web_portal');    
}else{
bearerToken = 'bearer '+accessToken;    
}


system.debug('bearerToken--'+bearerToken);
req.setHeader('Authorization',bearerToken);	

req.setBody(body);

http http = new http();
httpResponse res = http.send(req);
system.debug('post res--'+res.getBody());
system.debug('post res code--'+res.getstatusCode());
responseWrapper.responseCode = res.getStatusCode();
responseWrapper.responseBody =res.getBody();


return responseWrapper;
} 
*/

// post http request to portal
public static Rest_webPortalWrappers.genericOutboundResponseWrapper postHttpRequestPortal(string endpointAPI,string accessToken,string body){
    Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
    
    httpRequest req = new httpRequest();
    req.setEndpoint(web_portal_creds__c.getValues('endpoint').value__c + endpointAPI);    
    
    req.setMethod('POST');
    req.setHeader('Content-Type','application/json');
    req.setHeader('x-api-key',web_portal_creds__c.getValues('x-api-key').value__c);
    
    string bearerToken;
    if(string.isBlank(accessToken) || accessToken == ''){
        bearerToken = 'bearer '+session_Tokens__c.getValues('web_portal').token__c;    
    }else{
        bearerToken = 'bearer '+accessToken;    
    }
    
    
    system.debug('bearerToken--'+bearerToken);
    req.setHeader('Authorization',bearerToken);	
    
    req.setBody(body);
    
    http http = new http();
    httpResponse res = http.send(req);
    system.debug('post res--'+res.getBody());
    system.debug('post res code--'+res.getstatusCode());
    responseWrapper.responseCode = res.getStatusCode();
    responseWrapper.responseBody = res.getBody();
    
    
    return responseWrapper;
    
}
public static Rest_ExoWrappers.genericOutboundResponseWrapper postHttpRequestExo(string endpointAPI,string accessToken,string body){
    Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
    
    httpRequest req = new httpRequest();
    req.setEndpoint(Exo_Credentials__c.getValues('endpoint').value__c + endpointAPI);    
    
    req.setMethod('POST'); 
    req.setHeader('Content-Type','application/json');
    req.setHeader('x-api-key',Exo_Credentials__c.getValues('x-api-password').value__c);
    //req.setHeader('x-api-password',Exo_Credentials__c.getValues('x-api-password').value__c);
    string bearerToken;
    if(string.isBlank(accessToken) || accessToken == ''){
        bearerToken = 'bearer '+exo_session_tokens__c.getValues('EXO').token__c;    
    }else{
        bearerToken = 'bearer '+accessToken;    
    }
    
    
    system.debug('bearerToken--'+bearerToken);
    req.setHeader('Authorization',bearerToken);	
    req.setTimeout(70000);
    req.setBody(body);
    
    http http = new http();
    httpResponse res = http.send(req);
    system.debug('post res--'+res.getBody());
    system.debug('post res code--'+res.getstatusCode());
    responseWrapper.responseCode = res.getStatusCode();
    responseWrapper.responseBody = res.getBody();
    
    
    return responseWrapper;
    
}
     
//get call for EXO
public static Rest_ExoWrappers.genericOutboundResponseWrapper getHttpRequestExo(string endpointAPI,string accessToken){
    Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
    
    httpRequest req = new httpRequest();
    req.setEndpoint(Exo_Credentials__c.getValues('endpoint').value__c + endpointAPI);    
    
    req.setMethod('GET'); 
    req.setHeader('Content-Type','application/json');
    //req.setHeader('x-api-key',Exo_Credentials__c.getValues('x-api-key').value__c);
    req.setHeader('x-api-key',Exo_Credentials__c.getValues('x-api-password').value__c);
    string bearerToken;
    if(string.isBlank(accessToken) || accessToken == ''){
        //bearerToken = 'bearer '+exo_session_tokens__c.getValues('EXO').token__c;    
    }else{
        //bearerToken = 'bearer '+accessToken;    
    }
    
    
    system.debug('bearerToken--'+bearerToken);
    //req.setHeader('Authorization',bearerToken);	
    req.setTimeout(120000);
    
    
    http http = new http();
    httpResponse res = http.send(req);
    system.debug('get res--'+res.getBody());
    system.debug('get res code--'+res.getstatusCode());
    responseWrapper.responseCode = res.getStatusCode();
    responseWrapper.responseBody = res.getBody();
    
    
    return responseWrapper;
    
}


    
  


//post http request to web site
public static Rest_webPortalWrappers.genericOutboundResponseWrapper postHttpCreateProductTowebSite(string body,string wordPressId){
    System.debug('in website request');
    Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
    
    httpRequest req = new httpRequest();
    //get web site credentials for product
    web_site_creds__c wc = web_site_creds__c.getValues('products');
    //set endpoint
    System.debug('wordPressId ' + wordPressId);
    if(wordPressId==null){
        req.setEndpoint(wc.endpoint__c +'?consumer_key='+wc.consumer_key__c+'&consumer_secret='+wc.consumer_secret__c);    
    }
    else{
        //for update
        req.setEndpoint(wc.endpoint__c+'/'+ wordPressId +'?consumer_key='+wc.consumer_key__c+'&consumer_secret='+wc.consumer_secret__c);    
    }
    req.setMethod('POST');
    req.setHeader('Content-Type','application/json');
    req.setHeader('Cache-Control', 'no-cache');
    req.setBody(body);
    
    http http = new http();
    httpResponse res = http.send(req);
    system.debug('post res--'+res.getBody());
    system.debug('post res code--'+res.getstatusCode());
    responseWrapper.responseCode = res.getStatusCode();
    responseWrapper.responseBody = res.getBody();
    
    if(wordPressId==null){
        List<Product2> prodList = new List<Product2>(); 
        Map<String,String> stockNameToIdMap = new Map<String,String>();
        String stockItemName;
        String stockItemID;
        JSONParser parser = JSON.createParser(res.getBody());
        
        while (parser.nextToken() != null) {
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'id')) {                
                    // Get the value.
                    parser.nextToken();
                    
                    stockItemID = parser.getText();
                    system.debug('stockItemID.. ' + stockItemID);
                }
            else if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'name')){
                        // Get the value.
                        parser.nextToken();
                        
                        stockItemName = parser.getText();
                        system.debug('stockItemName.. '  + stockItemName);
                        stockNameToIdMap.put(stockItemName,stockItemID);
                        break;
                        //stockItemName = '';
                        //stockItemID = '';    
                    }
            
            //stockNameToIdMap.put(stockItemName,stockItemID);
            
        }
        System.debug('stockNameToIdMap ' + stockNameToIdMap);
        
        prodList = [SELECT Id, Name, WordPress_Id__c FROM Product2 WHERE Name IN :stockNameToIdMap.keySet()];
        
        //if(wordPressId==null){
        for(Product2 prod : prodList){            
            prod.WordPress_Id__c = stockNameToIdMap.get(prod.Name);    
        }
        
        update prodList;
    }
    //System.debug('stockNameToIdMap ' + stockNameToIdMap);
    return responseWrapper;
}

}