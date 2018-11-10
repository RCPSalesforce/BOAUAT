global with sharing class BoaOpportunityClone {
    @InvocableMethod
    global static List<Apex_Result> Opportunityreplicate(List<string> oppId){ 
        Savepoint sp = Database.setSavepoint();
        
        String opportunityId = '';
        String oppRecType = '';
        String accName = '';
        
        List<Apex_Result> cloneStat = new List<Apex_Result>();
        Apex_Result ar = new Apex_Result();
        
        try{
            
            String[] oppDetails = oppId[0].split('-');
            System.debug('oppRecType' + oppDetails[1]);
            System.debug('order' + oppDetails.size());
            
            Opportunity oldOpp = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id=: oppDetails[0]];
            //purchase to purchase
            if(oldOpp.RecordType.DeveloperName == 'Purchase_Order' && oppDetails[1] == 'Purchase Order'){ // change condition 
                opportunityId = oppDetails[0];
                oppRecType = oppDetails[1];
                accName = oppDetails[2];
                System.debug('purchase');
                Opportunity opp1 = [SELECT AccountId,Id,Amount,BOA_Order__c,Internal_Note__c,CurrencyIsoCode,city__c,CloseDate,Country__c,customer_order_number__c,default_Location__c,Description,ExpectedRevenue,Lead_Time__c,
                                    Name,On_hold__c,Order_Date__c,Order_Placed_By__c,Order_Source__c,OwnerId,Parent_Order__c,Payment_type__c,postal_code__c,Probability,RecordTypeId,reference__c,
                                    StageName,state__c,Street__c,subtotal__c,tax_total__c,TotalOpportunityQuantity,Type FROM Opportunity Where Id=:opportunityId ];  
                
                
                Account acc = [SELECT override_GST_rate__c,Remaining_Credit_Balance__c,Sea_Freight_Lead_Time__c,Air_Freight_Lead_Time__c FROM Account WHERE Id =: opp1.AccountId];
                
                Decimal daysToAddToCloseDate = 0;
                if(opp1.Lead_Time__c == 'Sea Freight Lead Time'){
                    daysToAddToCloseDate = acc.Sea_Freight_Lead_Time__c == null ? 0 : acc.Sea_Freight_Lead_Time__c;
                }
                else if(opp1.Lead_Time__c == 'Air Freight Lead Time'){
                    daysToAddToCloseDate = acc.Air_Freight_Lead_Time__c == null ? 0 : acc.Air_Freight_Lead_Time__c;
                }
                
                ObjectAutoNumber__c t1 = ObjectAutoNumber__c.getInstance('Opportunity');
                
                t1.Purchase_Order_No__c += decimal.valueof('1');
                
                update t1;
                
                Opportunity Oppt1 = new Opportunity();  
                Oppt1.Name=string.valueof(math.round(t1.Purchase_Order_No__c));
                Oppt1.OwnerId = opp1.OwnerId;
                Oppt1.AccountId = opp1.AccountId;
                Oppt1.Order_Date__c = date.today();
                Date cd = opp1.CloseDate;
                cd = cd.addDays(Integer.valueOf(daysToAddToCloseDate));
                Oppt1.CloseDate = cd;
                Oppt1.Lead_Time__c = opp1.Lead_Time__c;
                Oppt1.default_Location__c = opp1.default_Location__c;
                // Oppt1.tax_total__c = 0.00;
                //   Oppt1.Amount = opp1.Amount;
                // Oppt1.subtotal__c = 0.00;
                Oppt1.StageName = 'Prospecting';
                Oppt1.Parent_Order__c = opp1.Id;
                Oppt1.CurrencyIsoCode = opp1.CurrencyIsoCode;
                Oppt1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Purchase_Order').getRecordTypeId();
                insert Oppt1;
                
                
                
                Account accId = [select id from account where name=:accName]; 
                if(accId.id !=null)
                {
                    oppt1.AccountId = accId.id;
                }
                update oppt1;  // Working
                
                
                // changes
                
                List<Id> prodId = new List<Id>();
                
                Map<Id,Stock_Supplier__c> stockSuppl = new Map<Id,Stock_Supplier__c>();
                
                List<OpportunityLineItem> oliList = [Select Product2Id,PricebookEntryId,UnitPrice,Quantity,Discount,OpportunityId,Description FROM OpportunityLineItem WHERE OpportunityId =: opp1.Id];
                for(OpportunityLineItem oli : oliList){
                    prodId.add(oli.Product2Id);
                }
                
                System.debug('oliList ' + oliList);
                
                // Stock supplier records based on supplier and stock selected
                for(Stock_Supplier__c m : [SELECT Id, Discount_Percentage__c, Pack_Price__c, Supplier_Code__c, Stock_Item__c, Stock_Item__r.EOQ__c FROM Stock_Supplier__c WHERE Stock_Item__c IN : prodId AND Supplier_Name__c =: accId.Id]){
                    if(m != null){
                        stockSuppl.put(m.Stock_Item__c,m);                   
                    }
                }
                
                System.debug('stockSuppl' + stockSuppl);
                
                List<OpportunityLineItem> newOli = new List<OpportunityLineItem>();
                //if(stockSuppl.size() > 0){
                for(OpportunityLineItem e : oliList){             
                    OpportunityLineItem m = new OpportunityLineItem();
                    if(stockSuppl.get(e.product2Id) != null){                        
                        m.PricebookEntryId = e.PricebookEntryId;
                        m.UnitPrice = stockSuppl.get(e.product2Id).Pack_Price__c;
                        m.Quantity = Decimal.valueOf((stockSuppl.get(e.product2Id).Stock_Item__r.EOQ__c == null) ? String.valueOf(e.Quantity) : String.valueOf(stockSuppl.get(e.product2Id).Stock_Item__r.EOQ__c));
                        m.Discount = stockSuppl.get(e.product2Id).Discount_Percentage__c;
                        m.Description = e.Description == null ? '' : e.Description;
                        m.OpportunityId = Oppt1.Id;
                    }
                    else{                        
                        m.PricebookEntryId = e.PricebookEntryId;
                        m.UnitPrice = e.UnitPrice;
                        m.Quantity = e.Quantity;
                        m.Discount = e.Discount == null ? 0 : e.Discount;
                        m.Description = e.Description == null ? '' : e.Description;
                        m.OpportunityId = Oppt1.Id;
                    }
                    newOli.add(m);        
                    
                    
                }
                //}
                
                System.debug('newoliList ' + newOli);            
                insert newOli;      
                Account acct = [SELECT override_GST_rate__c,Remaining_Credit_Balance__c FROM Account WHERE Id =: oppt1.AccountId];
                Decimal TotalVal = 0.0;
                Decimal taxPercent = 0.0;
                Decimal taxAmt = 0.0;
                Decimal totalAmountWithTax = 0.0;
                if(String.isNotBlank(acct.override_GST_rate__c) && acct.override_GST_rate__c != 'Auto Select Rate'){
                    String gstRate = acct.override_GST_rate__c;
                    String[] gr = gstRate.split('%');
                    taxPercent = Decimal.valueOf(gr[0]);
                    
                }
                System.debug('m' + newOli);
                for(OpportunityLineItem r : newOli){
                    Decimal prodTotal = (Double.valueOf(r.UnitPrice) * Double.valueOf(r.Quantity)) - ((Double.valueOf(r.UnitPrice) * Double.valueOf(r.quantity)) * (Double.valueOf(r.Discount)/100));
                    TotalVal += prodTotal;
                    taxAmt = TotalVal * (taxPercent/100);
                    totalAmountWithTax = TotalVal + taxAmt;
                    
                    oppt1.subtotal__c = TotalVal;
                    oppt1.tax_total__c = taxAmt;
                    
                    update oppt1;
                }
                
                ar.ReturnCode = '1';
                ar.cloneOppId = Oppt1.Id; 	
                cloneStat.add(ar);
                return cloneStat;
                
            }
            
            //Sales to sales
            
            else if(oldOpp.RecordType.DeveloperName == 'Sales_Order' && oppDetails[1] == 'Sales order'){
                System.debug('sales');
                
                opportunityId = oppDetails[0];
                oppRecType = oppDetails[1];
                System.debug('sales');
                Opportunity opp = [SELECT Id,Amount,BOA_Order__c,Internal_Note__c,CurrencyIsoCode,city__c,CloseDate,Country__c,customer_order_number__c,default_Location__c,Description,ExpectedRevenue,Lead_Time__c,
                                   Name,On_hold__c,Order_Date__c,Order_Placed_By__c,Order_Source__c,OwnerId,Parent_Order__c,Payment_type__c,postal_code__c,Probability,RecordTypeId,reference__c,
                                   StageName,state__c,Street__c,subtotal__c,tax_total__c,TotalOpportunityQuantity,Type,AccountId FROM Opportunity Where Id=:opportunityId ];
                
                ObjectAutoNumber__c t = ObjectAutoNumber__c.getInstance('Opportunity');
                t.Number__c += 1;
                update t;  
                
                Opportunity Oppt = new Opportunity();
                oppt.OwnerId = opp.OwnerId;
                oppt.Name = string.valueof(math.round(t.Number__c));
                oppt.AccountId = opp.AccountId;
                oppt.Order_Date__c = Date.Today();
                oppt.CloseDate =  Date.Today();
                oppt.StageName = 'Prospecting';
                oppt.default_Location__c= opp.default_Location__c;
                oppt.Internal_Note__c = opp.Internal_Note__c;
                oppt.reference__c = opp.reference__c;
                oppt.On_hold__c = False;
                oppt.Order_Placed_By__c = opp.Order_Placed_By__c;
                oppt.tax_total__c = opp.tax_total__c;
                oppt.Amount = opp.Amount;
                oppt.subtotal__c = opp.subtotal__c;
                oppt.state__c = opp.state__c;
                oppt.Street__c = opp.Street__c;
                oppt.postal_code__c = opp.postal_code__c;
                oppt.city__c = opp.city__c;
                oppt.Parent_Order__c = opp.Id;
                oppt.Type = opp.Type;
                //oppt.Web_Portal_Order_Status__c = 'Invoiced'; // Need to be checked
                oppt.CurrencyIsoCode = opp.CurrencyIsoCode;
                oppt.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_order').getRecordTypeId();
                insert oppt;
                
                Date td = Date.today();
                
                List<OpportunityLineItem> oliList1 = [Select Product2Id,PricebookEntryId,PricebookEntry.UnitPrice,UnitPrice,Product2.Name,Product2.Price_Group__c,Quantity,Discount,OpportunityId,Description FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
                
                List<Pricing_Policy_with_Customer__c> ppc = new List<Pricing_Policy_with_Customer__c>();
                String ppId = '';
                Pricing_Policy__c pp = new Pricing_Policy__c();
                
                Map<String,Pricing_Policy_Rules__c> stockCodeList = new Map<String,Pricing_Policy_Rules__c>(); 
                Map<String,Pricing_Policy_Rules__c> stockGroupList = new Map<String,Pricing_Policy_Rules__c>();
                
                System.debug('opp selected' + opp.Id);
                if(String.isNotBlank(opp.Id)){
                    System.debug('opp selected' + opp.Id);
                    for(Pricing_Policy_with_Customer__c c : [SELECT Pricing_Policy__c,Pricing_Policy__r.Start_Date__c,Pricing_Policy__r.End_Date__c,Pricing_Policy__r.IS_Active__c FROM Pricing_Policy_with_Customer__c WHERE Customers__c =: opp.AccountId]){
                        System.debug('opp acc' + opp.AccountId);
                        System.debug('todays date ' + date.today());
                        System.debug('Pricing' + c.Pricing_Policy__r.Start_Date__c + ' ' + c.Pricing_Policy__r.End_Date__c);
                        if((td >= c.Pricing_Policy__r.Start_Date__c) && (td <= c.Pricing_Policy__r.End_Date__c) && (c.Pricing_Policy__r.IS_Active__c == true)){
                            ppId = c.Pricing_Policy__c;
                            break;
                        }
                    }
                    System.debug('ppId' + ppId);
                }
                if(String.isNotBlank(ppId)){
                    pp = [SELECT Id,Start_Date__c,End_Date__c,IS_Active__c FROM Pricing_Policy__c WHERE Id =: ppId];
                    System.debug('pp ' + pp);
                    if((date.today() >= pp.Start_Date__c) && (date.today() <= pp.End_Date__c) && (pp.IS_Active__c == true)){
                        System.debug('pricing policy ' + pp);
                        List<Pricing_Policy_Rules__c> allppr = [SELECT Id,Stock_Code__c,Stock_Price_Group__c,Price__c,Minimum_Quantity__c,Discount__c,Start_Date__c,Stop_Date__c
                                                                FROM Pricing_Policy_Rules__c WHERE Pricing_Policy__c =: pp.Id ];
                        if(allppr.size() > 0){
                            for(Pricing_Policy_Rules__c h : allppr){
                                if((date.today() >= h.Start_Date__c) && (date.today() <= h.Stop_Date__c)){
                                    if(String.isNotBlank(h.Stock_Code__c)){
                                        stockCodeList.put(h.Stock_Code__c,h);
                                    }
                                    if(String.isNotBlank(h.Stock_Price_Group__c)){
                                        String pprStockPriceGroupLabel = SFToExoIntegrationUtility.getPicklistLabel('Pricing_Policy_Rules__c','Stock_Price_Group__c',h.Stock_Price_Group__c); 
                                        System.debug('pprStockPriceGroupLabel ' + h.Stock_Price_Group__c);
                                        h.Stock_Price_Group__c = pprStockPriceGroupLabel;
                                        stockGroupList.put(pprStockPriceGroupLabel,h);
                                    }
                                }
                            }
                        }
                    }
                }
                System.debug('stockCodeList ' + stockCodeList);
                System.debug('stockGroupList ' + stockGroupList); 
                
                List<OpportunityLineItem> newOli1 = new List<OpportunityLineItem>();
                
                for(OpportunityLineItem b : oliList1){
                    //String priceGroupLabel = SFToExoIntegrationUtility.getPicklistLabel('Product2','Price_Group__c',lsp[i].priceGroup);
                    //lsp[i].priceGroup = priceGroupLabel;  
                    OpportunityLineItem newOpl = new OpportunityLineItem(); 
                    system.debug('stcode price ' + b.Product2.Name);
                    if(stockCodeList.size() > 0){
                        if(stockCodeList.get(b.Product2.Name) != null){
                            system.debug('stcode price ' + b.Product2.Name);
                            system.debug('stcode price ' + stockCodeList.get(b.Product2.Name).Stock_Code__c);
                            if(b.Product2.Name == stockCodeList.get(b.Product2.Name).Stock_Code__c){
                                newOpl.UnitPrice = stockCodeList.get(b.Product2.Name).Price__c != null ? stockCodeList.get(b.Product2.Name).Price__c : b.PricebookEntry.UnitPrice;
                                newOpl.Discount =  stockCodeList.get(b.Product2.Name).Discount__c != null ? stockCodeList.get(b.Product2.Name).Discount__c : 0;
                                newOpl.Quantity = ((stockCodeList.get(b.Product2.Name).Minimum_Quantity__c != null) && (stockCodeList.get(b.Product2.Name).Minimum_Quantity__c > 0)) ? stockCodeList.get(b.Product2.Name).Minimum_Quantity__c : 1;
                                newOpl.PricebookEntryId = b.PricebookEntryId;
                                newOpl.Description = b.Description == null ? '' : b.Description;
                                newOpl.OpportunityId = oppt.Id;
                            }
                        }
                        else{
                            newOpl.PricebookEntryId = b.PricebookEntryId;
                            newOpl.UnitPrice = b.UnitPrice;
                            newOpl.Quantity = b.Quantity;
                            newOpl.Discount = b.Discount == null ? 0 : b.Discount;
                            newOpl.Description = b.Description == null ? '' : b.Description;
                            newOpl.OpportunityId = oppt.Id; 
                        }
                        
                    }  
                    else if(stockGroupList.size() > 0){
                        String pprStockPriceGroupLabel = SFToExoIntegrationUtility.getPicklistLabel('Product2','Price_Group__c',b.Product2.Price_Group__c);
                        system.debug('pprStockPriceGroupLabel' + pprStockPriceGroupLabel);
                        if(stockGroupList.get(pprStockPriceGroupLabel) != null){
                            System.debug('Stock_Price_Group__c' + stockGroupList.get(pprStockPriceGroupLabel).Stock_Price_Group__c);
                            if(pprStockPriceGroupLabel == stockGroupList.get(pprStockPriceGroupLabel).Stock_Price_Group__c){
                                newOpl.UnitPrice = stockGroupList.get(pprStockPriceGroupLabel).Price__c != null ? stockGroupList.get(pprStockPriceGroupLabel).Price__c : b.PricebookEntry.UnitPrice;
                                system.debug('stgroup price ' + newOpl.UnitPrice);
                                newOpl.Discount = stockGroupList.get(pprStockPriceGroupLabel).Discount__c != null ? stockGroupList.get(pprStockPriceGroupLabel).Discount__c : 0;
                                newOpl.Quantity = ((stockGroupList.get(pprStockPriceGroupLabel).Minimum_Quantity__c != null) && (stockGroupList.get(pprStockPriceGroupLabel).Minimum_Quantity__c > 0)) ? stockGroupList.get(pprStockPriceGroupLabel).Minimum_Quantity__c : 1;
                                newOpl.PricebookEntryId = b.PricebookEntryId;
                                newOpl.Description = b.Description == null ? '' : b.Description;
                                newOpl.OpportunityId = oppt.Id;
                            }                            
                        }
                        else{
                            system.debug('no stockGroupList ppr');
                            newOpl.PricebookEntryId = b.PricebookEntryId;
                            newOpl.UnitPrice = b.UnitPrice;
                            newOpl.Quantity = b.Quantity;
                            newOpl.Discount = b.Discount == null ? 0 : b.Discount;
                            newOpl.Description = b.Description == null ? '' : b.Description;
                            newOpl.OpportunityId = oppt.Id;
                        }
                    }
                    else{
                        system.debug('no ppr');
                        newOpl.PricebookEntryId = b.PricebookEntryId;
                        newOpl.UnitPrice = b.UnitPrice;
                        newOpl.Quantity = b.Quantity;
                        newOpl.Discount = b.Discount;
                        newOpl.Description = b.Description;
                        newOpl.OpportunityId = oppt.Id;
                    }
                    
                    newOli1.add(newOpl);
                    
                }
                
                insert newOli1;
                /* 
// tax calculations

Account acct = [SELECT override_GST_rate__c,Remaining_Credit_Balance__c FROM Account WHERE Id =: oppt.AccountId];

Decimal TotalVal = 0.0;
Decimal taxPercent = 0.0;
Decimal taxAmt = 0.0;
Decimal totalAmountWithTax = 0.0;

if(String.isNotBlank(acct.override_GST_rate__c) && acct.override_GST_rate__c != 'Auto Select Rate'){
String gstRate = acct.override_GST_rate__c;
String[] gr = gstRate.split('%');
taxPercent = Decimal.valueOf(gr[0]);
}

System.debug('m' + newOli1);

for(OpportunityLineItem r : newOli1){
Decimal prodTotal = (Double.valueOf(r.UnitPrice) * Double.valueOf(r.Quantity)) - ((Double.valueOf(r.UnitPrice) * Double.valueOf(r.quantity)) * (Double.valueOf(r.Discount)/100));
TotalVal += prodTotal;
}

taxAmt = TotalVal * (taxPercent/100);
totalAmountWithTax = TotalVal + taxAmt;

oppt.subtotal__c = TotalVal;
oppt.tax_total__c = taxAmt;

update oppt;

if((acct.Remaining_Credit_Balance__c - totalAmountWithTax) < 0){
CalloutException e = new CalloutException();
e.setMessage('The Total Order Value is exceeding the remaining credit for this customer.Cannot create a new order');
throw e;
}
else{
acct.Remaining_Credit_Balance__c = acct.Remaining_Credit_Balance__c - totalAmountWithTax;
}

update acct;
*/
                ar.ReturnCode = '1';
                ar.cloneOppId = oppt.Id; 	
                cloneStat.add(ar);
                return cloneStat;
                
            }
            
            
            //Sales to purchase
            else if(oldOpp.RecordType.DeveloperName ==  'Sales_Order' && oppDetails[1] == 'Purchase Order'){ // change condition 
                
                opportunityId = oppDetails[0];
                oppRecType = oppDetails[1];
                accName = oppDetails[2];
                
                System.debug('Sales to purchase');
                Account accId = [select id ,Sea_Freight_Lead_Time__c ,Remaining_Credit_Balance__c,override_GST_rate__c from account where name=:accName];  
                System.debug('accId' + accId.Id);
                Opportunity opp2= [SELECT AccountId,Id,Amount,BOA_Order__c,Internal_Note__c,CurrencyIsoCode,city__c,CloseDate,Country__c,customer_order_number__c,default_Location__c,Description,ExpectedRevenue,Lead_Time__c,
                                   Name,On_hold__c,Order_Date__c,Order_Placed_By__c,Order_Source__c,OwnerId,Parent_Order__c,Payment_type__c,postal_code__c,Probability,RecordTypeId,reference__c,
                                   StageName,state__c,Street__c,subtotal__c,tax_total__c,TotalOpportunityQuantity,Type FROM Opportunity Where Id=:opportunityId ];
                ObjectAutoNumber__c t2 = ObjectAutoNumber__c.getInstance('Opportunity');
                t2.Purchase_Order_No__c += 1;
                update t2;
                System.debug('AccName --- '+accName);
                Opportunity Oppt2 = new Opportunity();  
                Oppt2.Name=string.valueof(math.round(t2.Purchase_Order_No__c));
                Oppt2.OwnerId = opp2.OwnerId;
                Oppt2.AccountId = accId.Id;//Should take to account id from user
                Oppt2.Order_Date__c = Date.today();
                Oppt2.Lead_Time__c = 'Sea Freight Lead Time';
                Oppt2.default_Location__c= '1';
                Oppt2.StageName = 'Prospecting';
                //Oppt2.tax_total__c = 0.00;
                //Oppt2.subtotal__c =0.00;
                Oppt2.Parent_Order__c = opp2.Id;                 
                oppt2.CloseDate = Date.today(); // need to check
                oppt2.CurrencyIsoCode = opp2.CurrencyIsoCode;
                Oppt2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Purchase_Order').getRecordTypeId();
                insert oppt2;
                //oppt2.clone_test__c = oppt2.id;
                //update oppt2;
                system.debug('New Opp Id'+oppt2.accountId);
                
                
                
                
                
                //if(accId.id !=null){
                //  oppt2.AccountId = accId.id;
                //}
                //update oppt2;  
                
                List<Id> prodId1 = new List<Id>();
                
                Map<Id,Stock_Supplier__c> stockSuppl1 = new Map<Id,Stock_Supplier__c>();
                List<OpportunityLineItem> oliList2 = [Select Product2Id,PricebookEntryId,UnitPrice,Quantity,Discount,OpportunityId,Description FROM OpportunityLineItem WHERE OpportunityId =: opp2.Id];
                for(OpportunityLineItem oli2 : oliList2){
                    prodId1.add(oli2.Product2Id);
                }
                for(Stock_Supplier__c m1 : [SELECT Id, Discount_Percentage__c, Pack_Price__c, Supplier_Code__c, Stock_Item__c, Stock_Item__r.EOQ__c FROM Stock_Supplier__c WHERE Stock_Item__c IN : prodId1 AND Supplier_Name__c =: accId.Id]){
                    if(m1 != null){
                        stockSuppl1.put(m1.Stock_Item__c,m1);                   
                    }
                }
                System.debug('stockSuppl' + stockSuppl1);
                List<OpportunityLineItem> newOli1 = new List<OpportunityLineItem>();
                for(OpportunityLineItem e1 : oliList2){
                    OpportunityLineItem m1 = new OpportunityLineItem();
                    if(stockSuppl1.get(e1.product2Id) != null){
                        m1.PricebookEntryId = e1.PricebookEntryId;
                        m1.UnitPrice = stockSuppl1.get(e1.product2Id).Pack_Price__c;
                        m1.Quantity = Decimal.valueOf((stockSuppl1.get(e1.product2Id).Stock_Item__r.EOQ__c == null || stockSuppl1.get(e1.product2Id).Stock_Item__r.EOQ__c == 0) ? String.valueOf(e1.Quantity) : String.valueOf(stockSuppl1.get(e1.product2Id).Stock_Item__r.EOQ__c));
                        m1.Discount = 0;
                        m1.Discount = stockSuppl1.get(e1.product2Id).Discount_Percentage__c == null ? 0 : stockSuppl1.get(e1.product2Id).Discount_Percentage__c;
                        m1.Description = e1.Description == null ? '' : e1.Description;
                        m1.OpportunityId = Oppt2.Id;
                        
                    }
                    else{
                        m1.PricebookEntryId = e1.PricebookEntryId;
                        m1.UnitPrice = e1.UnitPrice;
                        m1.Quantity = e1.Quantity;
                        m1.Discount = e1.Discount == null ? 0 : e1.Discount;
                        m1.Description = e1.Description == null ? '' : e1.Description;
                        m1.OpportunityId = Oppt2.Id;                    
                    }
                    newOli1.add(m1);        
                }
                insert newOli1;    
                Account acct = [SELECT override_GST_rate__c,Remaining_Credit_Balance__c FROM Account WHERE Id =: oppt2.AccountId];
                Decimal TotalVal = 0.0;
                Decimal taxPercent = 0.0;
                Decimal taxAmt = 0.0;
                Decimal totalAmountWithTax = 0.0;
                if(String.isNotBlank(acct.override_GST_rate__c) && acct.override_GST_rate__c != 'Auto Select Rate'){
                    String gstRate = acct.override_GST_rate__c;
                    String[] gr = gstRate.split('%');
                    taxPercent = Decimal.valueOf(gr[0]);
                    
                }
                System.debug('m' + newOli1);
                for(OpportunityLineItem r : newOli1){
                    Decimal prodTotal = (Double.valueOf(r.UnitPrice) * Double.valueOf(r.Quantity)) - ((Double.valueOf(r.UnitPrice) * Double.valueOf(r.quantity)) * (Double.valueOf(r.Discount)/100));
                    TotalVal += prodTotal;
                    taxAmt = TotalVal * (taxPercent/100);
                    totalAmountWithTax = TotalVal + taxAmt;
                    
                    oppt2.subtotal__c = TotalVal;
                    oppt2.tax_total__c = taxAmt;
                    
                    update oppt2;
                    
                    
                }
                
                ar.ReturnCode = '1';
                ar.cloneOppId = Oppt2.Id; 	
                cloneStat.add(ar);
                return cloneStat;
                
            }
            else{
                ar.ReturnCode = '0';
                ar.cloneOppId = opportunityId;	
                cloneStat.add(ar);
                return cloneStat;
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            ar.ReturnCode = '0';
            ar.cloneOppId = opportunityId;
            cloneStat.add(ar);
            ErrorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'BoaOpportunityClone.Opportunityreplicate',e.getLineNumber());
            return cloneStat;
        }
        
    }
    
    global class Apex_Result{
        @InvocableVariable(label='ReturnCode')
        global String ReturnCode;
        @InvocableVariable(label='clonedOppId')
        global String cloneOppId;
    }
    
}