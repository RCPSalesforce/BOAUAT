/*
* Description - Class handles methods for web portal operations in salesforce.
* Author - Centelon Team 
*/

global class Rest_WebPortalHandler { 
    
    global string inboundPostRequestRouter(string apiName, string requestBody){
        
        string response = '';
        if(!string.isBlank(apiName) && !string.isBlank(requestBody)){
            //Create new Activity
            if(apiName.equalsIgnoreCase('createSignup')){
               CustomerController.Responsewrapper responseObj = new CustomerController.ResponseWrapper();
               responseObj = CustomerController.customerSignUpForRetailCustomer(requestBody);
               return JSON.serialize(responseObj);
            }
            //Create CAF
            else if(apiname.equalsIgnoreCase('createCAForm')){	                
            	CustomerController.Responsewrapper responseObj = new CustomerController.ResponseWrapper();
                responseObj = CustomerController.createCAForm(requestBody);
                return JSON.serialize(responseObj);
            }
            // Update activity
            /*else if(apiname.equalsIgnoreCase('updatecustomer')){
            	CustomerController.Responsewrapper responseObj = new CustomerController.Responsewrapper();
                responseObj = CustomerController.updateCustomer(requestbody);
                return JSON.serialize(responseObj);
            }*/
            //Create order
            else if(apiname.equalsIgnoreCase('createOrder')){
                System.debug('in Handler method');
            	CustomerController.orderResponseWrapper responseObj = new CustomerController.orderResponseWrapper();
                System.debug('response obj creted');
                responseObj = CustomerController.createorder(requestbody);
                System.debug('order created ' + responseObj);
                return JSON.serialize(responseObj);
                
            }
            else if(apiname.equalsIgnoreCase('updateOrder')){
            	CustomerController.orderResponseWrapper responseObj = new CustomerController.orderResponseWrapper();
                responseObj = CustomerController.updateOrder(requestbody);
                return JSON.serialize(responseObj);
            }
            //delete delivery address
            else if(apiname.equalsIgnoreCase('deleteAddress')){
            	CustomerController.responseWrapper responseObj = new CustomerController.responseWrapper();
				responseObj = CustomerController.deleteaddress(requestbody);
				return JSON.serialize(responseObj);                
            }
            else if(apiname.equalsIgnoreCase('updateAddress')){
                CustomerController.responseWrapper responseObj = new CustomerController.responseWrapper();
                responseObj = CustomerController.updateDelAddress(requestBody);
                return JSON.serialize(responseObj);
            } 
            else if(apiname.equalsIgnoreCase('createLead')){
                CustomerController.LeadResponseWrapper responseObj = new CustomerController.LeadResponseWrapper();
                responseObj = CustomerController.insertLead(requestBody);
                return JSON.serialize(responseObj); 
            }
            else if(apiname.equalsIgnoreCase('updateContact')){
            	CustomerController.responseWrapper responseObj = new CustomerController.responseWrapper();
                responseObj = CustomerController.updateContact(requestBody);
                return JSON.serialize(responseObj);    
            }
            else if(apiname.equalsIgnoreCase('createLeadTask')){
            	CustomerController.LeadResponseWrapper responseObj = new CustomerController.LeadResponseWrapper();
                responseObj = CustomerController.createLeadTask(requestBody);
                return JSON.serialize(responseObj);    
            }
            
            
        }         
        return response;
        
    }
    
    /*global string inboundPatchRequestRouter(string apiname, string custid){
    	string response = '';
        return response;
    }*/
    
    
    //method to handle GET requests from web portal
    global string inboundGetRequestRouter(string apiName,string userId, String rego){
        string response = '';
        
        
        if(!string.isBlank(apiName)){
            if(apiName.equalsIgnoreCase('GetProfileDetails') && !string.isBlank(userId)){
                system.debug('Response....'+response);
                return response;
                
            } 
            
            else if(apiName.equalsIgnoreCase('')){
             	   
                
            }
        }
        
        return response;
    } 
    
    
}