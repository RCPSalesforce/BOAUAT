public with sharing class EditOrder_ProdList {
    
    // for sales order
    @AuraEnabled
    public static String salesOrderEdit(String oppId){
        try{
            List<String> opportunityInfo = new List<String>();
            
            Opportunity oppt = [SELECT Id, Order_Source__c, Street__c, city__c, postal_code__c, state__c, Country__c, Order_Date__c, CloseDate, 
                                default_Location__c, OwnerId, On_hold__c, Internal_Note__c, reference__c, customer_order_number__c, 
                                StageName, Closed_Lost_Reason__c, Order_Placed_By__c, Order_Placed_By__r.Name, Type,
                                Account.CurrencyIsoCode,Account.Full_Box_Coil_Percent__c FROM Opportunity WHERE Id =: oppId];
            opportunityInfo.add(JSON.serialize(oppt));
            
            List<OpportunityLineItem> opl = [SELECT Id, PricebookEntryId,Product2Id, Product2.Name, Quantity, Product2.Price_Group__c, 
                                             ProductCode, UnitPrice, Discount,Description,Product2.Full_Coil_Size_metre__c,Product2.pop_up_alert__c,
                                             Opportunity.Account.Full_Box_Coil_Percent__c FROM OpportunityLineItem WHERE OpportunityId  =: oppId];
            
            List<ListOfSelectedProducts> lsp = new List<ListOfSelectedProducts>();
            if(!opl.isEmpty()){   
                for(OpportunityLineItem j : opl){
                    ListOfSelectedProducts sp = new ListOfSelectedProducts();
                    sp.Id = j.PricebookEntryId;
                    sp.productId = j.Product2Id;
                    sp.stockCode = j.Product2.Name;
                    sp.quantity = String.valueOf(j.Quantity);
                    sp.priceGroup = j.Product2.Price_Group__c;
                    sp.stockDescription = j.Description;
                    sp.UnitPrice = j.UnitPrice;
                    sp.discount = j.Discount;
                    sp.BasePrice = j.UnitPrice;
                    sp.pricingPolicyPrice = String.valueOf(j.UnitPrice);
                    sp.pricingPolicyRuleId = '';
                    sp.pricingPolicyquantity = String.valueOf(j.Quantity);
                    sp.fullCoilSize = j.Product2.Full_Coil_Size_metre__c;
                    sp.prevCoilDiscStat = false;
                    sp.fullCoilSizeDiscount = j.Opportunity.Account.Full_Box_Coil_Percent__c;
                    sp.productAlert = j.Product2.pop_up_alert__c;
                    lsp.add(sp);
                }   
            }
            
            opportunityInfo.add(JSON.serialize(lsp));
            opportunityInfo.add(currentUserProfileName());
            return JSON.serialize(opportunityInfo);
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.poPriceBookDataWithSearch',e.getLineNumber());
            return '{"error":"An error occurred"}';
        }
        
    }
    
    // purchase order
    @AuraEnabled
    public static String purchaseOrderEdit(String oppId){
        try{
            List<String> opportunityInfo = new List<String>();
            
            Opportunity oppt = [SELECT Id, Street__c, city__c, postal_code__c, state__c, Country__c, Order_Date__c, CloseDate, 
                                default_Location__c, OwnerId, Internal_Note__c, reference__c, Lead_Time__c, StageName, 
                                Closed_Lost_Reason__c, Order_Placed_By__c, Order_Placed_By__r.Name, Account.CurrencyIsoCode, AccountId 
                                FROM Opportunity WHERE Id =: oppId];
            opportunityInfo.add(JSON.serialize(oppt));
            
            List<OpportunityLineItem> opl = [SELECT Id, PricebookEntryId,Product2Id, Product2.Name, Quantity, Product2.Price_Group__c, ProductCode, UnitPrice, 
                                             Discount,Description FROM OpportunityLineItem WHERE OpportunityId =: oppId];
            
            List<PurchaseOrderSelectedProducts> lsp = new List<PurchaseOrderSelectedProducts>();
            
            
            List<Id> prodId = new List<Id>();
            
            Map<Id,Stock_Supplier__c> stockSuppl = new Map<Id,Stock_Supplier__c>();
            
            for(OpportunityLineItem j : opl){
                prodId.add(j.product2Id);
            }

            // Stock supplier records based on supplier and stock selected
            for(Stock_Supplier__c m : [SELECT Id, Discount_Percentage__c, Pack_Price__c, Supplier_Code__c, Stock_Item__c, Stock_Item__r.EOQ__c FROM Stock_Supplier__c WHERE Stock_Item__c IN : prodId AND Supplier_Name__c =: oppt.AccountId]){
                if(m != null){
                    stockSuppl.put(m.Stock_Item__c,m);                   
                }
            }
           
            System.debug('stockSuppl' + stockSuppl);
			
            /*
                for(OpportunityLineItem j : opl){
                    PurchaseOrderSelectedProducts sp = new PurchaseOrderSelectedProducts();
                    if(stockSuppl.get(j.product2Id) != null){                        
                        sp.Id = j.PricebookEntryId;
                        sp.productId = j.Product2Id;
                        sp.stockCode = j.Product2.Name;
                        sp.quantity = String.valueOf(j.Quantity);
                        sp.orderedQuantity = (stockSuppl.get(j.product2Id).Stock_Item__r.EOQ__c == null) ? String.valueOf(j.quantity) : String.valueOf(stockSuppl.get(j.product2Id).Stock_Item__r.EOQ__c);
                        sp.stockDescription = j.Description;
                        sp.UnitPrice = j.UnitPrice;
                        sp.discount = stockSuppl.get(j.product2Id).Discount_Percentage__c;
                        sp.packPrice = stockSuppl.get(j.product2Id).Pack_Price__c;
                        sp.supplierCode = stockSuppl.get(j.product2Id).Supplier_Code__c;
                    }
                    else{
                        sp.Id = j.PricebookEntryId;
                        sp.productId = j.Product2Id;
                        sp.stockCode = j.Product2.Name;
                        sp.quantity = String.valueOf(j.Quantity);
                        sp.orderedQuantity = String.valueOf(j.Quantity);
                        sp.stockDescription = j.Description;
                        sp.UnitPrice = j.UnitPrice;
                        sp.discount = j.Discount;
                        sp.packPrice = j.UnitPrice;
                        sp.supplierCode = '';
                    }
                   lsp.add(sp);
                }
              */
            for(OpportunityLineItem j : opl){
                PurchaseOrderSelectedProducts sp = new PurchaseOrderSelectedProducts();
                sp.Id = j.PricebookEntryId;
                sp.productId = j.Product2Id;
                sp.stockCode = j.Product2.Name;
                sp.quantity = String.valueOf(j.Quantity);
                sp.orderedQuantity = String.valueOf(j.Quantity);
                sp.stockDescription = j.Description;
                sp.UnitPrice = j.UnitPrice;
                sp.discount = j.Discount;
                sp.packPrice = j.UnitPrice;
                if(stockSuppl.get(j.product2Id) != null && stockSuppl.get(j.product2Id).Supplier_Code__c != null){
                    sp.supplierCode = stockSuppl.get(j.product2Id).Supplier_Code__c;
                }
                else{
                    sp.supplierCode = '';
                }
                
                lsp.add(sp);
            }
            
            opportunityInfo.add(JSON.serialize(lsp));
            opportunityInfo.add(currentUserProfileName());
            return JSON.serialize(opportunityInfo);
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.poPriceBookDataWithSearch',e.getLineNumber());
            return '{"error":"An error occurred"}';
        }
        
    }
    
    @testVisible
    private Static String currentUserProfileName(){
        try{
            return [SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserId() AND isActive = true].Profile.Name;
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.userProfile',e.getLineNumber());
            return 'error';
        }
    }
    
    // for sales order
    private class ListOfSelectedProducts{
        public String Id;
        public String productId;
        public String stockCode;
        public String quantity;
        public String priceGroup;
        public String stockDescription;
        public Double UnitPrice;
        public Double discount;
        public Double BasePrice;
        public String pricingPolicyPrice;
        public String pricingPolicyRuleId;
        public String pricingPolicyquantity; 
        public String fullCoilSize;
        public Double fullCoilSizeDiscount;
        public Boolean prevCoilDiscStat;
        public String productAlert;
    }
    
      // for purchase order
    private class PurchaseOrderSelectedProducts{
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