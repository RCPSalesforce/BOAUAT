/*
@Purpose - Used to create new order and its line items for Sales Order
@CreatedBy - Centelon Team 
*/
public with sharing class NewOrder_CreateOrder {
    
    @AuraEnabled
    public static String createOrder(String orderData, String productData){
        Savepoint sp = Database.setSavepoint();
        try{
            
            Decimal TotalVal = 0.0;
            Decimal taxPercent = 0.0;
            Decimal taxAmt = 0.0;
            Decimal totalAmountWithTax = 0.0;
            Decimal prevtotalAmountWithTax = 0.0;
            Decimal amountDiff = 0.0;
            
            String oppSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_order').getRecordTypeId();
            
            AccountDetails ad = (AccountDetails)JSON.deserialize(orderData, AccountDetails.class);
            System.debug('ad ' + ad);
            
            List<OrderProducts> op = (List<OrderProducts>)JSON.deserialize(productData, List<OrderProducts>.class);
            
            Account acct = [SELECT Stop_Credit__c,Credit_Limit__c,Remaining_Credit_Balance__c,override_GST_rate__c,Onboarding_Status__c FROM Account WHERE Id=:ad.Id];
            System.debug(acct.Id);
            Opportunity oldOpp = new Opportunity();
            if(String.isNotBlank(ad.opportunityId)){
                oldOpp = [SELECT Id,TotalAmount__c,StageName,AccountId FROM Opportunity WHERE Id =: ad.opportunityId];
            }
			
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
                System.debug('unit price ' + Double.valueOf(b.UnitPrice));
                System.debug('qty ' + Double.valueOf(b.Quantity));
                System.debug('discount ' + Double.valueOf(b.discount));
                Decimal prodTotal = (Double.valueOf(b.UnitPrice) * Double.valueOf(b.Quantity)) - ((Double.valueOf(b.UnitPrice) * Double.valueOf(b.quantity)) * (Double.valueOf(b.discount)/100));
                TotalVal += prodTotal;                
            }
            
            taxAmt = TotalVal * (taxPercent/100);
            totalAmountWithTax = TotalVal + taxAmt;
                
            system.debug('Totalbal ' + TotalVal);
            system.debug('accRemainingCredBalance ' + acct.Remaining_Credit_Balance__c);
            
        /*   
            if(String.isNotBlank(oldOpp.Id) && (oldOpp.AccountId == ad.Id)){
                system.debug('totalAmountWithTax ' + totalAmountWithTax);
                system.debug('remaining cred ' + acct.Remaining_Credit_Balance__c);
                system.debug('oldOppTotalAmount__c' + oldOpp.TotalAmount__c);
                amountDiff = oldOpp.TotalAmount__c - totalAmountWithTax;
                system.debug('amountDiff ' + amountDiff);
                totalAmountWithTax = totalAmountWithTax - (oldOpp.TotalAmount__c);
                prevtotalAmountWithTax = totalAmountWithTax; 
                
                totalAmountWithTax = totalAmountWithTax < 0 ? - (totalAmountWithTax) : totalAmountWithTax;
                system.debug('totalAmountWithTax2 ' + totalAmountWithTax);
                //totalAmountWithTax = acct.Remaining_Credit_Balance__c <= 0 ? -1 : totalAmountWithTax;
                //totalAmountWithTax = oldOpp.TotalAmount__c - totalAmountWithTax;
                //system.debug('totalAmountWithTax3 ' + totalAmountWithTax);
            }
	
            if(op.size() == 0){
                return '{"emptyOrderProd":"Order cannot be created without stock item/s"}';
            }
            
            if((acct.Credit_Limit__c == null ||  acct.Credit_Limit__c == 0) && ad.selecteddOppStageVal == 'Closed Won' && acct.Stop_Credit__c == false){
                return '{"remainingCreditBalanceError":"Please enter a non zero credit limit for customer to proceed with the action"}';
            }
            
            
            if(String.isNotBlank(ad.opportunityId) && (amountDiff < 0) && acct.Remaining_Credit_Balance__c == 0 && acct.Stop_Credit__c == false && ad.selecteddOppStageVal == 'Closed Won'){
                system.debug('Test');
                return '{"creditBalanceError":"The Total Order Value is exceeding the remaining credit for this customer"}';
            }
            
            if((totalAmountWithTax > acct.Remaining_Credit_Balance__c) && String.isBlank(ad.opportunityId) && acct.Stop_Credit__c == false && ad.selecteddOppStageVal == 'Closed Won'){
                System.debug('value greater');
                return '{"creditBalanceError":"The Total Order Value is exceeding the remaining credit for this customer"}';
            }
            
            if((totalAmountWithTax < 0) && String.isNotBlank(ad.opportunityId) && (oldOpp.TotalAmount__c == totalAmountWithTax) && acct.Stop_Credit__c == false && ad.selecteddOppStageVal == 'Closed Won'){
                System.debug('value less');
                return '{"creditBalanceError":"The Total Order Value is exceeding the remaining credit for this customer"}';
            }
            */
            
            if(acct.Remaining_Credit_Balance__c != null){
                
                /*
                if(String.isNotBlank(String.valueOf(oldOpp.TotalAmount__c))){
                    totalAmountWithTax = prevtotalAmountWithTax < 0 ? prevtotalAmountWithTax : totalAmountWithTax;
                    //totalAmountWithTax = totalAmountWithTax - (oldOpp.TotalAmount__c);
                    //totalAmountWithTax = totalAmountWithTax < 0 ? - (totalAmountWithTax) : totalAmountWithTax;                    
                }
                */
                
                // Auto number custom setting
                ObjectAutoNumber__c t = ObjectAutoNumber__c.getInstance('Opportunity');
                Opportunity opp = new Opportunity();
                
                if(String.isBlank(ad.opportunityId)){
                    t.Number__c += 1;
                    update t;
                    opp.Name = String.valueOf(Integer.valueOf(t.Number__c));
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
                opp.On_hold__c = ad.onHold;
                opp.default_Location__c = ad.selecteddLocVal;
                opp.customer_order_number__c = ad.customerOrderNo;    
                opp.Street__c = ad.ShippingStreet;
                opp.city__c = ad.ShippingCity;
                opp.postal_code__c = ad.ShippingPostalCode;
                opp.state__c = ad.ShippingState;
                opp.Country__c = ad.ShippingCountry;
                opp.RecordTypeId = oppSalesRecordTypeId;
                opp.OwnerId = ad.salesPersonSelectedVal;
                if(String.isNotBlank(ad.selectedContactId)){
                    //opp.Contact_Email_id__c = [SELECT Email FROM Contact WHERE Id =: ad.selectedContactId].Email;
                    opp.Order_Placed_By__c = ad.selectedContactId;
                }
                if(String.isNotBlank(ad.closedLostReason)){
                    opp.Closed_Lost_Reason__c = ad.closedLostReason;
                }

                opp.CurrencyIsoCode = ad.CurrencyIsoCode;
                
                opp.subtotal__c = TotalVal;
                opp.tax_total__c = taxAmt;
                opp.Type = ad.oppTypeSelectedVal;
                opp.Order_Source__c = ad.oppOrderSource;
                 
                if(ad.selecteddOppStageVal == 'Closed Won' && ad.oppTypeSelectedVal == 'New Business' && acct.Onboarding_Status__c != 'Complete'){
                    opp.Onboarding_Target_Start_Date__c = Date.ValueOf(ad.onboardingStartDate);
                    opp.Onboarding_Target_Closure_Date__c = Date.ValueOf(ad.onboardingCloseDate);
                    opp.Onboarding_Point_of_Contact__c = ad.onboardingContact;
                    //to update onboarding details
                    acct.Onboarding_Target_Start_Date__c = opp.Onboarding_Target_Start_Date__c;
                    acct.Onboarding_Target_Closure_Date__c = opp.Onboarding_Target_Closure_Date__c;
                    acct.Onboarding_Point_of_Contact__c = opp.Onboarding_Point_of_Contact__c;
                    acct.Is_New_Business__c = true;
                    //acct.Sync_to_Exo__c = false;
                    update acct;
                }
                
                opp.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE IsStandard = true].Id; 

                upsert opp;
                System.debug('oppId ' + ad.opportunityId);
                
                List<OpportunityLineItem> oppL = new List<OpportunityLineItem>();
                
                if(String.isBlank(ad.opportunityId)){
                    if(op.size() > 0){
                        for(Integer i = 0; i < op.size(); i++){
                            OpportunityLineItem oppLIt = new OpportunityLineItem();
                            oppLIt.PricebookEntryId = op[i].Id;
                            oppLIt.UnitPrice = Double.valueOf(op[i].UnitPrice);
                            oppLIt.Quantity = Double.valueOf(op[i].Quantity);
                            oppLIt.Discount = Double.valueOf(op[i].Discount);
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
                        oppLIt.UnitPrice = Double.valueOf(op[i].UnitPrice);
                        oppLIt.Quantity = Double.valueOf(op[i].Quantity);
                        oppLIt.Discount = Double.valueOf(op[i].Discount);
                        oppLit.Description = op[i].stockDescription;
                        oppLIt.OpportunityId = ad.opportunityId;
                        oppL.add(oppLIt);
                    }
                    
                }
                System.debug('opp ' + opp.Id);

                upsert oppL;
                
                if((acct.Stop_Credit__c == false && ad.selecteddOppStageVal == 'Closed Won') && ((String.isBlank(ad.opportunityId)) || (String.isNotBlank(ad.opportunityId)))){                   
                    acct.Remaining_Credit_Balance__c = acct.Remaining_Credit_Balance__c - totalAmountWithTax;
                    system.debug('Test ' + acct.Remaining_Credit_Balance__c);
                    if(acct.Remaining_Credit_Balance__c < 0){
                        CalloutException e = new CalloutException();
                        e.setMessage('The Total Order Value is exceeding the remaining credit for this customer');
                        throw e;
                   }
                    else{
                        System.debug('updated ' + acct.Remaining_Credit_Balance__c);
                        update acct;
                    }
                    
                }                
                
                return '{"success":"' + opp.Id + '"}'; 
            } 
            else{
                return '{"unknownerror":"An unknown error occurred. Please contact your Administrator."}';
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_CreateOrder.createOrder',e.getLineNumber()); 
            if(e.getMessage() == 'The Total Order Value is exceeding the remaining credit for this customer'){
                return '{"creditBalanceError":"The Total Order Value is exceeding the remaining credit for this customer"}';
            }
            else{
            	return '{"error":"An error occurred. Please contact your Administrator."}';
            }
        }
        
    }
    
    @AuraEnabled
    public static String prodDetailsForLocation(String productId){
        try{
            List<Stock_Count_Per_Location__c> scpl = [SELECT Physical_Quantity__c,Minimum_Stock__c, Maximum_Stock__c, Stock_Location__r.Name, 
                                                      Stock_Item__r.Name FROM Stock_Count_Per_Location__c WHERE Stock_Item__c =: productId];
            if(!scpl.isEmpty()){
                return '{"success":' + JSON.serialize(scpl) + '}';
            } 
            else{
                return '{"success":""}'; 
            }
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_CreateOrder.prodDetailsForLocation',e.getLineNumber());
            return '{"error":"' + e.getMessage() + '"}';
        }
        
    }
    
    @AuraEnabled
    public static String prodQtyDetailsForLocation(String oppDefaultLocation, String productId){
        try{
            String physicalQty = '';
            String oppDefaultLocationLabel = SFToExoIntegrationUtility.getPicklistLabel('Opportunity','default_Location__c',oppDefaultLocation);
            List<Stock_Count_Per_Location__c> scpl = [SELECT Physical_Quantity__c,Stock_Item__r.isLookup__c FROM Stock_Count_Per_Location__c 
                                                      WHERE Stock_Item__c =: productId AND Stock_Location__r.Name =: oppDefaultLocationLabel AND Stock_Item__r.isLookup__c = false LIMIT 1];
            System.debug('scpl ' + scpl);
            if(scpl.isEmpty()){
                return '{"success":"no_details_available"}'; 
            } 
            else if(!scpl.isEmpty() && scpl[0].Stock_Item__r.isLookup__c == false){
                return '{"success":' + String.valueOf(scpl[0].Physical_Quantity__c) + '}';
            }
            else{
                return '{"success":""}'; 
            }
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_CreateOrder.prodQtyDetailsForLocation',e.getLineNumber());
            return '{"error":"' + e.getMessage() + '"}';
        }
        
    }
	
    
    
    /*
    // Sales Order    
    @AuraEnabled
    public static String productPriceForPolicy(String accId, String selectedProdList){
        
        try{
            System.debug('in class');
            
            Date td = Date.today();
            
            List<ListOfSelectedProducts> lsp = (List<ListOfSelectedProducts>)JSON.deserialize(selectedProdList, List<ListOfSelectedProducts>.class);
            system.debug('lsp ' + lsp); 
            
            
            List<Pricing_Policy_with_Customer__c> ppc = new List<Pricing_Policy_with_Customer__c>();
            String ppId = '';
            Pricing_Policy__c pp = new Pricing_Policy__c();
            //List<Pricing_Policy_Rules__c> ppr = new List<Pricing_Policy_Rules__c>();
            Map<String,Pricing_Policy_Rules__c> stockCodeList = new Map<String,Pricing_Policy_Rules__c>(); 
            Map<String,Pricing_Policy_Rules__c> stockGroupList = new Map<String,Pricing_Policy_Rules__c>(); 
            
            // get pricing policy using id from policy with customers using accountId from component
            if(String.isNotBlank(accId)){
                ppc = [SELECT Pricing_Policy__c FROM Pricing_Policy_with_Customer__c WHERE Customers__c =: accId];
                if(ppc.size() > 0){
                    ppId = ppc[0].Pricing_Policy__c;
                }
            }
            
            // check pricing policy for start date,end date,isActive - if true
            if(String.isNotBlank(ppId)){
                
                pp = [SELECT Id,Start_Date__c,End_Date__c,IS_Active__c FROM Pricing_Policy__c WHERE Id =: ppId];
                
                System.debug('pp ' + pp);
                System.debug('today ' + pp);
                
                // (pp.Start_Date__c >= Date.today()) && (pp.End_Date__c <= Date.today()) && - add this logic
                if((td >= pp.Start_Date__c) && (td <= pp.End_Date__c) && (pp.IS_Active__c == true)){
                    // get all pricing policy rules                 
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
                                    stockGroupList.put(h.Stock_Price_Group__c,h);
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
                        }
                    }
                    
                }
                System.debug('pricegr ' + lsp[i].priceGroup);
                if(stockGroupList.get(lsp[i].priceGroup) != null){
                    System.debug('Stock_Price_Group__c' + stockGroupList.get(lsp[i].priceGroup).Stock_Price_Group__c);
                    System.debug('priceGroup' + lsp[i].priceGroup);
                    if(lsp[i].priceGroup == stockGroupList.get(lsp[i].priceGroup).Stock_Price_Group__c){
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
                        }
                    }
                }
            }
            //return JSON.serialize(lsp);
            
            return 'success';
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_CreateOrder.productPriceForPolicy',e.getLineNumber());
            return 'error';
        }
        
    }
*/
     // changed for new selected products design
    // for sales order with search
    @AuraEnabled
    public static String productSearch(String searchString,String accId){
        System.debug('searchString ' + searchString);
        try{
            Id stdPriceBookId   = [SELECT id FROM Pricebook2 WHERE isStandard = true limit 1].Id;
            Account cust = [SELECT Id,Base_Price__c,CurrencyIsoCode FROM Account WHERE Id =: accId];
            List<PricebookEntry> pb = [SELECT Id,Name, Product2Id,Product2.pop_up_alert__c,Product2.Bill_of_Material__c FROM PricebookEntry WHERE Pricebook2Id =: stdPriceBookId 
                                       AND ((Product2.Name LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) OR 
                                       Product2.ProductCode LIKE :('%' + String.escapeSingleQuotes(searchString) + '%')) AND Product2.IsActive = true AND CurrencyIsoCode =: cust.CurrencyIsoCode LIMIT 10];
            
            String pbEntry = ''; 
            pbEntry = JSON.serialize(pb);
            
            return pbEntry;
        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_CreateOrder.productSearch',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
    
    }
    
     // changed for new selected products design
     // Pricing Policy For Selected Product
     // for sales order
    @AuraEnabled
    public static String productPriceForPolicy(String accId, String selectedProd){
        
        try{
            
            List<String> stockList = new List<String>();
            
            System.debug('accId' + accId);
            
            Date td = Date.today();
            SelectedProduct sp = (SelectedProduct)JSON.deserialize(selectedProd, SelectedProduct.class);
            //System.debug('sp ' + sp);
            //System.debug('PricebookEntry ' + sp.Id);
            
            /*               
            	Add pricebook entry queries for populating the unit price, description and fullbox coil
			*/
            Account cust = [SELECT Id,Base_Price__c,CurrencyIsoCode,Full_Box_Coil_Percent__c FROM Account WHERE Id =: accId];
            String basePrice = SFToExoIntegrationUtility.getPicklistLabel('account','base_price__c',cust.Base_Price__c);
            System.debug('basePrice ' + basePrice);
                                    
            List<SelectedStockBOMItems> selectedBOMItems = new List<SelectedStockBOMItems>();
            
            for(BOM_Line_Item__c b : [SELECT Name,Quantity__c,Description__c FROM BOM_Line_Item__c WHERE Stock_Item__c =: sp.productId AND Stock_Item__r.Bill_of_Material__c = true]){
                SelectedStockBOMItems sbi = new SelectedStockBOMItems();
                sbi.bName = b.Name;
                sbi.bQuantity = b.Quantity__c;
                sbi.bDescription= b.Description__c;
				selectedBOMItems.add(sbi);
            }
            
            sp.sbom = selectedBOMItems;
            
            PricebookEntry pb = [SELECT Id,Name,UnitPrice,Retail_Price__c,Contractor_Price__c,Trade_Price__c,Wholesale_Price__c,Dealer_Price__c,Bulk_Buy_Price__c,
                                       Product2.Id,Product2.ProductCode,Product2.Price_Group__c,Product2.Full_Coil_Size_metre__c,Product2.pop_up_alert__c,Product2.HideLineItem__c FROM PricebookEntry
                                       WHERE Id =: sp.Id];
            
            System.debug('PricebookEntry ' + pb);
            
            switch on basePrice.toLowerCase() {
                when 'retail'{
                    sp.UnitPrice = pb.Retail_Price__c;
                    sp.BasePrice = pb.Retail_Price__c;
                }
                when 'contractor'{
                    sp.UnitPrice = pb.Contractor_Price__c;
                    sp.BasePrice = pb.Contractor_Price__c;
                }
                when 'trade'{
                    sp.UnitPrice = pb.Trade_Price__c;
                    sp.BasePrice = pb.Trade_Price__c;
                }
                when 'wholesale'{
                    sp.UnitPrice = pb.Wholesale_Price__c;
                    sp.BasePrice = pb.Wholesale_Price__c;
                }
                when 'dealer'{
                    sp.UnitPrice = pb.Dealer_Price__c;
                    sp.BasePrice = pb.Dealer_Price__c;
                }
                when 'bulk buy'{
                    sp.UnitPrice = pb.Bulk_Buy_Price__c;
                    sp.BasePrice = pb.Bulk_Buy_Price__c;
                }
                when else { 
                    sp.UnitPrice = pb.UnitPrice;      
                }        
            }

            String productPriceGroupLabel = SFToExoIntegrationUtility.getPicklistLabel('Product2','Price_Group__c',pb.Product2.Price_Group__c); 
            
            sp.priceGroup = productPriceGroupLabel;			
            sp.stockDescription = pb.Product2.ProductCode;
            sp.fullCoilSize = pb.Product2.Full_Coil_Size_metre__c;
            sp.fullCoilSizeDiscount = cust.Full_Box_Coil_Percent__c;
            sp.productAlert = pb.Product2.pop_up_alert__c;
            sp.hideBOMItems = String.valueOf(pb.Product2.HideLineItem__c);
            
            List<Pricing_Policy_with_Customer__c> ppc = new List<Pricing_Policy_with_Customer__c>();
            String ppId = '';
            Pricing_Policy__c pp = new Pricing_Policy__c();
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
                    List<Pricing_Policy_Rules__c> allppr = [SELECT Id,StockCodeName__c,Stock_Price_Group__c,Price__c,Minimum_Quantity__c,Discount__c,Start_Date__c,Stop_Date__c
                                                            FROM Pricing_Policy_Rules__c WHERE Pricing_Policy__c =: pp.Id ];
                    if(allppr.size() > 0){
                        for(Pricing_Policy_Rules__c h : allppr){
                            if((td >= h.Start_Date__c) && (td <= h.Stop_Date__c)){
                                if(String.isNotBlank(h.StockCodeName__c)){                               
                                    stockCodeList.put(h.StockCodeName__c,h);
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
            //System.debug('stockCodeList ' + stockCodeList);
            //System.debug('stockGroupList ' + stockGroupList);
            
            /*
             *  If  stockCodeList and stockGroupList is not found then update the json that will be returned
            */
            
            if(stockCodeList.get(sp.stockCode) != null){
                    if(sp.stockCode == stockCodeList.get(sp.stockCode).StockCodeName__c){
                        sp.pricingPolicyRuleId = stockCodeList.get(sp.stockCode).Id;
                        if(stockCodeList.get(sp.stockCode).Price__c != null){
                            sp.BasePrice = stockCodeList.get(sp.stockCode).Price__c;
                            //system.debug('stcode price ' + sp.BasePrice);
                        }
                        else if(stockCodeList.get(sp.stockCode).Discount__c != null){
                            sp.Discount = stockCodeList.get(sp.stockCode).Discount__c;
                            //system.debug('stcode discount ' + sp.Discount);
                        }
                        if((stockCodeList.get(sp.stockCode).Minimum_Quantity__c != null) && (stockCodeList.get(sp.stockCode).Minimum_Quantity__c > 0)){
                            sp.Quantity = String.valueOf(stockCodeList.get(sp.stockCode).Minimum_Quantity__c);
                            sp.pricingPolicyquantity = sp.Quantity;
                        }
                    }
                    
                }
                //System.debug('pricegr ' + sp.priceGroup);
                if(stockGroupList.get(sp.priceGroup) != null){
                    //System.debug('Stock_Price_Group__c' + stockGroupList.get(sp.priceGroup).Stock_Price_Group__c);
                    //System.debug('priceGroup' + sp.priceGroup);               
                    if(sp.priceGroup == stockGroupList.get(sp.priceGroup).Stock_Price_Group__c){
                        sp.pricingPolicyRuleId = stockGroupList.get(sp.priceGroup).Id;
                        if(stockGroupList.get(sp.priceGroup).Price__c != null){
                            sp.BasePrice = stockGroupList.get(sp.priceGroup).Price__c;
                            //system.debug('stgroup price ' + sp.BasePrice);
                        }
                        else if(stockGroupList.get(sp.priceGroup).Discount__c != null){
                            sp.Discount = stockGroupList.get(sp.priceGroup).Discount__c;
                            //system.debug('stgroup discount ' + sp.Discount);
                        }
                        if((stockGroupList.get(sp.priceGroup).Minimum_Quantity__c != null) && (stockGroupList.get(sp.priceGroup).Minimum_Quantity__c > 0)){
                            sp.Quantity = String.valueOf(stockGroupList.get(sp.priceGroup).Minimum_Quantity__c);
                            sp.pricingPolicyquantity = sp.Quantity;
                        }
                    }
                }
            
            return JSON.serialize(sp);

        }
        catch(Exception e){
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'NewOrder_CreateOrder.productPriceForPolicy',e.getLineNumber());
            return '{"error":"'+e.getMessage()+'"}';
        }
    }
    
	// No changes
    public class AccountDetails{
        public String Id;
        public String AccountName;
        public String ShippingStreet;   
        public String ShippingCity; 
        public String ShippingPostalCode;   
        public String ShippingState;    
        public String ShippingCountry;
        public String OwnerId;
        public String CurrencyIsoCode;
        public String orderDate;
        public String dueDate;  
        public String reference;  
        public String internalNote;  
        public String selecteddLocVal;
        public Boolean onHold;
        public String customerOrderNo;
        public String selecteddOppStageVal;   
        public String selectedContactId;
        public String salesPersonSelectedVal;
        public String closedLostReason;
        public String opportunityId;
        public String oppTypeSelectedVal;
        public String oppOrderSource;
        
        public String onboardingStartDate;
        public String onboardingCloseDate;
        public String onboardingContact;
    }
    
    // No changes
    public class OrderProducts{
        public String Id;
        public String ProductCode;
        public String Quantity;
        public String stockDescription;
        public Double UnitPrice;
        public Double Discount;
        //public String opptId;
    }
    
    // No changes
    public class ListOfSelectedProducts{
        public String Id;
        private String productId;
        public String stockCode;
        public String quantity;
        public String priceGroup;
        public String stockDescription;
        public Double UnitPrice;
        public Double discount;
        public Double BasePrice;
    }
    
    // changed
    // for sales order
    public class SelectedProduct{
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
        public String isBOM;
        public List<SelectedStockBOMItems> sbom;
        public String hideBOMItems;
        //public String fullBoxCoilPercent;
        
    }
    
    // BOM line itemsfor sales order
    public class SelectedStockBOMItems{
        public String bName;
        public Double bQuantity;
        public String bDescription;
    }
    
    
}