/*
* Description - Class will work as a generic outbound rest controller for web portal as well as mobile app. From here request will be
kicked off and further directed to proper class using Rest_WebPortalOutboundHandler
* Author - Centelon Team 
*/

public class Rest_WebPortalOutbondController {
    
    public class SFtoWebPortal{
        
        @InvocableVariable
        public string sObjectName;
        @InvocableVariable
        Public string sObjectId; 
        }
    
    @InvocableMethod
    public static void callerMethod(List<SFtoWebPortal> obj){
        String objName;
        List<Id> sObjIds = new List<Id>();
        for(SFtoWebPortal sObj : obj){
            objName = sObj.sObjectName;
            sObjIds.add(sObj.sObjectId);
        }     
        
               
            if(objName == 'Contact'){
                sendContactUpdates(sObjIds);    
            }
            else if(objName == 'Product'){
                sendProductDetails(sObjIds);    
            }
            else if(objName == 'PricingPolicy' || objName == 'PricingPolicyRules'){
                sendPricingPolicyAndRulesDetails(sObjIds);	    
            }
            else if(objName == 'PricingPolicyWithCustomer'){
                sendPricingPolicyWithCustomerDetails(sObjIds);    
            }
            else if(objName == 'PricingPolicyWithCustomerDelete'){
                System.debug('PricingPolicyWithCustomerDelete');
                sendDeletedPricingPolicyWithCustomerDetails(sObjIds);    
            }
            else if(objName == 'Opportunity' || objName == 'OrderProduct'){
                    sendOrderWithOrderProductDetails(sObjIds);	 
                        }
            else if(objName == 'Account'){
                sendCustomerWithDeliveryAddress(sObjIds);    
            }             
    }
    
    //method to send contact plus account updates to external systems, triggered when - 
    // 1) Any user is activated or updated in SF wit change in specified fields.    
    public static void sendContactUpdates(list<id> contactIds){
        if(!contactIds.isEmpty()){
            System.debug('Contact Initiated');
            //Rest_WebPortalOutboundHandler.SendContactupdatesToPortal(contactIds);
            callOut(contactIds);
        }        
    }
    
    //method to send product details to external systems
    public static void sendProductDetails(list<id> stockItemIds){
        if(!stockItemIds.isEmpty()){
            callOutStockItems(stockItemIds);		    
        }        
    }
    
    //method to send pricing policy details to external systems
    public static void sendPricingPolicyAndRulesDetails(List<id> pricingPolicyIds){
        if(!pricingPolicyIds.isEmpty()){
            //Rest_WebPortalOutboundHandler.sendPricingPolicyDetailsToWebPortal(pricingPolicyIds);
            callOutPricingPolicy(pricingPolicyIds);
        }    
    }
    
    //method to send pricing policy with customer details to external systems
    public static void sendPricingPolicyWithCustomerDetails(List<id> pricingPolicyIdsWithCustomer){
        if(!pricingPolicyIdsWithCustomer.isEmpty()){
            //Rest_WebPortalOutboundHandler.sendCustomerWithPricingPolicyToPortal(pricingPolicyIdsWithCustomer);
            callOutProcingPolicyWithCustomer(pricingPolicyIdsWithCustomer);
        }
    }
    
    public static void sendDeletedPricingPolicyWithCustomerDetails(List<id> pPIdsWithCustomerDelete){
        if(!pPIdsWithCustomerDelete.isEmpty()){
            //Rest_WebPortalOutboundHandler.sendCustomerWithPricingPolicyToPortal(pricingPolicyIdsWithCustomer);
            system.debug('sendDeletedPricingPolicyWithCustomerDetails before callout');
            callOutPricingPolicyWithCustomerDelete(pPIdsWithCustomerDelete);
        }
    }
    
    public static void sendOrderWithOrderProductDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            //Rest_WebPortalOutboundHandler.sendOrderWithOrderProductDetailsToWebPortal(orderIds);
            callOutBoaOrder(orderIds);    
        }    
    }
    
    public static void sendCustomerWithDeliveryAddress(List<id> custIds){
        if(!custIds.isEmpty()){
            //Rest_WebPortalOutboundHandler.sendCustomerDetailsWithDeliveryAddress(custIds);
            callOutAccount(custIds);    
        }        
    }
    
    @future(callout=true)
    public static void callOut(list<id> contactIds){
        Rest_WebPortalOutboundHandler.SendContactupdatesToPortal(contactIds);
    }
    
    @future(callout=true)
    public static void callOutAccount(list<id> custIds){
        Rest_WebPortalOutboundHandler.sendCustomerDetailsWithDeliveryAddress(custIds);
    }
    
    @future(callout=true)
    public static void callOutPricingPolicy(List<id> pricingPolicyIds){
        Rest_WebPortalOutboundHandler.sendPricingPolicyDetailsToWebPortal(pricingPolicyIds);    
    }
    
    @future(callout=true)
    public static void callOutProcingPolicyWithCustomer(List<id> pricingPolicyIdsWithCustomer){
        Rest_WebPortalOutboundHandler.sendCustomerWithPricingPolicyToPortal(pricingPolicyIdsWithCustomer);    
    }
    
    @future(callout=true)
    public static void callOutPricingPolicyWithCustomerDelete(List<id> pPIdsWithCustomerDelete){
        system.debug('IN Callout');
        Rest_WebPortalOutboundHandler.sendCustomerWithPricingPolicyToPortalUponDeletion(pPIdsWithCustomerDelete);   
    }
    
    @future(callout=true)
    public static void callOutBoaOrder(List<Id> orderIds){
        Rest_WebPortalOutboundHandler.sendOrderWithOrderProductDetailsToWebPortal(orderIds);
        system.debug('IN web portal callout');
    }
    
    @future(callout=true)
    public static void callOutStockItems(List<id> stockItemIds){
        Rest_WebPortalOutboundHandler.sendProductDetailsToPortal(stockItemIds);	    
    }
    
    //for WebPortal batch
    public static void sendProductDetailsTrigger(List<Id> stockItemIds){
        Rest_WebPortalOutboundHandler.sendProductDetailsToPortal(stockItemIds);    
    }
    
    
    
}