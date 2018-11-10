/*
@Purpose - Used to create new order and its line items for Purchase Order
@CreatedBy - Centelon Team 
*/
public with sharing class NewOrder_CreatePurchaseOrder {
    
    @AuraEnabled
    public static String createOrder(String orderData, String productData){
        Savepoint sp = Database.setSavepoint();
        try{
            
            Decimal TotalVal = 0.0;
            Decimal taxPercent = 0.0;
            Decimal taxAmt = 0.0;
            //Decimal totalAmountWithTax = 0.0;
            
            String oppPurchaseRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Purchase_Order').getRecordTypeId();
            
            PurchaseOrderAccountDetails ad = (PurchaseOrderAccountDetails)JSON.deserialize(orderData, PurchaseOrderAccountDetails.class);
            
            List<OrderProducts> op = (List<OrderProducts>)JSON.deserialize(productData, List<OrderProducts>.class);
            
            System.debug('PurchaseOrderAccountDetails ' + ad);
            System.debug('orderProd ' + op);
            if(op.size() == 0){
                return '{"emptyProdList":"Order cannot be created without stock item/s"}';
            }   
            else{
                
                Account acct = [SELECT override_GST_rate__c FROM Account WHERE Id=:ad.Id];
               
                if(String.isNotBlank(acct.override_GST_rate__c)){
                    String gstRate = SFToExoIntegrationUtility.getPicklistLabel('Account','override_GST_rate__c',acct.override_GST_rate__c);
                    if(gstRate == 'Auto Select Rate'){
                        taxPercent = Decimal.valueOf(Label.CustomerAutoSelectGStRate);
                    }
                    else{
                        String[] gr = gstRate.split('%');
                        taxPercent = Decimal.valueOf(gr[0]);
                    }
                }
                
                for(OrderProducts b : op){
                    Decimal prodTotal = (Double.valueOf(b.packprice) * Double.valueOf(b.orderedQuantity)) - ((Double.valueOf(b.packprice) * Double.valueOf(b.orderedQuantity)) * (Double.valueOf(b.discount)/100));
                    TotalVal += prodTotal;
                }
                
                taxAmt = TotalVal * (taxPercent/100);
                //totalAmountWithTax = TotalVal + taxAmt;
                
                // Auto number custom setting
                ObjectAutoNumber__c t = ObjectAutoNumber__c.getInstance('Opportunity');
                Opportunity opp = new Opportunity();
                
                if(String.isBlank(ad.opportunityId)){
                    t.Purchase_Order_No__c += 1;
                    update t;
                    opp.Name = String.valueOf(Integer.valueOf(t.Purchase_Order_No__c));
                }
                
                if(String.isNotBlank(ad.opportunityId)){
                    opp.Id = ad.opportunityId;
                } 
                opp.AccountId = ad.Id;
                opp.CloseDate = (ad.dueDate != null || ad.dueDate != '') ? Date.valueOf(ad.dueDate) : Date.today();
                opp.Order_Date__c = (ad.orderDate != null || ad.orderDate != '') ? Date.valueOf(ad.orderDate) : Date.today();
                opp.StageName = ad.selecteddOppStageVal;
                opp.reference__c = ad.reference;
                opp.Internal_Note__c = ad.internalNote;
                opp.default_Location__c = ad.selecteddLocVal;
                opp.Street__c = ad.ShippingStreet;
                opp.city__c = ad.ShippingCity;
                opp.postal_code__c = ad.ShippingPostalCode;
                opp.state__c = ad.ShippingState;
                opp.Country__c = ad.ShippingCountry;
                opp.RecordTypeId = oppPurchaseRecordTypeId;
                opp.CurrencyIsoCode = ad.CurrencyIsoCode;
                opp.Lead_Time__c = ad.selectedLeadTime;
                opp.OwnerId = ad.salesPersonSelectedVal;
                if(String.isNotBlank(ad.selectedContactId)){
                    //opp.Contact_Email_id__c = [SELECT Email FROM Contact WHERE Id =: ad.selectedContactId].Email;
                    opp.Order_Placed_By__c = ad.selectedContactId;
                }
                if(String.isNotBlank(ad.closedLostReason)){
                    opp.Closed_Lost_Reason__c = ad.closedLostReason;
                }

                opp.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = 'Supplier Price book'].Id;
                opp.subtotal__c = TotalVal;
                opp.tax_total__c = taxAmt;
                
                upsert opp;
                
                List<OpportunityLineItem> oppL = new List<OpportunityLineItem>();                
                
                if(String.isBlank(ad.opportunityId)){
                    if(op.size() > 0){
                        for(Integer i = 0; i < op.size(); i++){
                            OpportunityLineItem oppLIt = new OpportunityLineItem();
                            oppLIt.PricebookEntryId = op[i].Id;
                            oppLIt.UnitPrice = Double.valueOf(op[i].packprice);
                            oppLIt.Quantity = Double.valueOf(op[i].orderedQuantity);
                            oppLIt.Discount = Double.valueOf(op[i].discount);
                            oppLit.Description = op[i].stockDescription;
                            oppLIt.OpportunityId = opp.Id;
                            oppL.add(oppLIt);
                        }
                    }
                }
                
                if(String.isNotBlank(ad.opportunityId)){
                    List<OpportunityLineItem> opl = [SELECT Id, Description, OpportunityId, PricebookEntryId,Product2Id, Product2.Name, Quantity, Product2.Price_Group__c, ProductCode, UnitPrice, 
                                             Discount FROM OpportunityLineItem WHERE OpportunityId =: ad.opportunityId];
                    
                    delete opl;
                    
                    for(Integer i = 0; i < op.size(); i++){
                        OpportunityLineItem oppLIt = new OpportunityLineItem();
                        oppLIt.PricebookEntryId = op[i].Id;
                        oppLIt.UnitPrice = Double.valueOf(op[i].packprice);
                        oppLIt.Quantity = Double.valueOf(op[i].orderedQuantity);
                        oppLIt.Discount = Double.valueOf(op[i].discount);
                        oppLit.Description = op[i].stockDescription;
                        oppLIt.OpportunityId = opp.Id;
                        oppL.add(oppLIt);
                    }
                    
                }
                
                
                /*if(op.size() > 0){
                    for(Integer i = 0; i < op.size(); i++){
                        OpportunityLineItem oppLIt = new OpportunityLineItem();
                        oppLIt.PricebookEntryId = op[i].Id;
                        oppLIt.UnitPrice = Double.valueOf(op[i].packprice);
                        oppLIt.Quantity = Double.valueOf(op[i].orderedQuantity);
                        oppLIt.Discount = Double.valueOf(op[i].discount);
                        oppLit.Description = op[i].stockDescription;
                        oppLIt.OpportunityId = opp.Id;
                        oppL.add(oppLIt);
                    }
                //}
                */
                System.debug('opp ' + opp.Id);
                
                upsert oppL;
                
                return '{"success":"' + opp.Id + '"}'; 
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_CreatePurchaseOrder.createOrder',e.getLineNumber()); 
            return '{"error":"An error occurred. Please contact your Administrator."}';
        }
        
    }
    
     // changed for new selected products design
     // for purchase order with search
    @AuraEnabled
    public static String poPriceBookDataWithSearch(String searchString,String accId){
        try{
            system.debug('accId ' + accId);       
            Id supplierPriceBookId   = [SELECT id FROM Pricebook2 WHERE Name = 'Supplier Price book' limit 1].Id;
            String CurrencyIsoCode = [SELECT CurrencyIsoCode FROM Account WHERE Id =: accId LIMIT 1].CurrencyIsoCode;
            List<PricebookEntry> pb = [SELECT Id,Name,UnitPrice,Product2.Id,Product2.Name,Product2.ProductCode,Product2.pop_up_alert__c,Product2.Stock_Item_Url__c,Product2.Price_Group__c FROM PricebookEntry WHERE Pricebook2Id =: supplierPriceBookId 
                                       AND ((Product2.Name LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) OR 
                                            Product2.ProductCode LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) AND Product2.IsActive = true AND CurrencyIsoCode =: CurrencyIsoCode LIMIT 10];        
            System.debug('pb ' + pb);
            return JSON.serialize(pb);  
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.poPriceBookDataWithSearch',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
        
    }
    
    @AuraEnabled
    public static String productPriceForPurchaseOrder(String accId, String selectedProd){        
        try{            
            PurchaseOrderSelectedProducts lsp = (PurchaseOrderSelectedProducts)JSON.deserialize(selectedProd, PurchaseOrderSelectedProducts.class);
 			
            System.debug('accId ' + accId);
            System.debug('prodId ' + lsp.productId);
            
            Map<Id,Stock_Supplier__c> stockSuppl = new Map<Id,Stock_Supplier__c>();

            // Stock supplier records based on supplier and stock selected
            for(Stock_Supplier__c m : [SELECT Id, Discount_Percentage__c, Pack_Price__c, Supplier_Code__c, Stock_Item__c, Stock_Item__r.EOQ__c, Stock_Item__r.ProductCode FROM Stock_Supplier__c WHERE Stock_Item__c =: lsp.productId AND Supplier_Name__c =: accId]){
                if(m != null){
                    stockSuppl.put(m.Stock_Item__c,m);                   
                }
            }
            
            System.debug('stockSuppl' + stockSuppl);
            
            if(stockSuppl.size() > 0){
                if(stockSuppl.get(lsp.productId) != null){                    
                    lsp.discount = stockSuppl.get(lsp.productId).Discount_Percentage__c;
                    lsp.packPrice = stockSuppl.get(lsp.productId).Pack_Price__c;				
                    lsp.supplierCode = stockSuppl.get(lsp.productId).Supplier_Code__c;
                    lsp.orderedQuantity = (stockSuppl.get(lsp.productId).Stock_Item__r.EOQ__c == null) ? String.valueOf(lsp.orderedQuantity) : String.valueOf(stockSuppl.get(lsp.productId).Stock_Item__r.EOQ__c);
                    lsp.quantity = lsp.orderedQuantity;
                    lsp.stockDescription = stockSuppl.get(lsp.productId).Stock_Item__r.ProductCode;
                }
            }
            System.debug('lsp' + lsp);
            return JSON.serialize(lsp);
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.productPriceForPurchaseOrder',e.getLineNumber());
            return '';
        }
    }
    
    public class PurchaseOrderAccountDetails{
        public String Id;
        public String AccountName;
        public String ShippingStreet;	
        public String ShippingCity;	
        public String ShippingPostalCode;	
        public String ShippingState;	
        public String ShippingCountry;
        //public String OwnerId;
        public String CurrencyIsoCode;
        public String orderDate;
        public String dueDate;	
        public String reference;  
        public String internalNote;  
        public String selecteddLocVal;
        public String selecteddOppStageVal;  
        public String selectedLeadTime;
        public String salesPersonSelectedVal;
        public String selectedContactId;
        public String closedLostReason;
        public String opportunityId;
    }
    
    public class OrderProducts{
        public String id;
        public String stockCode;
        public String orderedQuantity;
        public String stockDescription;
        public Double packprice;
        public Double discount;
    }
    
     public class PurchaseOrderSelectedProducts{
        public String Id;
        public String productId;
        public String stockCode;
        public String stockDescription;
        public String orderedQuantity;
        public String quantity;        
        public Double UnitPrice;
        public Double packPrice;
        public Double discount;
		public String supplierCode;
        public String productAlert; 
    }
    
    
}