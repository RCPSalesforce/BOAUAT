public class Rest_ExoOutbondController {
    /** Description - Class will work as a generic outbound rest controller for Exo as well as mobile app. From here request will be
kicked off and further directed to proper class using Rest_ExoOutboundHandler
* Author - Centelon Team 
*/
    public class Exo{
        
        @InvocableVariable
        public string sObjectName;
        @InvocableVariable
        Public string sObjectId; 
        @InvocableVariable
        Public string recordTypeid;
        
    }
    
    @InvocableMethod
    public static void callerMethod(List<Exo> obj){
        String objName;
        string objRecordType;
        List<Id> sObjIds = new List<Id>();
        for(Exo sObj : obj){
            objName = sObj.sObjectName;
            sObjIds.add(sObj.sObjectId);
            objRecordType = sObj.recordTypeid;
        }
        if(objName == 'Opportunity' || objName == 'OrderProduct'){
            If(objRecordType == System.Label.BoaSalesOrderRecordType){
                system.debug('record type' + objRecordType);
                sendOrderWithOrderProductDetails(sObjIds);	 
            }
            
            else {
                //system.debug('record type purchase'+objRecordType);
                sendPurchaseOrderWithOrderProductDetails(sObjIds);
            }
        }
        if(objName == 'Account'){
            If(objRecordType == System.Label.BoaSupplierCustomer){
                system.debug('record type' + objRecordType);
              sendCreditAccountDetails(sObjIds);
            }
            
            else if (objRecordType == System.Label.BoaEnterpriseCustomer){
                //system.debug('record type purchase'+objRecordType);
                   sendDebitAccountDetails(sObjIds);	
            }
        } 
        if(objName == 'Contact'){
            sendContactDetails(sObjIds);
        }
        if(objName == 'StockItem'){
            
            sendStockItemDetails(sObjIds);
        }
         if(objName == 'PriceBook'){
            sendPriceBookDetails(sObjIds);
        }
        if(objName == 'BOM'){
            sendBOMDetails(sObjIds);
        }
        If(objName == 'Stock Supplier'){
            sendStockSupplierDetails(sObjIds);
        }
        
    }
    public static void sendStockSupplierDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutStockSupplier(orderIds);    
        }    
    }
    public static void sendBOMDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutBOM(orderIds);    
        }    
    }
     public static void sendPriceBookDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutPriceBook(orderIds);    
        }    
    }
    public static void sendOrderWithOrderProductDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutBoaOrderSales(orderIds);    
        }    
    }
    public static void sendPurchaseOrderWithOrderProductDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutBoaOrderPurchase(orderIds);    
        }    
    }
    public static void sendDebitAccountDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callDebitOutAccount(orderIds);    
        }    
    }
    public static void sendCreditAccountDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutCreditAccount(orderIds);    
        }    
    }
    public static void sendContactDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutContact(orderIds);    
        }    
    }
    public static void sendStockItemDetails(List<id> orderIds){
        if(!orderIds.isEmpty()){
            callOutStockItem(orderIds);    
        }    
    }
    //Price book
     @future(callout=true)
    public static void callOutPriceBook(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertStockItemDetailsToEXO(orderIds);
        
    }
    //Stock Supplier
     @future(callout=true)
    public static void callOutStockSupplier(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertStockSupplierDetailsToEXO(orderIds);
        
    }
    //BOM
    @future(callout=true)
    public static void callOutBOM(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertBOMToExo(orderIds);
        
    }
     //Stock item
     @future(callout=true)
    public static void callOutStockItem(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertStockItemDetailsToEXO(orderIds);
        
    }
    
    //Supplier account
    @future(callout=true)
    public static void callDebitOutAccount(List<Id> orderIds){
        Rest_ExoOutboundHandler.upertAccountDetailsToEXO(orderIds);
        
    }
    //Enterpprise account
    @future(callout=true)
    public static void callOutCreditAccount(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertCreditAccountDetailsToEXO(orderIds);
        
    }
    //Contact
    @future(callout=true)
    public static void callOutContact(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertContactDetailsToEXO(orderIds);
        
    }
    //Sales order
    @future(callout=true)
    public static void callOutBoaOrderSales(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertSalesOrderDetailsToEXO(orderIds);
        
    }
    //Purchase order
    @future(callout=true)
    public static void callOutBoaOrderPurchase(List<Id> orderIds){
        Rest_ExoOutboundHandler.upsertPurchaseOrderDetailsToEXO(orderIds);
        
    }
    
    
}