public class Rest_ExoResponseWrapper {
    
    
    
    public class ResponseChild {
        public Integer SEQNO;
        public String SalesforceID;
        
    }
    //sales order response wrappers
  //sales order response wrappers
    public class salesOrderResponseWrapper{
        public String msg;
        public list<cls_salesOrderData> salesOrderData;
    }
    
    public class cls_salesOrderData {
        public cls_salesOrderResponseHdr salesOrdHdr;        
    }
    
    
    public class cls_salesOrderResponseHdr { 
        public Integer SEQNO;
        public String SalesforceID;
        public list<ResponseChild> salesOrdLines;
        public cls_salesOrderResponseHdr(){
            salesOrdLines = new list<responseChild>();
        }
    }
    
    
    //purchase order response wrappers
    public class purchaseOrderResponseWrapper{
        public String msg;
        public list<cls_purchOrderData> purchOrderData;
    }
    
    
    public class cls_purchOrderData {
        public cls_purchOrderResponseHdr purchOrdHdr;        
    }
    
    
    public class cls_purchOrderResponseHdr { 
        public Integer SEQNO;
        public String SalesforceID;
        public list<ResponseChild> purchOrdLines;
        public cls_purchOrderResponseHdr(){
            purchOrdLines = new list<responseChild>();
        }
    }
    
    // Account response wrapper
    public class accountResponseWrapper{
        public String msg;
        public list<cls_accountData> cr_accountData;
    }
    
    
    public class cls_accountData { 
        public Integer ACCNO;
        public String SalesforceID;
        
    }
    
    //Supplier or account response wrapper
    public class supplierAccountResponseWrapper{
        public String msg;
        public list<cls_supplierAccountData> accountData;
    }  
    
    public class cls_supplierAccountData { 
        public Integer ACCNO;
        public String SalesforceID;
        
    }
    
    //Contact response wrapper
    public class contactResponseWrapper{
        public String msg;
        public list<cls_contactData> contactData;
    }
    public class cls_contactData { 
        public Integer SEQNO;
        public String SalesforceID;
        
    }
    //Cr contact response wrapper
    public class CrcontactResponseWrapper{
        public String msg;
        public list<cr_contactData> contactData;
    }
    public class cr_contactData { 
        public string SEQNO;
        public integer ACCNO;
        public integer CONTACT_SEQNO;
        public string SalesforceId;
        
    }
    
    //Stock Item response wrapper
    public class stockItemResponseWrapper{
        public String msg;
        public list<cls_stockItemData> stockitemsData;
    }
    public class cls_stockItemData { 
        public String STOCKCODE;
        public String SalesforceID;
        public boolean isSuccess;
        
    }
    //Price book entry response wrapper
    public class priceBookResponseWrapper{
        public String msg;
        public list<cls_priceBookData> stockitemsData;
    }
    public class cls_priceBookData { 
        public Integer STOCKCODE;
        public String SalesforceID;
        public boolean isSuccess;
        
    }
//BOM response wrappers
    public class bomResponseWrapper{
        public String msg;
        public list<cls_bomData> bomData;
    }
    
    
    public class cls_bomData {
        public cls_bomResponseHdr bomHdr;        
    }
    
    
    public class cls_bomResponseHdr { 
        public Integer BILLCODE;
        public list<ResponseChild> bomLines;
        public cls_bomResponseHdr(){
            bomLines = new list<responseChild>();
        }
    }
    
    
}