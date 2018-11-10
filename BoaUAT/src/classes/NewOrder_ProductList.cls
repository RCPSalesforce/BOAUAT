/*
@Purpose - Used to fetch product details
@CreatedBy - Centelon Team 
*/
public with sharing class NewOrder_ProductList {
    
    // add error handling logic (for hose)
    @AuraEnabled
    public static List<Product2> productData(String searchString){
        return [SELECT Id, Name, ProductCode, Family FROM Product2 WHERE Name LIKE :('%' + String.escapeSingleQuotes(searchString) + '%') AND IsActive = true LIMIT 5];
    }
    
    /*
@AuraEnabled
public static Integer productUpdate(List<PricebookEntry> productList){
System.debug('productList ' + productList);
update productList;
return productList.size();
}
*/
    // for sales order without search
    @AuraEnabled
    public static String priceBookData(String accId){
        try{
            system.debug('accId ' + accId);
            
            Id stdPriceBookId   = [SELECT id FROM Pricebook2 WHERE isStandard = true limit 1].Id;
            Account cust = [SELECT Id,Base_Price__c,CurrencyIsoCode FROM Account WHERE Id =: accId];
            String basePrice = SFToExoIntegrationUtility.getPicklistLabel('account','base_price__c',cust.Base_Price__c);
            if(basePrice == null){
                return '{"requiredFieldMissing":"Please enter required fields in the customer record before creating order"}';
            }
            List<PricebookEntry> pb = [SELECT Id,Name,UnitPrice,Retail_Price__c,Contractor_Price__c,Trade_Price__c,Wholesale_Price__c,Dealer_Price__c,Bulk_Buy_Price__c,
                                       Product2.Id,Product2.Name,Product2.ProductCode,Product2.pop_up_alert__c,Product2.Stock_Item_Url__c,
                                       Product2.Price_Group__c,Product2.Full_Coil_Size_metre__c
                                       FROM PricebookEntry WHERE Pricebook2Id =: stdPriceBookId AND 
                                       Product2.Name LIKE :('%%') AND Product2.IsActive = true AND 
                                       CurrencyIsoCode =: cust.CurrencyIsoCode LIMIT 10];
            system.debug('PricebookEntry ' + pb);
            String pbEntry = ''; 
            String[] listProducts = new List<String>();
            listProducts.add(JSON.serialize(basePrice.toLowerCase()));
            listProducts.add(JSON.serialize(pb));
            pbEntry = JSON.serialize(listProducts);
            return pbEntry;
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.priceBookData',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
        
        /*
String productList = '';
if(String.isNotBlank(accId)){
Account cust = [SELECT Id,Base_Price__c,CurrencyIsoCode FROM Account WHERE Id =: accId];
String basePrice = SFToExoIntegrationUtility.getPicklistLabel('account','base_price__c',cust.Base_Price__c);
switch on basePrice {
when 'Trade'{
productList = 'SELECT Trade_Price__c,Product2.Name,Product2.ProductCode FROM PricebookEntry WHERE Pricebook2Id =: stdPriceBookId AND Product2.Name LIKE \'%%\' LIMIT 10';
List<PricebookEntry> pe = Database.query(productList);
//system.debug('pe ' + pe);
}

}
}
*/       
    }
    
    // for sales order with search
    @AuraEnabled
    public static String productSearch(String searchString,String accId){
        
        try{
            Id stdPriceBookId   = [SELECT id FROM Pricebook2 WHERE isStandard = true limit 1].Id;
            Account cust = [SELECT Id,Base_Price__c,CurrencyIsoCode FROM Account WHERE Id =: accId];
            String basePrice = SFToExoIntegrationUtility.getPicklistLabel('account','base_price__c',cust.Base_Price__c);
            List<PricebookEntry> pb = [SELECT Id,Name,UnitPrice,Retail_Price__c,Contractor_Price__c,Trade_Price__c,Wholesale_Price__c,Dealer_Price__c,Bulk_Buy_Price__c,
                                       Product2.Id,Product2.Name,Product2.ProductCode,Product2.pop_up_alert__c,Product2.Stock_Item_Url__c,
                                       Product2.Price_Group__c,Product2.Full_Coil_Size_metre__c FROM PricebookEntry WHERE Pricebook2Id =: stdPriceBookId 
                                       AND ((Product2.Name LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) OR 
                                            Product2.ProductCode LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) AND Product2.IsActive = true AND CurrencyIsoCode =: cust.CurrencyIsoCode LIMIT 10];
            
            
            String pbEntry = ''; 
            String[] listProducts = new List<String>();
            listProducts.add(JSON.serialize(basePrice.toLowerCase()));
            listProducts.add(JSON.serialize(pb));
            pbEntry = JSON.serialize(listProducts);
            
            return pbEntry;
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.productSearch',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
        
        
    }
    
    /*
@AuraEnabled
public static List<PricebookEntry> productSearch(String searchString,String accId){
Id stdPriceBookId   = [SELECT id FROM Pricebook2 WHERE isStandard = true limit 1].Id; 
Account cust = [SELECT Id,Base_Price__c,CurrencyIsoCode FROM Account WHERE Id =: accId];
List<PricebookEntry> pr =  [SELECT Id,Name,UnitPrice,Product2.Name,Product2.ProductCode,Product2.pop_up_alert__c FROM PricebookEntry WHERE Pricebook2Id =: stdPriceBookId 
AND ((Product2.Name LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) OR 
Product2.ProductCode LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) AND CurrencyIsoCode =: cust.CurrencyIsoCode LIMIT 10];
return pr;
}
*/
    
    // for sales order
    @AuraEnabled
    public static String productPriceForPolicy(String accId, String selectedProdList){
        
        try{
            //System.debug('selectedProdList' + selectedProdList);
            
            Date td = Date.today();
            
            List<ListOfSelectedProducts> lsp = (List<ListOfSelectedProducts>)JSON.deserialize(selectedProdList, List<ListOfSelectedProducts>.class);

            for(ListOfSelectedProducts k : lsp){
                String productPriceGroupLabel = SFToExoIntegrationUtility.getPicklistLabel('Product2','Price_Group__c',k.priceGroup); 
                k.priceGroup = productPriceGroupLabel;
                System.debug('priceGroup ' + k.priceGroup);
            }
            
            
            
            List<Pricing_Policy_with_Customer__c> ppc = new List<Pricing_Policy_with_Customer__c>();
            String ppId = '';
            Pricing_Policy__c pp = new Pricing_Policy__c();
            //List<Pricing_Policy_Rules__c> ppr = new List<Pricing_Policy_Rules__c>();
            Map<String,Pricing_Policy_Rules__c> stockCodeList = new Map<String,Pricing_Policy_Rules__c>(); 
            Map<String,Pricing_Policy_Rules__c> stockGroupList = new Map<String,Pricing_Policy_Rules__c>(); 
            
            // get pricing policy using id from policy with customers using accountId from component
            if(String.isNotBlank(accId)){
                    for(Pricing_Policy_with_Customer__c c : [SELECT Pricing_Policy__c,Pricing_Policy__r.Start_Date__c,Pricing_Policy__r.End_Date__c,Pricing_Policy__r.IS_Active__c FROM Pricing_Policy_with_Customer__c WHERE Customers__c =: accId]){
                        if((td >= c.Pricing_Policy__r.Start_Date__c) && (td <= c.Pricing_Policy__r.End_Date__c) && (c.Pricing_Policy__r.IS_Active__c == true)){
                            ppId = c.Pricing_Policy__c;
                            break;
                        }
                    }                    
            }
            
            // check pricing policy for start date,end date,isActive - if true
            if(String.isNotBlank(ppId)){
                
                pp = [SELECT Id,Start_Date__c,End_Date__c,IS_Active__c FROM Pricing_Policy__c WHERE Id =: ppId];
                
                System.debug('pp ' + pp);
                
                // (pp.Start_Date__c >= Date.today()) && (pp.End_Date__c <= Date.today()) && - add this logic
                if((td >= pp.Start_Date__c) && (td <= pp.End_Date__c) && (pp.IS_Active__c == true)){
                    // get all pricing policy rules	  
                    System.debug('pricing policy ' + pp);              
                    List<Pricing_Policy_Rules__c> allppr = [SELECT Id,Stock_Code__c,Stock_Price_Group__c,Price__c,Minimum_Quantity__c,Discount__c,Start_Date__c,Stop_Date__c
                                                            FROM Pricing_Policy_Rules__c WHERE Pricing_Policy__c =: pp.Id ];
                    if(allppr.size() > 0){
                        for(Pricing_Policy_Rules__c h : allppr){
                            if((td >= h.Start_Date__c) && (td <= h.Stop_Date__c)){
                                if(String.isNotBlank(h.Stock_Code__c)){                               
                                    stockCodeList.put(h.Stock_Code__c,h);
                                }
                                if(String.isNotBlank(h.Stock_Price_Group__c)){
                                    String pprStockPriceGroupLabel = SFToExoIntegrationUtility.getPicklistLabel('Pricing_Policy_Rules__c','Stock_Price_Group__c',h.Stock_Price_Group__c); 
                                    System.debug('pprStockPriceGroupLabel ' + pprStockPriceGroupLabel);
                                    h.Stock_Price_Group__c = pprStockPriceGroupLabel;
                                    stockGroupList.put(pprStockPriceGroupLabel,h);
                                }                            
                                //ppr.add(h);
                            }
                        }
                    }
                    
                }
            }
            
            //System.debug('ppr ' + ppr);
            System.debug('stockCodeList ' + stockCodeList);
            System.debug('stockGroupList ' + stockGroupList);
            
            
            for( Integer i=0 ;i<lsp.size(); i++){
                //String priceGroupLabel = SFToExoIntegrationUtility.getPicklistLabel('Product2','Price_Group__c',lsp[i].priceGroup);
                //lsp[i].priceGroup = priceGroupLabel;
                if(stockCodeList.get(lsp[i].stockCode) != null){
                    if(lsp[i].stockCode == stockCodeList.get(lsp[i].stockCode).Stock_Code__c){
                        lsp[i].pricingPolicyRuleId = stockCodeList.get(lsp[i].stockCode).Id;
                        if(stockCodeList.get(lsp[i].stockCode).Price__c != null){
                            lsp[i].BasePrice = stockCodeList.get(lsp[i].stockCode).Price__c;
                            system.debug('stcode price ' + lsp[i].BasePrice);
                        }
                        else if(stockCodeList.get(lsp[i].stockCode).Discount__c != null){
                            lsp[i].Discount = stockCodeList.get(lsp[i].stockCode).Discount__c;
                            system.debug('stcode discount ' + lsp[i].Discount);
                        }
                        if((stockCodeList.get(lsp[i].stockCode).Minimum_Quantity__c != null) && (stockCodeList.get(lsp[i].stockCode).Minimum_Quantity__c > 0)){
                            lsp[i].Quantity = String.valueOf(stockCodeList.get(lsp[i].stockCode).Minimum_Quantity__c);
                            lsp[i].pricingPolicyquantity = lsp[i].Quantity;
                        }
                    }
                    
                }
                System.debug('pricegr ' + lsp[i].priceGroup);
                if(stockGroupList.get(lsp[i].priceGroup) != null){
                    System.debug('Stock_Price_Group__c' + stockGroupList.get(lsp[i].priceGroup).Stock_Price_Group__c);
                    System.debug('priceGroup' + lsp[i].priceGroup);               
                    if(lsp[i].priceGroup == stockGroupList.get(lsp[i].priceGroup).Stock_Price_Group__c){
                        lsp[i].pricingPolicyRuleId = stockGroupList.get(lsp[i].priceGroup).Id;
                        if(stockGroupList.get(lsp[i].priceGroup).Price__c != null){
                            lsp[i].BasePrice = stockGroupList.get(lsp[i].priceGroup).Price__c;
                            system.debug('stgroup price ' + lsp[i].BasePrice);
                        }
                        else if(stockGroupList.get(lsp[i].priceGroup).Discount__c != null){
                            lsp[i].Discount = stockGroupList.get(lsp[i].priceGroup).Discount__c;
                            system.debug('stgroup discount ' + lsp[i].Discount);
                        }
                        if((stockGroupList.get(lsp[i].priceGroup).Minimum_Quantity__c != null) && (stockGroupList.get(lsp[i].priceGroup).Minimum_Quantity__c > 0)){
                            lsp[i].Quantity = String.valueOf(stockGroupList.get(lsp[i].priceGroup).Minimum_Quantity__c);
                            lsp[i].pricingPolicyquantity = lsp[i].Quantity;
                        }
                    }
                }
            }
            
            return JSON.serialize(lsp);
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.productPriceForPolicy',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
        
        //System.debug('pricegr ' + lsp);
        
        // check for every product whether -
        // check for start date,enddate
        // it matches stockcode or stock price depending which field is present.
        // get price or discount on which field is present
        // get minimum qty if present
        
        
        // return the result 
        
        
        //Pop up alert based on stock selection - This can be done on save as it will have qty
        // for every product get stock location that matches the account and get its physical qty
        // if selected qty is greater than physical qty add alert attribute
        
    }
    
    // for purchase order without search
    @AuraEnabled
    public static String poPriceBookDataWithoutSearch(String accId){
        try{
            system.debug('accId ' + accId);       
            Id supplierPriceBookId   = [SELECT id FROM Pricebook2 WHERE Name = 'Supplier Price book' limit 1].Id;
            String CurrencyIsoCode = [SELECT CurrencyIsoCode FROM Account WHERE Id =: accId LIMIT 1].CurrencyIsoCode;
            List<PricebookEntry> pb = [SELECT Id,Name,UnitPrice,Product2.Id,Product2.Name,Product2.ProductCode,Product2.pop_up_alert__c,Product2.Stock_Item_Url__c FROM PricebookEntry WHERE Pricebook2Id =: supplierPriceBookId AND Product2.Name LIKE :('%%') AND Product2.IsActive = true AND CurrencyIsoCode =: CurrencyIsoCode LIMIT 10];        
            return JSON.serialize(pb); 
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.poPriceBookDataWithoutSearch',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
        
    }
    
    
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
            return JSON.serialize(pb);  
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_ProductList.poPriceBookDataWithSearch',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
        
    }
    
    // for purchase order
    @AuraEnabled
    public static String productPriceForPurchaseOrder(String accId, String selectedProdList){        
        try{            
            List<PurchaseOrderSelectedProducts> lsp = (List<PurchaseOrderSelectedProducts>)JSON.deserialize(selectedProdList, List<PurchaseOrderSelectedProducts>.class);
            
            List<Id> prodId = new List<Id>();
            
            Map<Id,Stock_Supplier__c> stockSuppl = new Map<Id,Stock_Supplier__c>();
            
            for(PurchaseOrderSelectedProducts j : lsp){
                prodId.add(j.productId);
            }
            
            
            // Stock supplier records based on supplier and stock selected
            for(Stock_Supplier__c m : [SELECT Id, Discount_Percentage__c, Pack_Price__c, Supplier_Code__c, Stock_Item__c, Stock_Item__r.EOQ__c FROM Stock_Supplier__c WHERE Stock_Item__c IN : prodId AND Supplier_Name__c =: accId]){
                if(m != null){
                    stockSuppl.put(m.Stock_Item__c,m);                   
                }
            }
            
            System.debug('stockSuppl' + stockSuppl);
            
            if(stockSuppl.size() > 0){
                for(PurchaseOrderSelectedProducts e : lsp){                    
                    if(stockSuppl.get(e.productId) != null){
                        System.debug('test ' + e);
                        e.discount = stockSuppl.get(e.productId).Discount_Percentage__c;
                        e.packPrice = stockSuppl.get(e.productId).Pack_Price__c;				
                        e.supplierCode = stockSuppl.get(e.productId).Supplier_Code__c;
                        e.orderedQuantity = (stockSuppl.get(e.productId).Stock_Item__r.EOQ__c == null) ? String.valueOf(e.orderedQuantity) : String.valueOf(stockSuppl.get(e.productId).Stock_Item__r.EOQ__c);
                        e.quantity = e.orderedQuantity;
                    }
                   
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
    
    // for sales order
    public class ListOfSelectedProducts{
        public String Id;
        public String productId;
        public String stockCode;
        public String quantity;
        public String priceGroup;
        public String stockDescription;
        public Double UnitPrice;
        public Double discount;
        public Double BasePrice;
        public String pricingPolicyPrice;  // additional
        public String pricingPolicyRuleId; // additional
        public String pricingPolicyquantity; // additional
        public String fullCoilSize;
        public Boolean prevCoilDiscStat;
        //public String fullBoxCoilPercent;
        
    }
    
     // for purchase order
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
    }
    
}