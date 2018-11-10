public class Rest_ExoOutboundHandler {
    
public static void upsertSalesOrderDetailsToEXO(List<Id> orderIds){
        system.debug('enter into sales');
        try{
            List<Opportunity> oppList = [SELECT Id,StageName,SEQNO_EXO__c,Sales_Person_Code_In_Exo__c,CloseDate,Invoice_URL__c,name,AccountId,account.accountNumber__C,Order_Date__c,Order_Source__c,Payment_type__c,
                                         Web_Portal_Order_Status__c,Currency_Code_in_Exo__c,CurrencyIsoCode,subtotal__c,tax_total__c,customer_order_number__c,account.IsPersonAccount,
                                         reference__c,Amount,city__c,Street__c,postal_code__c,Country__c,state__c,On_hold__c,default_Location__c,lastModifiedDate,CreatedDate,RecordTypeId,owner.name FROM Opportunity WHERE Id IN : orderIds  ];
            
            if(!oppList.isEmpty()){
                System.debug('oppList ' + oppList);
                Set<Id> oppIds = new Set<Id>();
                Map<Id,List<OpportunityLineItem>> orderToOrderLintItemMap = new Map<Id,List<OpportunityLineItem>>();
                for(Opportunity opp : oppList){
                    oppIds.add(opp.Id);   
                }
                
                List<OpportunityLineItem> oliList = [SELECT Id,Discount,Line_Item_number__c,SEQNO_EXO__c,ListPrice,Supplied_quantity__c,
                                                     invoiced_quantity__c,Product2Id,Product2.Name,Product2.Bill_of_Material__c,
                                                     OpportunityId,ProductCode,Description,Quantity,UnitPrice,TotalPrice
                                                     FROM OpportunityLineItem WHERE OpportunityId IN : oppIds];
                //Popuating map
                if(!oliList.isEmpty()){
                    System.debug('Oli list in not empty..');
                    for(OpportunityLineItem oli : oliList){
                        if(orderToOrderLintItemMap.containsKey(oli.OpportunityId)){
                            orderToOrderLintItemMap.get(oli.OpportunityId).add(oli);
                        }else{
                            List<OpportunityLineItem> olisList = new List<OpportunityLineItem>();
                            olisList.add(oli);
                            orderToOrderLintItemMap.put(oli.OpportunityId,olisList);
                        }
                    }           
                }
                
                List<Rest_ExoWrappers.salesOrdDetails> salesInfoList = new List<Rest_ExoWrappers.salesOrdDetails>();
                for(Opportunity opp : oppList){
                    system.debug('in for loop...');
                    Rest_ExoWrappers.SalesOrdHdr SalesDetails = new Rest_ExoWrappers.SalesOrdHdr();
                    Rest_ExoWrappers.salesOrdDetails SalesOrderInfo = new Rest_ExoWrappers.salesOrdDetails();
                    List<Rest_ExoWrappers.SalesOrdLines> SalesOrdLinesDetails = new List<Rest_ExoWrappers.SalesOrdLines>();
                    SalesDetails.STATUS=0;
                    // in case of person account orders , se nd hardcoded ACCNO to exo.
                    SalesDetails.ACCNO = opp.account.IsPersonAccount ? integer.valueOf(label.ExoPersonAccountNo) :integer.valueOf(opp.account.AccountNumber__c); 
                    SalesDetails.ORDERDATE = opp.Order_Date__c; 
                    SalesDetails.DUEDATE= opp.CloseDate;
                    SalesDetails.CUSTORDERNO = opp.customer_order_number__c;
                    SalesDetails.REFERENCE = opp.reference__c;
                    SalesDetails.ADDRESS1 = opp.Street__c;
                    SalesDetails.ADDRESS2 = opp.city__c;
                    SalesDetails.ADDRESS3 = opp.state__c;
                    SalesDetails.ADDRESS4 = opp.Country__c;
                    SalesDetails.SUBTOTAL = opp.subtotal__c;
                    SalesDetails.TAXTOTAL = opp.tax_total__c;
                    SalesDetails.SALESNO =sales_person__c.getAll().get(opp.owner.Name) != null ? sales_person__c.getAll().get(opp.owner.Name).staff_number__c : sales_person__c.getAll().get('Integration User').staff_number__c ;                    SalesDetails.CURRENCYNO = opp.Currency_Code_in_Exo__c;
                 
                    SalesDetails.CURRENCYNO = opp.Currency_Code_in_Exo__c;
                    SalesDetails.LAST_UPDATED = opp.lastModifiedDate;
                    SalesDetails.DEFLOCNO = opp.default_Location__c;
                    SalesDetails.ONHOLD = opp.On_hold__c ? 'Y' : 'N';
                    SalesDetails.CREATE_DATE= opp.CreatedDate;
                    SalesDetails.SEQNO = opp.SEQNO_EXO__c;
                    SalesDetails.SalesforceID = opp.Id;
                    
                    if(orderToOrderLintItemMap.containsKey(opp.Id)){
                        System.debug('orderToOrderLintItemMap.containsKey(opp.Id)');
                        for(OpportunityLineItem oli : orderToOrderLintItemMap.get(opp.Id)){
                            Rest_ExoWrappers.SalesOrdLines SalesLineItemDetails = new Rest_ExoWrappers.SalesOrdLines();                            
                            SalesLineItemDetails.STOCKCODE = oli.Product2.Name;
                            if(oli.Description!=null && oli.Description.length()>=40){
                                SalesLineItemDetails.DESCRIPTION = oli.Description.substring(0,40);
                            }
                            SalesLineItemDetails.SEQNO = oli.SEQNO_EXO__c;
                            SalesLineItemDetails.ORD_QUANT = oli.Quantity;
                            SalesLineItemDetails.UNITPRICE = oli.UnitPrice;
                            SalesLineItemDetails.DISCOUNT = oli.Discount;
                            SalesLineItemDetails.LISTPRICE = oli.ListPrice;
                            SalesLineItemDetails.SalesforceID = oli.Id;
                            // add to list of sales Order Line Items
                            SalesOrdLinesDetails.add(SalesLineItemDetails);
                            //if order line item is a BOM then add its child components also 
                            if(oli.Product2.Bill_of_Material__c){
                                List<BOM_Line_Item__c> BOMLineItems = [SELECT Id,Name,Stock_Item__r.Name,Quantity__c,
                                                                       Description__c FROM BOM_Line_Item__c WHERE
                                                                       Stock_Item__c =: oli.Product2Id];
                                for(BOM_Line_Item__c bomLineItem :BOMLineItems ){
                                    Rest_ExoWrappers.SalesOrdLines BOMLineItemDetails = new Rest_ExoWrappers.SalesOrdLines();
                                    BOMLineItemDetails.STOCKCODE = bomLineItem.Name;
                            		BOMLineItemDetails.DESCRIPTION = bomLineItem.Description__c;
                            		BOMLineItemDetails.ORD_QUANT = bomLineItem.Quantity__c;
                            		//BOMLineItemDetails.UNITPRICE = oli.UnitPrice;
                            		//BOMLineItemDetails.DISCOUNT = oli.Discount;
                            		//BOMLineItemDetails.LISTPRICE = oli.ListPrice;
                            		//BOMLineItemDetails.SalesforceID = oli.Id;
                            		// add to list of sales Order Line Items
                            		SalesOrdLinesDetails.add(BOMLineItemDetails);
                                }
                            }
                            
                        }
                    }
                    SalesDetails.salesOrdLines = SalesOrdLinesDetails;
                    SalesOrderInfo.salesOrdHdr = SalesDetails;
                    SalesInfoList.add(SalesOrderInfo);
                }
                System.debug('SalesInfoList..' + SalesInfoList);
                //sending out a request
                Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
                
                responseWrapper = Rest_outboundCaller.postHttpRequestExo('/salesOrder','',Json.serialize(SalesInfoList));
                System.debug('Json.serialize(SalesInfoList[0]) ' + Json.serialize(SalesInfoList));
               
                
                //logic to update order numner and order line item number starts from this point
                If(responseWrapper.responseCode == 200){
                    Rest_ExoResponseWrapper.salesOrderResponseWrapper responseObj = (Rest_ExoResponseWrapper.salesOrderResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.salesOrderResponseWrapper.class);
                    system.debug('responseObj--'+responseObj);
                    list<opportunity> updOppList = new list<opportunity>();
                    list<OpportunityLineItem> updOliList = new list<OpportunityLineItem>();
                    // response parsing logic                    
                    if(!responseObj.salesOrderData.isEmpty()){
                        for(Rest_ExoResponseWrapper.cls_salesOrderData s : responseObj.salesOrderData){
                            // add opportunity to update in opportunity list
                            opportunity updOpp = new opportunity();
                            updOpp.Id = s.salesOrdHdr.SalesforceID;
                            updOpp.SEQNO_EXO__c = s.salesOrdHdr.SEQNO;
                            updOpp.Order_Synced__c = false;
                            updOppList.add(updOpp);
                            for(Rest_ExoResponseWrapper.ResponseChild oli : s.salesOrdHdr.salesOrdLines){
                                OpportunityLineItem updOli = new OpportunityLineItem();
                                updOli.Id = oli.SalesforceID;
                                updOli.SEQNO_EXO__c = oli.SEQNO; 
                                updOliList.add(updOli);
                                
                            }
                        }
                    }
                    
                    //update opportunities and opportunity line items now
                    if(!updOppList.isEmpty()){
                        update updOppList;
                    }
                    
                    if(!updOliList.isEmpty()){
                        update updOliList;
                    }
                } 
            }
            
        }
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.upsertSalesOrderDetailsToEXO',e.getLineNumber());                   
        }
    }
    
    
    
    //Purchase order
    public static void upsertPurchaseOrderDetailsToEXO(List<Id> orderIds){
        system.debug('enter into purchase');
        try{
            
            List<Opportunity> oppList = [SELECT Id,SEQNO_EXO__c,StageName,Sales_Person_Code_In_Exo__c,CloseDate,Invoice_URL__c,name,AccountId,account.accountNumber__C,Order_Date__c,Order_Source__c,Payment_type__c,
                                         Web_Portal_Order_Status__c,Currency_Code_in_Exo__c,CurrencyIsoCode,subtotal__c,tax_total__c,customer_order_number__c,
                                         reference__c,Amount,city__c,Street__c,postal_code__c,owner.Name,Country__c,state__c,On_hold__c,default_Location__c,lastModifiedDate,CreatedDate,RecordTypeId FROM Opportunity WHERE Id IN : orderIds ];
            if(!oppList.isEmpty()){
                System.debug('oppList ' + oppList);
                Set<Id> oppIds = new Set<Id>(); 
                Map<Id,List<OpportunityLineItem>> orderToOrderLintItemMap = new Map<Id,List<OpportunityLineItem>>();
                for(Opportunity opp : oppList){
                    oppIds.add(opp.Id);    
                }
                
                List<OpportunityLineItem> oliList = [SELECT Id,SEQNO_EXO__c,Discount,Line_Item_number__c,ListPrice,Supplied_quantity__c,
                                                     invoiced_quantity__c,Product2Id,Product2.Name,OpportunityId,ProductCode,
                                                     Description,Quantity,UnitPrice,TotalPrice FROM OpportunityLineItem 
                                                     WHERE OpportunityId IN : oppIds];
                //Popuating map
                if(!oliList.isEmpty()){
                    System.debug('Oli list in not empty..');
                    for(OpportunityLineItem oli : oliList){
                        if(orderToOrderLintItemMap.containsKey(oli.OpportunityId)){
                            orderToOrderLintItemMap.get(oli.OpportunityId).add(oli);
                            //System.debug('in the loop ' +PricingPplicyToPPRulesMap);
                        }else{
                            List<OpportunityLineItem> olisList = new List<OpportunityLineItem>();
                            olisList.add(oli);
                            //System.debug('in another loop pprList' +pprList);
                            orderToOrderLintItemMap.put(oli.OpportunityId,olisList);
                        } 
                    }	    
                }
                
                List<Rest_ExoWrappers.PurchaseOrdDetails> SalesInfoList = new List<Rest_ExoWrappers.PurchaseOrdDetails>();
                for(Opportunity opp : oppList){
                    system.debug('in for loop...');
                    Rest_ExoWrappers.PurchOrdHdr SalesDetails = new Rest_ExoWrappers.PurchOrdHdr();
                    Rest_ExoWrappers.PurchaseOrdDetails SalesOrderInfo = new Rest_ExoWrappers.PurchaseOrdDetails();
                    List<Rest_ExoWrappers.PurchOrdLines> SalesOrdLinesDetails = new List<Rest_ExoWrappers.PurchOrdLines>();
                    
                    SalesDetails.STATUS = opp.StageName != 'Not processed' ?  0 :  2;
                    SalesDetails.ACCNO = integer.valueOf(opp.account.AccountNumber__c); //should relate ACCNO in EXO
                    SalesDetails.ORDERDATE = system.now(); //
                    SalesDetails.DUEDATE= system.now(); //
                    SalesDetails.ADDRESS1 = opp.Street__c;
                    SalesDetails.ADDRESS2 = opp.city__c;
                    SalesDetails.ADDRESS3 = opp.state__c;
                    SalesDetails.ADDRESS4 = opp.Country__c;
                    SalesDetails.SUBTOTAL = opp.subtotal__c;
                    SalesDetails.TAXTOTAL = opp.tax_total__c;
                    //SalesDetails.SALESNO = opp.Sales_Person_Code_In_Exo__c;
                    SalesDetails.SALESNO =sales_person__c.getAll().get(opp.owner.Name) != null ? sales_person__c.getAll().get(opp.owner.Name).staff_number__c : sales_person__c.getAll().get('Integration User').staff_number__c ;                    SalesDetails.CURRENCYNO = opp.Currency_Code_in_Exo__c;
                    SalesDetails.LAST_UPDATED = opp.lastModifiedDate;
                    SalesDetails.DEFLOCNO = opp.default_Location__c;
                    SalesDetails.CREATE_DATE= opp.CreatedDate;
                    SalesDetails.SEQNO = opp.SEQNO_EXO__c;
                    SalesDetails.SalesforceID = opp.Id;
                    
                    if(orderToOrderLintItemMap.containsKey(opp.Id)){
                        System.debug('orderToOrderLintItemMap.containsKey(opp.Id)');
                        for(OpportunityLineItem oli : orderToOrderLintItemMap.get(opp.Id)){
                            Rest_ExoWrappers.purchOrdLines SalesLineItemDetails = new Rest_ExoWrappers.purchOrdLines();
                            
                            SalesLineItemDetails.STOCKCODE = oli.Product2.Name;
                            if(SalesLineItemDetails.DESCRIPTION!=null && SalesLineItemDetails.DESCRIPTION.length()>=1){
                                SalesLineItemDetails.DESCRIPTION = oli.Description.substring(0,30)!=null? oli.Description.substring(0,30):null;
                            }
                            SalesLineItemDetails.SEQNO = oli.SEQNO_EXO__c;
                            SalesLineItemDetails.ORD_QUANT = oli.Quantity;
                            SalesLineItemDetails.UNITPRICE = oli.UnitPrice;
                            SalesLineItemDetails.DISCOUNT = oli.Discount;
                            SalesLineItemDetails.SalesforceID = oli.Id;
                            SalesLineItemDetails.DUEDATE = system.now();
                            
                            SalesOrdLinesDetails.add(SalesLineItemDetails);
                            //SalesOrderInfo.salesOrdHdr.salesOrdLines = SalesOrdLinesDetails;
                        }
                        SalesDetails.purchOrdLines = SalesOrdLinesDetails;
                        SalesOrderInfo.purchOrdHdr = SalesDetails;
                        SalesInfoList.add(SalesOrderInfo);
                        
                    } 
                    
                    //Adding BOM if any
                    
                }
                System.debug('PurchaseInfoList..' + SalesInfoList);
                //sending out a request 
                Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
                
                responseWrapper = Rest_outboundCaller.postHttpRequestExo('/purchOrder','',Json.serialize(SalesInfoList));
                System.debug('Json.serialize(SalesInfoList[0]) ' + Json.serialize(SalesInfoList));
                
                //logic to update order numner and order line item number starts from this point
                If(responseWrapper.responseCode == 200){
                    Rest_ExoResponseWrapper.purchaseOrderResponseWrapper responseObj = (Rest_ExoResponseWrapper.purchaseOrderResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.purchaseOrderResponseWrapper.class);
                    system.debug('NewresponseObj--'+responseObj);
                    list<opportunity> updOppList = new list<opportunity>();
                    list<OpportunityLineItem> updOliList = new list<OpportunityLineItem>();
                    // response parsing logic                    
                    if(!responseObj.purchOrderData.isEmpty()){
                        for(Rest_ExoResponseWrapper.cls_purchOrderData s : responseObj.purchOrderData){
                            // add opportunity to update in opportunity list
                            opportunity updOpp = new opportunity();
                            updOpp.Id = s.purchOrdHdr.SalesforceID;
                            updOpp.SEQNO_EXO__c = s.purchOrdHdr.SEQNO;
                            updOpp.Order_Synced__c = false;

                            updOppList.add(updOpp);
                            for(Rest_ExoResponseWrapper.ResponseChild oli : s.purchOrdHdr.purchOrdLines){
                                OpportunityLineItem updOli = new OpportunityLineItem();
                                updOli.Id = oli.SalesforceID;
                                updOli.SEQNO_EXO__c = oli.SEQNO;
                                updOliList.add(updOli);    
                            }
                        }
                    }
                    
                    //update opportunities and opportunity line items now
                    if(!updOppList.isEmpty()){
                        update updOppList;
                    }
                    
                    if(!updOliList.isEmpty()){
                        update updOliList;
                    }
                }  
            }
        }
        
        
        
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.PurchaseOrderDetailsToEXO',e.getLineNumber());	    
        }
    }
    
    public static void upertAccountDetailsToEXO(List<Id> AccIds){
        system.debug('enter into debit account');
        try{
            List<Account> Acclist= [SELECT Id, AccountNumber__c,owner.Name,Name,Alpha_Code__c,Currency_Code_in_Exo__c,ParentId,Crimper__c,Fitting_Type__c,Set_up_hose_type__c,
                                    SET_UP_DATE_del__c,Default_payment_type__c,pop_up_alert__c,Allow_Restricted_Goods__c,Parent.accountNumber__c,
                                    Need_Order_Number__c,override_GST_rate__c,stop_credit__c,open_Item__c,IsActive__c,Credit_Terms__c,Credit_Limit__c,
                                    Base_Price__c,OwnerId,Region__c,Type__c,Industry,Monthly_target_value__c,PPSR__c,Statement_Delivery__c,Default_Contact__c,
                                    Customer_Class__c,Statement_Contact__r.Contact_SEQ_No__c,FAX,BillingStreet,BillingCity,BillingCountry,BillingPostalCode,
                                    ShippingStreet,ShippingCity,ShippingState,ShippingCountry,Email__c,Phone FROM Account WHERE Id IN : AccIds];
            List<Rest_ExoWrappers.AccountDrDetails> AccountInfoList = new List<Rest_ExoWrappers.AccountDrDetails>();
            Set<Id> DefaultContactIds = new Set<Id>();
			List<Contact> defConatctsToUpdate = new List<Contact>();
            if(!AccList.isEmpty()){
                System.debug('oppList ' + AccList);
                Set<Id> AcctIds = new Set<Id>(); 
                for(Account acc : AccList){
                    AccIds.add(acc.Id);    
                }
                for(Account acc : AccList){
                    system.debug('in for loop...');
                    Rest_ExoWrappers.AccountDrDetails AccountDetails = new Rest_ExoWrappers.AccountDrDetails();
                    AccountDetails.SalesforceID = acc.Id;
                    AccountDetails.ALPHACODE = acc.Alpha_Code__c;
                    AccountDetails.ACCNO = acc.AccountNumber__c;
                    AccountDetails.NAME = acc.Name;
                    AccountDetails.ADDRESS1 = acc.BillingStreet;
                    //AccountDetails.ADDRESS2 = acc.BILLINGSUBURB;
                    AccountDetails.ADDRESS3 = acc.BillingCity;
                    AccountDetails.ADDRESS4 = acc.BillingCountry;
                    AccountDetails.POST_CODE = acc.BillingPostalCode;
                    AccountDetails.DELADDR1 = acc.ShippingStreet;
                    //AccountDetails.DELADDR2 = acc.Shipping SUBURB;
                    AccountDetails.DELADDR3 = acc.ShippingCity;
                    AccountDetails.DELADDR4 = acc.ShippingState;
                    AccountDetails.DELADDR5 = acc.ShippingCountry;
                    AccountDetails.EMAIL = acc.Email__c;
                    AccountDetails.PHONE = acc.Phone;
                    AccountDetails.FAX = acc.FAX;
                    AccountDetails.X_CUSCLASS = acc.Customer_Class__c;
                    AccountDetails.X_MONTHLYTARGET = acc.Monthly_target_value__c;
                    AccountDetails.X_PPSR = acc.PPSR__c ? 'Y':'N';
                    AccountDetails.ACCGROUP = acc.Region__c;
                    AccountDetails.ACCGROUP2 = acc.Type__c;
                    AccountDetails.X_INDUSTRYTYPE = acc.Industry;
                    //AccountDetails.SALESNO = acc.OwnerId;
                    AccountDetails.SALESNO =sales_person__c.getAll().get(acc.owner.Name) != null ? sales_person__c.getAll().get(acc.owner.Name).staff_number__c : sales_person__c.getAll().get('Integration User').staff_number__c ;
                    AccountDetails.PRICENO = acc.Base_Price__c;
                    AccountDetails.CREDITSTATUS = acc.Credit_Terms__c;
                    AccountDetails.CREDLIMIT = acc.Credit_Limit__c;
                    AccountDetails.ISACTIVE = acc.IsActive__c ? 'Y':'N';
                    AccountDetails.OPENITEM = acc.open_Item__c ? 'Y':'N';
                    AccountDetails.STOPCREDIT = acc.stop_credit__c ? 'Y':'N';
                    AccountDetails.NEED_ORDERNO = acc.Need_Order_Number__c ? 'Y':'N';
                    AccountDetails.ALLOW_RESTRICTED_STOCK = acc.Allow_Restricted_Goods__c ? 'Y':'N';
                    AccountDetails.ALERT = acc.pop_up_alert__c;
                    AccountDetails.PAY_TYPE = acc.Default_payment_type__c;
                    AccountDetails.X_SET_UP_DATE = acc.SET_UP_DATE_del__c;
                    AccountDetails.X_HOSE_TYPE = acc.Set_up_hose_type__c;
                    AccountDetails.X_FITTING_TYPE = acc.Fitting_Type__c;
                    AccountDetails.X_CRIMPER = acc.Crimper__c;
                    AccountDetails.TAXSTATUS = acc.override_GST_rate__c!=null ? acc.override_GST_rate__c:null;
                    AccountDetails.HEAD_ACCNO = acc.ParentId != null ? Integer.valueOf(acc.parent.accountNumber__c) :-1 ;
                    AccountDetails.PRIVATE_ACC = 'N';
                    AccountDetails.STATEMENT_CONTACT_SEQNO = acc.Statement_Contact__c == null ? 0: acc.Statement_Contact__r.Contact_SEQ_No__c;
					AccountDetails.STATEMENT = acc.Statement_Delivery__c;
                    AccountDetails.CURRENCYNO = acc.Currency_Code_in_Exo__c;
                    
                    if(acc.Default_Contact__c != null){
						DefaultContactIds.add(acc.Default_Contact__c);
					}
						
                    AccountInfoList.add(AccountDetails);
                    
                }                 
            }
            //sending out a account sync request 
            Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
            
            responseWrapper = Rest_outboundCaller.postHttpRequestExo('/account','',Json.serialize(AccountInfoList));
            System.debug('Json.serialize(AccountInfoList[0]) ' + Json.serialize(AccountInfoList));
            
            // sending our default contact sync request
			if(!DefaultContactIds.isEmpty()){
				List<Contact> syncContacts = [SELECT Id,AccountId,Account.RecordTypeId,Contact_SEQ_No__c,DR_CR_Contact_Seq_number__c,Account.Default_Contact__r.Id,
											  Account.Default_Contact__r.Contact_SEQ_No__c,account.AccountNumber__c FROM CONTACT WHERE Id IN: DefaultContactIds];
				defConatctsToUpdate = upsertCrAndDrContactsToEXO(syncContacts);
			}
			
			
			//logic to update order numner and order line item number starts from this point
            If(responseWrapper.responseCode == 200){
                Rest_ExoResponseWrapper.supplierAccountResponseWrapper responseObj = (Rest_ExoResponseWrapper.supplierAccountResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.supplierAccountResponseWrapper.class);
                system.debug('NewresponseObj--'+responseObj);
                list<account> updOppList = new list<account>();
                // response parsing logic                    
                if(!responseObj.accountData.isEmpty()){
                    for(Rest_ExoResponseWrapper.cls_supplierAccountData s : responseObj.accountData){
                        // add opportunity to update in opportunity list
                        account accObj = new account();
                        accObj.Id = s.SalesforceID;
                        accObj.AccountNumber__c = s.ACCNO;
                        updOppList.add(accObj);
                    }
                }
                
                if(!updOppList.isEmpty()){
                    update updOppList;
                }
            }
			
			//finally update list of contacts
			if(!defConatctsToUpdate.isEmpty()){
				update defConatctsToUpdate;
			}
        }
        
        
        
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.InsertAccountDetailsToEXO',e.getLineNumber());	    
        }
    }
    
    
    // credit/supplier Account 
    public static void upsertCreditAccountDetailsToEXO(List<Id> AccIds){
        system.debug('enter into supplier/Credit account');
        try{
            List<Account> Acclist= [SELECT AccountNumber__c,Primary_Group__c,Secondary_Group_del__c,Air_Freight_Lead_Time__c,owner.Name,Name,Id,Phone,BillingCountry,BillingStreet,BillingCity,BillingPostalCode,ShippingStreet,
                                    ShippingCity,Default_Invoice__c	,ShippingState,ShippingCountry,Email__c,FAX,customer_class__c,Region__c,
                                    PPSR__c,Type__c,Base_Price__c,override_GST_rate__c,Bank_Name__c,Bank_Account_Number__c,OwnerId,Credit_Terms__c,Credit_Limit__c,IsActive__c,open_Item__c,stop_credit__c,
                                    Need_Order_Number__c,Statement_Contact__r.Contact_SEQ_No__c,Allow_Restricted_Goods__c,Parent.accountNumber__c,pop_up_alert__c,Default_payment_type__c,Set_up_hose_type__c,Crimper__c,Default_Contact__c,
                                    ParentId,SET_UP_DATE_del__c,Statement_Delivery__c,Sea_Freight_Lead_Time__c,Hide_prices_on_PO__c,Alpha_Code__c,CreatedDate,CurrencyIsoCode,Contact_SEQ_No__pc,Currency_Code_in_Exo__c,LinkedIn__c,facebook__c,Fitting_Type__c,Twitter__c FROM Account WHERE Id IN : AccIds];
            List<Rest_ExoWrappers.AccountCrDetails> AccountInfoList = new List<Rest_ExoWrappers.AccountCrDetails>();
            Set<Id> DefaultContactIds = new Set<Id>();
			List<Contact> defConatctsToUpdate = new List<Contact>();
            if(!AccList.isEmpty()){
                System.debug('oppList ' + AccList);
                Set<Id> AcctIds = new Set<Id>(); 
                for(Account acc : AccList){
                    AccIds.add(acc.Id);    
                }
                for(Account acc : AccList){
                    system.debug('in for loop...');
                    Rest_ExoWrappers.AccountCrDetails AccountDetails = new Rest_ExoWrappers.AccountCrDetails();
                    AccountDetails.SalesforceID = acc.Id;
                    AccountDetails.ALPHACODE = acc.Alpha_Code__c;
                   AccountDetails.ACCNO = acc.AccountNumber__c;
                    AccountDetails.NAME = acc.Name;
                    AccountDetails.ADDRESS1= acc.BillingStreet;
                    AccountDetails.ADDRESS3	= acc.BillingCity;
                    AccountDetails.ADDRESS4= acc.BillingCountry;
                    AccountDetails.POST_CODE= acc.BillingPostalCode;
                    AccountDetails.DELADDR1= acc.ShippingStreet;
                    AccountDetails.DELADDR3= acc.ShippingCity;
                    AccountDetails.DELADDR4= acc.ShippingState;
                    AccountDetails.DELADDR5= acc.ShippingCountry;
                    AccountDetails.EMAIL= acc.Email__c;
                    AccountDetails.PHONE= acc.Phone;
                    AccountDetails.FAX= acc.FAX;
                    AccountDetails.X_CUSCLASS= acc.customer_class__c;
                    AccountDetails.X_PPSR= acc.PPSR__c;
                    AccountDetails.ACCGROUP= acc.Primary_Group__c;
                    AccountDetails.ACCGROUP2= acc.Secondary_Group_del__c;
                     AccountDetails.SALESNO =sales_person__c.getAll().get(acc.owner.Name) != null ? sales_person__c.getAll().get(acc.owner.Name).staff_number__c : sales_person__c.getAll().get('Integration User').staff_number__c ;
                    AccountDetails.PRICENO= acc.Base_Price__c;
                    AccountDetails.CREDITSTATUS= acc.Credit_Terms__c;
                    AccountDetails.CREDLIMIT= acc.Credit_Limit__c;
                    AccountDetails.ISACTIVE = acc.IsActive__c ? 'Y':'N';
                    AccountDetails.STOPCREDIT = acc.stop_credit__c ? 'Y':'N';
                    AccountDetails.NEED_ORDERNO= acc.Need_Order_Number__c;
                    AccountDetails.ALLOW_RESTRICTED_STOCK= acc.Allow_Restricted_Goods__c;
                    AccountDetails.ALERT= acc.pop_up_alert__c;
                    AccountDetails.PAY_TYPE= acc.Default_payment_type__c;
                    AccountDetails.X_SET_UP_DATE= acc.SET_UP_DATE_del__c;
                    AccountDetails.X_HOSE_TYPE= acc.Set_up_hose_type__c;
                    AccountDetails.X_FITTING_TYPE= acc.Fitting_Type__c;
                    AccountDetails.X_CRIMPER= acc.Crimper__c;
                    AccountDetails.STARTDATE= acc.CreatedDate;
                    AccountDetails.X_HIDE_POPRICES = acc.Hide_prices_on_PO__c ? 'Y':'N';
                    AccountDetails.LINKEDIN = acc.LinkedIn__c;
                    AccountDetails.TWITTER= acc.Twitter__c;
                    AccountDetails.FACEBOOK= acc.facebook__c;
                    AccountDetails.HEAD_ACCNO = acc.ParentId != null ? Integer.valueOf(acc.parent.accountNumber__c) :-1 ;
                    AccountDetails.CURRENCYNO = acc.Currency_Code_in_Exo__c;
                    AccountDetails.PRIVATE_ACC = 'N';
                    AccountDetails.AVE_DAYS_TO_PAY = -1;
                    AccountDetails.FREIGHTFREE = 'N';
                    AccountDetails.ISTEMPLATE = 'N';
                    AccountDetails.KEEPTRANSACTIONS = 'Y';
                    AccountDetails.SEND_PAYMENT_REMITTANCE = 'N';
                    AccountDetails.TRACK_CITP = 'N';
                    
                     //List<Contact> Contlist = [SELECT Id,Contact_SEQ_No__c FROM Contact WHERE AccountId =: acc.Id AND is_Statement_contact__c = True LIMIT 1];
                    //for(Contact con:Contlist){
                    AccountDetails.STATEMENT_CONTACT_SEQNO = acc.Statement_Contact__r == null ? -1: acc.Statement_Contact__r.Contact_SEQ_No__c;
                   // }
                    AccountDetails.DEF_INVMODE = acc.Default_Invoice__c!=null? 1:0 ;	
                    AccountDetails.REMITTANCE_METHOD = acc.Statement_Delivery__c;
                    AccountDetails.LEADTIME= acc.Sea_Freight_Lead_Time__c ;
                    AccountDetails.LEADTIME2 = acc.Air_Freight_Lead_Time__c;
                    AccountDetails.BANK_ACCOUNT = acc.Bank_Account_Number__c;
                    AccountDetails.BANK_ACC_NAME =acc.Bank_Name__c;
                    AccountDetails.TAXSTATUS =acc.override_GST_rate__c;
                    AccountDetails.OPENITEM =acc.open_Item__c == true ? 'Y':'N';
                    
                    if(acc.Default_Contact__c != null){
						DefaultContactIds.add(acc.Default_Contact__c);
					}
                    AccountInfoList.add(AccountDetails);
                    
                }                 
            }
            //sending out a request 
            Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
            
            responseWrapper = Rest_outboundCaller.postHttpRequestExo('/cr_account','',Json.serialize(AccountInfoList));
            System.debug('Json.serialize(AccountInfoList[0]) ' + Json.serialize(AccountInfoList));
            
            // sending our default contact sync request
			if(!DefaultContactIds.isEmpty()){
				List<Contact> syncContacts = [SELECT Id,AccountId,Account.RecordTypeId,Contact_SEQ_No__c,DR_CR_Contact_Seq_number__c,Account.Default_Contact__r.Id,
											  Account.Default_Contact__r.Contact_SEQ_No__c,account.AccountNumber__c FROM CONTACT WHERE Id IN: DefaultContactIds];
				defConatctsToUpdate = upsertCrAndDrContactsToEXO(syncContacts);
			}
            
            //logic to update order numner and order line item number starts from this point
            If(responseWrapper.responseCode == 200){
                System.debug('supplier response body--'+responseWrapper.responseBody);
                Rest_ExoResponseWrapper.accountResponseWrapper responseObj = (Rest_ExoResponseWrapper.accountResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.accountResponseWrapper.class);
                system.debug('Supplier NewresponseObj--'+responseObj);
                list<account> updOppList = new list<account>();
                // response parsing logic                    
                if(!responseObj.cr_accountData.isEmpty()){
                    for(Rest_ExoResponseWrapper.cls_accountData s : responseObj.cr_accountData){
                        // add opportunity to update in opportunity list
                        account accObj = new account();
                        accObj.Id = s.SalesforceID;
                        accObj.AccountNumber__c = s.ACCNO;
                        updOppList.add(accObj);
                        
                    }
                }
                
                if(!updOppList.isEmpty()){
                    update updOppList;
                }
            }
            
            //finally update list of contacts
			if(!defConatctsToUpdate.isEmpty()){
				update defConatctsToUpdate;
			}
        }
        
        
        
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.InsertAccountDetailsToEXO',e.getLineNumber());	    
        }
    }
    
    public static void upsertContactDetailsToEXO(List<Id> ConIds){
        system.debug('enter into contact');
        try{
            List<Contact> Conlist= [SELECT id,FirstName,Contact_SEQ_No__c,owner.Name,LastName,HasOptedOutOfEmail,Salutation,Role__c,MobilePhone,
                                    Phone,Fax,HomePhone,Email,Active__c,Sales_Person_Code_in_Exo__c,OtherStreet,OtherCity,OtherCountry,DR_CR_Contact_Seq_number__c,
                                    OtherPostalCode,MailingStreet,MailingCity,MailingState,MailingCountry,Account.AccountNumber__c,Account.RecordTypeId,Account.Default_Contact__c,
                                    Account.Default_Contact__r.Id,Account.Default_Contact__r.Contact_SEQ_No__c,Account.Name,LastModifiedDate 
                                    FROM Contact WHERE Id IN : ConIds];
             
            List<Rest_ExoWrappers.ContactDetails> ContactInfoList = new List<Rest_ExoWrappers.ContactDetails>();
            Map<Id,Contact> contactMap = new Map<Id,Contact>();
            if(!ConList.isEmpty()){
                System.debug('oppList ' + ConList);
                Set<Id> AcctIds = new Set<Id>(); 
                for(Contact con : ConList){
                    ConIds.add(con.Id);    
                }
                for(Contact con : ConList){
                    system.debug('in for loop...');
                   
                    Rest_ExoWrappers.ContactDetails ContactDetails = new Rest_ExoWrappers.ContactDetails();
                    ContactDetails.SEQNO  = con.Contact_SEQ_No__c;
                    ContactDetails.SalesforceID = con.id;
                    ContactDetails.SALUTATION = con.Salutation;
                    ContactDetails.FIRSTNAME = con.FirstName;
                    ContactDetails.LASTNAME = con.LastName;
                    ContactDetails.TITLE = con.Role__c;
                    ContactDetails.MOBILE= con.MobilePhone;
                    ContactDetails.DIRECTPHONE = con.Phone;
                    ContactDetails.DIRECTFAX = con.Fax;
                    ContactDetails.HOMEPHONE = con.HomePhone;
                    ContactDetails.EMAIL= con.Email ;
                    
                    ContactDetails.ADDRESS1 = con.OtherStreet;
                    ContactDetails.ADDRESS3 = con.OtherCity;
                    ContactDetails.ADDRESS4 = con.OtherCountry;
                    ContactDetails.POST_CODE = con.OtherPostalCode;
                    
                    ContactDetails.DELADDR1 = con.MailingStreet;
                    ContactDetails.DELADDR3 = con.MailingCity;
                    //ContactDetails.DELADDR4 = con.MailingState;
                    ContactDetails.DELADDR4 = con.MailingCountry;
                    
                    ContactDetails.ISACTIVE = con.Active__c;
                    
                    ContactDetails.SALESNO = sales_person__c.getAll().get(con.owner.Name) != null ? sales_person__c.getAll().get(con.owner.Name).staff_number__c : sales_person__c.getAll().get('Integration User').staff_number__c ;
                    ContactDetails.COMPANY_ACCNO = con.Account.AccountNumber__c;
                    ContactDetails.LAST_UPDATED = con.LastModifiedDate;
                    ContactDetails.OPTOUT_EMARKETING = con.HasOptedOutOfEmail;
                    if(Con.Account!=null){
                    	ContactDetails.COMPANY_ACCTYPE = string.valueOf(con.Account.RecordTypeId).substring(0,15) == string.valueOf(Label.BoaSupplierCustomer).substring(0,15) ? 2 : 1 ;
                    }
                    ContactInfoList.add(ContactDetails);
                    
                    // add to contact map as well
                    contactMap.put(con.Id,con);
                }                 
            }
            //sending out a request 
            Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
            
            responseWrapper = Rest_outboundCaller.postHttpRequestExo('/contact','',Json.serialize(ContactInfoList));
            System.debug('Json.serialize(ContactInfoList[0]) ' + Json.serialize(ContactInfoList[0]));
           
            //logic to update order numner and order line item number starts from this point
            If(responseWrapper.responseCode == 200){
                Rest_ExoResponseWrapper.contactResponseWrapper responseObj = (Rest_ExoResponseWrapper.contactResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.contactResponseWrapper.class);
                system.debug('NewresponseObj--'+responseObj);
               // list<contact> updOppList = new list<contact>();
                 List<Contact> ContactList = new list<Contact>();
                // response parsing logic                    
                if(!responseObj.contactData.isEmpty()){
                    
                    
                    for(Rest_ExoResponseWrapper.cls_contactData s : responseObj.contactData){
                        // add Contact to update in contact list
                        Contact conObj = new Contact();
      
                        // adding contact data
                        ConObj.Id = s.SalesforceID;
                        ConObj.Contact_SEQ_No__c = s.SEQNO;
                        //adding account data
                        conObj.DR_CR_Contact_Seq_number__c = contactMap.get(s.SalesforceID).DR_CR_Contact_Seq_number__c;
                        if(contactMap.get(s.SalesforceID).AccountId != null){
                        	Account customer = new Account();
                            customer.Id = contactMap.get(s.SalesforceID).AccountId;
                        	customer.AccountNumber__c = contactMap.get(s.SalesforceID).Account.AccountNumber__c;
                        	customer.recordTypeId = contactMap.get(s.SalesforceID).Account.recordTypeId;
                        	if(contactMap.get(s.SalesforceID).Account.Default_Contact__c !=  null){
                        		Contact defContact = new Contact();
                                defContact.Id = contactMap.get(s.SalesforceID).Account.Default_Contact__r.Id;
                                defContact.Contact_SEQ_No__c = contactMap.get(s.SalesforceID).Account.Default_Contact__r.Contact_SEQ_No__c;
                                customer.Default_Contact__r = defContact;
                            }
                        //assigning customer data to conObj
                        conObj.Account = customer;
                        }
                        ContactList.add(conObj);
                    }
                }
               
                if(!ContactList.isEmpty()){ 
                 // Now to call out to create CR and DR contacts in EXO
                 List<Contact> updContactList = Rest_ExoOutboundHandler.upsertCrAndDrContactsToEXO(ContactList);
                    if(!updContactList.isEmpty()){
                        update updContactList;
                    }   
                }
               
            }
        }
        
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.upsertContactDetailsToEXO',e.getLineNumber());	    
        }
    } 
    //Upsert CR DR contacts 
   public static list<Contact> upsertCrAndDrContactsToEXO(List<Contact> conlist){
        system.debug('enter into cr dr contacts');
        list<contact> conObjList = new list<contact>();
       	try{
            //List<Contact> conlist = [select Id,Is_Default_Contact__c, Contact_SEQ_No__c,Account.AccountNumber__c,Account.RecordTypeId  from contact where Id IN : ConIds ];
            List<Rest_ExoWrappers.Cr_contact> CrDrInfoList = new List<Rest_ExoWrappers.Cr_contact>();
            List<Rest_ExoWrappers.Cr_contact> CrInfoList = new List<Rest_ExoWrappers.Cr_contact>();
			List<Rest_ExoWrappers.Cr_contact> DrInfoList = new List<Rest_ExoWrappers.Cr_contact>();
			Map<Id,Id> contactIdToRecordTypeIDMap = new Map<Id,Id>();
			
			for(Contact cn : conlist){
                Rest_ExoWrappers.Cr_contact contactWrap =new Rest_ExoWrappers.Cr_contact();
                contactWrap.SalesforceID = cn.Id;
                contactWrap.SEQNO = cn.DR_CR_Contact_Seq_number__c;
                contactWrap.CONTACT_SEQNO = cn.Contact_SEQ_No__c;
                contactWrap.ACCNO = cn.Account.AccountNumber__c;
                If(cn.Account.Default_Contact__r.id!= null && cn.Account.Default_Contact__r.Contact_SEQ_No__c == cn.Contact_SEQ_No__c){
                    system.debug('Account default contact'+cn.Account.Default_Contact__r.id);
                    contactWrap.DEFCONTACT = 'Y';
                }
                else{
                 contactWrap.DEFCONTACT = 'N';
                }
                contactWrap.DEFACCOUNT = 'N';
                CrDrInfoList.add(contactWrap);
				
				//add to map
				contactIdToRecordTypeIDMap.put(cn.Id,cn.Account.RecordTypeId);
            }
            
            Rest_ExoWrappers.genericOutboundResponseWrapper CRresponseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
			Rest_ExoWrappers.genericOutboundResponseWrapper DRresponseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
            
            for(Rest_ExoWrappers.Cr_contact contactWrap : CrDrInfoList){
				if(contactIdToRecordTypeIDMap.get(contactWrap.SalesforceId) == System.Label.BoaEnterpriseCustomer){
					DrInfoList.add(contactWrap);
				}
				else if(contactIdToRecordTypeIDMap.get(contactWrap.SalesforceId) == System.Label.BoaSupplierCustomer){
					CrInfoList.add(contactWrap);
				}
			}
			
			
			if(!CrInfoList.isEmpty()){
                system.debug('CrInfoList--'+CrInfoList);
                CRresponseWrapper = Rest_outboundCaller.postHttpRequestExo('/contact/cr','',Json.serialize(CrInfoList));
                system.debug('CRresponseWrapper--'+CRresponseWrapper);
             }
            
			if(!DrInfoList.isEmpty()){
                DRresponseWrapper = Rest_outboundCaller.postHttpRequestExo('/contact/dr','',Json.serialize(DrInfoList));
             }
			 			
            //logic to update order numner and order line item number starts from this point
            If(CrResponseWrapper.responseCode == 200){
                Rest_ExoResponseWrapper.CrcontactResponseWrapper responseObj = (Rest_ExoResponseWrapper.CrcontactResponseWrapper) JSON.deserialize(CrResponseWrapper.responseBody, Rest_ExoResponseWrapper.CrcontactResponseWrapper.class);
                system.debug('NewresponseObj--'+responseObj);
                
                if(!responseObj.contactData.isEmpty()){
                    for(Rest_ExoResponseWrapper.cr_contactData s : responseObj.contactData){
                        contact conObj = new contact();
                        conObj.id=s.SalesforceID; 
                        conObj.Contact_SEQ_No__c = s.CONTACT_SEQNO;
                        conObj.DR_CR_Contact_Seq_number__c = s.SEQNO;
                        conObjList.add(conObj);

                    }
                }
            }

			If(DrResponseWrapper.responseCode == 200){
                Rest_ExoResponseWrapper.CrcontactResponseWrapper responseObj = (Rest_ExoResponseWrapper.CrcontactResponseWrapper) JSON.deserialize(DrResponseWrapper.responseBody, Rest_ExoResponseWrapper.CrcontactResponseWrapper.class);
                system.debug('NewresponseObj--'+responseObj);
                
                if(!responseObj.contactData.isEmpty()){
                    for(Rest_ExoResponseWrapper.cr_contactData s : responseObj.contactData){
                        contact conObj = new contact();
                        conObj.id=s.SalesforceID; 
                        conObj.Contact_SEQ_No__c = s.CONTACT_SEQNO;
                        conObj.DR_CR_Contact_Seq_number__c = s.SEQNO;
                        conObjList.add(conObj);

                    }
                }
            }

			if(!conObjList.isEmpty()){
               //     update conObjList;
                }		
				
        }
        
        
    
        Catch(Exception e){
              errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.upsertCRContactsToEXO',e.getLineNumber());	    
        
        }
       return conObjList;
    }
    
    public static void upsertStockSupplierDetailsToEXO(List<Id> stockIds){
        system.debug('enter into stock Supplier item');
        try{
            List<Stock_Supplier__c> stockSupplier = [select id,Discount_Percentage__c,Pack_Reference__c,Stock_Item__r.Name,Supplier_Name__r.AccountNumber__c,Supplier_Description__c,Name,Stock_Item__c,Supplier_Code__c,Is_Default__c,Quantity_per_pack__c,Pack_Price__c from Stock_Supplier__c	where Id IN : stockIds];
            List<Rest_ExoWrappers.stock_supplier> stockSupplierList = new list<Rest_ExoWrappers.stock_supplier>();
            List<Id> StockItemId = new List<Id>();
            if(!stockSupplier.isEmpty()){
                System.debug('oppList ' + stockSupplier);
                Set<Id> AcctIds = new Set<Id>(); 
                for(Stock_Supplier__c stockSupp: stockSupplier){
                    stockIds.add(stockSupp.Id); 
                }
            }
            
            for(Stock_Supplier__c stk : stockSupplier){
                system.debug('in for loop...');
                Rest_ExoWrappers.stock_supplier StockSupplierDetails = new Rest_ExoWrappers.stock_supplier();
                StockSupplierDetails.ACCNO = stk.Supplier_Name__r.AccountNumber__c!= null? stk.Supplier_Name__r.AccountNumber__c:null;
                StockSupplierDetails.IS_DEFAULT = stk.Is_Default__c ? 'Y':'N';
                StockSupplierDetails.PURCHPACKPRICE = stk.Pack_Price__c!=null?stk.Pack_Price__c:null;
                StockSupplierDetails.PURCHPACKQUANT = stk.Quantity_per_pack__c!= null? stk.Quantity_per_pack__c:null;
                StockSupplierDetails.STOCKCODE = stk.Stock_Item__r.Name!=null?stk.Stock_Item__r.Name:null;
                StockSupplierDetails.SUPPLIERCODE =stk.Name!=null?stk.Name:null;  
                StockSupplierDetails.DESCRIPTION = stk.Supplier_Description__c!=null?stk.Supplier_Description__c:null;
                StockSupplierDetails.PACKREFERENCE = stk.Pack_Reference__c!=null?stk.Pack_Reference__c:null;
                StockSupplierDetails.DISCOUNT = stk.Discount_Percentage__c!=null? stk.Discount_Percentage__c:null;
                 StockItemId.add(stk.Stock_Item__r.id);

                stockSupplierList.add(StockSupplierDetails);
                
                
             }
            system.debug('@2'+stockIds[0]);
            //sending out a request 
            Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
           
            responseWrapper = Rest_outboundCaller.postHttpRequestExo('/supplStockItem','',Json.serialize(stockSupplierList));
             if (stockSupplierList[0].IS_DEFAULT =='Y'){
                  
                 Rest_ExoOutboundHandler.upsertStockItemDetailsToEXO(StockItemId);
            }
            System.debug('Json.serialize(stockSupplierList) ' + Json.serialize(stockSupplierList));

            //logic to update order numner and order line item number starts from this point
            If(responseWrapper.responseCode == 200){
                system.debug('stock resposne body--'+responseWrapper.responseBody);
                Rest_ExoResponseWrapper.stockItemResponseWrapper responseObj = (Rest_ExoResponseWrapper.stockItemResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.stockItemResponseWrapper.class);
                system.debug('NewresponseObj--'+responseObj);
               	
            }
        }
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.upsertStockSupplierDetailsToEXO',e.getLineNumber());	    
            
        }
    }
    public static void upsertStockItemDetailsToEXO(List<Id> stockIds){
        system.debug('enter into stockitem');
        try{
            //searching for non BOM products only
            List<product2> stocklist= [SELECT Name,Description,Primary_group__c,Secondary_Group__c,Stock_Classification__c,
                                       Price_Group__c,QuantityUnitOfMeasure__c,isActive,Discountable__c,
                                       isRestricted_Goods__c,isLookup__c,EOQ__c,weight__c,
                                       purchase_GST__c,ProductCode,COS_GL_code_Subcode__c,
                                       Purchase_GL_code_Subcode__c,barcode1__c,barcode2__c,barcode3__c,
                                       pop_up_alert__c,LastModifiedDate,Stock_Primary_Supplier__r.AccountNumber__c,Total_Stock__c,Cubic_del__c,Tertiary_Group__c FROM product2 WHERE 
                                       Id IN : stockIds AND Bill_of_Material__c = false];
                List<Rest_ExoWrappers.StockItem> stockInfoList = new List<Rest_ExoWrappers.StockItem>();
            system.debug('#######'+stocklist.size());
            if(!stocklist.isEmpty()){
                System.debug('stockList ' + stocklist);
                Set<Id> AcctIds = new Set<Id>(); 
                for(product2 stk : stocklist){
                    stockIds.add(stk.Id);    
                }
                for(product2 stk : stocklist){
                    system.debug('in for loop...');
                    Rest_ExoWrappers.StockItem StockItemDetails = new Rest_ExoWrappers.StockItem();
                     string inputPrimaryGroup = stk.Primary_Group__c;
                    string delimiter = '-';
                    StockItemDetails.SALES_GL_CODE = stk.Primary_Group__c!=null? inputPrimaryGroup.substringBefore(delimiter):null;
                    StockItemDetails.SALES_GLSUBCODE =  stk.Primary_Group__c!=null? inputPrimaryGroup.substringAfter(delimiter):null;

                    StockItemDetails.STOCKCODE = stk.Name;
                    if(stk.ProductCode.length()>=40){
                    StockItemDetails.DESCRIPTION = stk.ProductCode.substring(0,40);
                    } 
                    else{                        
                   StockItemDetails.DESCRIPTION = stk.ProductCode;
                    }
                    StockItemDetails.STOCKGROUP2 = stk.Secondary_Group__c;
                    StockItemDetails.STOCKGROUP=stk.Tertiary_Group__c;
                    StockItemDetails.STOCK_CLASSIFICATION = stk.Stock_Classification__c;
                    StockItemDetails.STOCKPRICEGROUP = stk.Price_Group__c;
                    StockItemDetails.PACK = stk.QuantityUnitOfMeasure__c;
                    StockItemDetails.ISACTIVE = stk.isActive? 'Y':'N';
                    StockItemDetails.IS_DISCOUNTABLE = stk.Discountable__c ?'Y':'N';

                    StockItemDetails.RESTRICTED_ITEM = stk.isRestricted_Goods__c ?'Y':'N';

                    StockItemDetails.STATUS = stk.isLookup__c?'L':'S';

                    StockItemDetails.ECONORDERQTY = stk.EOQ__c;
                    StockItemDetails.WEIGHT=stk.weight__c; 
                    StockItemDetails.CUBIC = stk.Cubic_del__c;
                    StockItemDetails.PURCHTAXRATE = stk.purchase_GST__c;
                    
                    StockItemDetails.SUPPLIERNO = stk.Stock_Primary_Supplier__r.AccountNumber__c; 

                   
                                       
                    string inputPurchaseGLcodeGLsubcode = stk.Purchase_GL_code_Subcode__c;
                    string inputCOSGLcodeGLsubcode = stk.COS_GL_code_Subcode__c;
                    StockItemDetails.PURCH_GL_CODE = stk.Purchase_GL_code_Subcode__c!=null? inputPurchaseGLcodeGLsubcode.substringBefore(delimiter):null;
                    StockItemDetails.PURCH_GLSUBCODE = stk.Purchase_GL_code_Subcode__c!=null? inputPurchaseGLcodeGLsubcode.substringAfter(delimiter):null;
                    StockItemDetails.COS_GL_CODE = stk.COS_GL_code_Subcode__c!=null? inputCOSGLcodeGLsubcode.substringBefore(delimiter):null;  
                    StockItemDetails.COS_GLSUBCODE = stk.COS_GL_code_Subcode__c!=null? inputCOSGLcodeGLsubcode.substringAfter(delimiter):null;
                    StockItemDetails.BARCODE1 = stk.barcode1__c;
                    StockItemDetails.BARCODE2 = stk.barcode2__c;
                    StockItemDetails.BARCODE3 = stk.barcode3__c;
                    StockItemDetails.ALERT = stk.pop_up_alert__c;
                    StockItemDetails.LAST_UPDATED =stk.LastModifiedDate;
                   // List<Stock_Supplier__c> stckSupplier = [select id,Supplier_Name__c from Stock_Supplier__c where Stock_Item__c =: stk.id LIMIT 1];
                    //system.debug('Stock suppliers list'+stckSupplier[0]);
                   /* if(!stckSupplier.isEmpty()){
                        for(Stock_Supplier__c st :stckSupplier){
                            system.debug('Stock supplier available');
                            List <Account> acc = [select AccountNumber__c ,id from Account where id=: st.Supplier_Name__c LIMIt 1];
                            if(!acc.isEmpty()){
                                system.debug('Account seq number'+acc[0].AccountNumber__c);
                                StockItemDetails.SUPPLIERNO = acc[0].AccountNumber__c!= null ? acc[0].AccountNumber__c:null;
                            }
                        }
                    }*/
                    
                    StockItemDetails.SalesforceID = stk.id;
                  
                    stockInfoList.add(StockItemDetails);
                    
                }                 
            }
            //sending out a request 
            Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
                        System.debug('####' + Rest_outboundCaller.postHttpRequestExo('/stockitems','',Json.serialize(stockInfoList)));

            responseWrapper = Rest_outboundCaller.postHttpRequestExo('/stockitems','',Json.serialize(stockInfoList));
            System.debug('#' + Json.serialize(stockInfoList));
          
            //logic to update order numner and order line item number starts from this point
            If(responseWrapper.responseCode == 200){
                system.debug('stock resposne body--'+responseWrapper.responseBody);
                Rest_ExoResponseWrapper.stockItemResponseWrapper responseObj = (Rest_ExoResponseWrapper.stockItemResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.stockItemResponseWrapper.class);
                system.debug('NewresponseObj--'+responseObj);
               	
            }
        }catch(Exception e){
         system.debug('##########'+e);
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.InsertStockItemDetailsToEXO',e.getLineNumber());	    
}
    } 
    
    public static void upsertPriceBookDetailsToEXO(List<Id> stockIds){
        system.debug('enter into priceBook');
        try{
            List<PricebookEntry> priceBooklist= [SELECT id,Product2.Name, Pricebook2Id,Retail_Price__c,Contractor_Price__c,Trade_Price__c,Wholesale_Price__c,
                                                 Dealer_Price__c,Bulk_Buy_Price__c,Last_Cost__c,Average_Cost__c ,Standard_Cost__c,
                                                 Supplier_Cost__c FROM PricebookEntry WHERE Id IN : stockIds ];
            List<Rest_ExoWrappers.priceBook> priceBookInfoList = new List<Rest_ExoWrappers.priceBook>();
            
            if(!priceBooklist.isEmpty()){
                
                Set<Id> AcctIds = new Set<Id>(); 
                for(PricebookEntry stk : priceBooklist){
                    stockIds.add(stk.Id);    
                }
                for(PricebookEntry prc : priceBooklist){
                    system.debug('in for loop...');
                    Rest_ExoWrappers.priceBook priceBookDetails = new Rest_ExoWrappers.priceBook();
                    priceBookDetails.STOCKCODE = prc.Product2.Name;
                    priceBookDetails.SELLPRICE1 = prc.Retail_Price__c;
                    priceBookDetails.SELLPRICE2 = prc.Contractor_Price__c;
                    priceBookDetails.SELLPRICE3 = prc.Trade_Price__c;
                    priceBookDetails.SELLPRICE16 =prc.Wholesale_Price__c;
                    priceBookDetails.SELLPRICE17 = prc.Dealer_Price__c;
                    priceBookDetails.SELLPRICE18 = prc.Bulk_Buy_Price__c;
                    //Fields in doubt
                    priceBookDetails.LATESTCOST = prc.Last_Cost__c;
                    priceBookDetails.AVECOST = prc.Average_Cost__c;
                    priceBookDetails.STDCOST = prc.Standard_Cost__c;
                    priceBookDetails.SUPPLIERCOST = prc.Supplier_Cost__c;
                    priceBookInfoList.add(priceBookDetails);             
                    
                }
            }
            
            //sending out a request 
            Rest_ExoWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
            
            responseWrapper = Rest_outboundCaller.postHttpRequestExo('/stockitems','',Json.serialize(priceBookInfoList));
            System.debug('Json.serialize(priceBookInfoList) ' + Json.serialize(priceBookInfoList));
            
            //logic to update order numner and order line item number starts from this point
            If(responseWrapper.responseCode == 200){
                Rest_ExoResponseWrapper.priceBookResponseWrapper responseObj = (Rest_ExoResponseWrapper.priceBookResponseWrapper) JSON.deserialize(responseWrapper.responseBody, Rest_ExoResponseWrapper.priceBookResponseWrapper.class);
                system.debug('NewresponseObj--'+responseObj);
              
            }
        }
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.upsertPriceBookDetailsToEXO',e.getLineNumber());	    
        }
        
    }
    
    //method to upsert BOM to EXO
    public static void upsertBOMToExo (list<id> bomIds){
        system.debug('enter into BOM');
        try{
            list<string> outPutCodes = new list<string>();
            List<product2> bomList= [SELECT Id,Name,ProductCode,Pricing_Mode__c,Output_Code__c,HideLineItem__c,
                                     Description,IsActive,
                                     (select Id,Name,Stock_Item__r.Name,Quantity__c,Description__c
                                      FROM Bill_Of_Material__r),
                                     (Select Id,Retail_Price__c,Trade_Price__c,Wholesale_Price__c,Bulk_Buy_Price__c,
                                      Contractor_Price__c,Dealer_Price__c,Average_Cost__c 
                                      FROM PriceBookEntries WHERE Pricebook2.IsStandard = true) 
                                     FROM product2 WHERE Id IN : bomIds AND Bill_of_Material__c = true];
            
            List<Rest_ExoWrappers.bomWrapper> bomWrapperList = new List<Rest_ExoWrappers.bomWrapper>();
            
            if(!bomList.isEmpty()){
                for(product2 bom : bomList){
                    Rest_ExoWrappers.bomWrapper bomWrap =  new Rest_ExoWrappers.bomWrapper();
                    //filling in BOM Header generic data 
                    bomWrap.bomHdr.BILLCODE = bom.Name;
                    bomWrap.bomHdr.DESCRIPTION = bom.ProductCode;
                    bomWrap.bomHdr.PRICING_MODE = integer.valueOf(bom.Pricing_Mode__c);
                    bomWrap.bomHdr.OUTPUT_CODE = bom.Output_Code__c;
                    bomWrap.bomHdr.BATCH_QTY = 1; //passing default hard coded value as 1.
                    bomWrap.bomHdr.HIDE_LINES = bom.HideLineItem__c == true ? 'Y' : 'N' ;
                    bomWrap.bomHdr.NOTES = bom.Description;
                    bomWrap.bomHdr.ISACTIVE = bom.IsActive  == true ? 'Y' : 'N';
                    bomWrap.bomHdr.KIT_TYPE = 0; //passing default hard coded value as 0.
                    bomWrap.bomHdr.BOMTYPE = 'B'; //passing default hard coded value as B
                    bomWrap.bomHdr.AUTOBUILD = 'N';//passing default hard coded value as N.
                    
                    //filling BOM pricing related data
                    if(!bom.PriceBookEntries.IsEmpty()){
                        for(pricebookentry pb: bom.PriceBookEntries){
                            bomWrap.bomHdr.SELLPRICE1 = pb.Retail_Price__c;
                            bomWrap.bomHdr.SELLPRICE2 = pb.Contractor_Price__c;
                            bomWrap.bomHdr.SELLPRICE3 = pb.Trade_Price__c;
                            bomWrap.bomHdr.SELLPRICE16 = pb.wholesale_Price__c;
                            bomWrap.bomHdr.SELLPRICE17 = pb.dealer_Price__c;
                            bomWrap.bomHdr.SELLPRICE18 = pb.Bulk_Buy_Price__c;    
                        }
                    }
                    
                    //filling BOM Line Items data    
                    if(!bom.Bill_Of_Material__r.IsEmpty()){
                        for(BOM_Line_Item__c bli: bom.Bill_Of_Material__r){
                            Rest_ExoWrappers.BomLines bliWrap = new Rest_ExoWrappers.BomLines();
                            bliWrap.BILLCODE = bli.Stock_Item__r.Name;
                            bliWrap.DESCRIPTION = bli.Description__c;
                            bliWrap.QUANTITY = bli.Quantity__c;
                            bliWrap.STOCKCODE = bli.Name;
                            //add this bliWrap to bomHdr wrapper list
                            bomWrap.bomHdr.bomLines.add(bliWrap);
                        }
                    }    
                    //add output Code to list outputCodes for further reference
                    if(string.isNotBlank(bom.Output_Code__c)){
                        outputCodes.add(bom.Output_Code__c);        
                    }
                    
                    //add now whole bomWrap to bomWrapperList
                    bomWrapperList.add(bomWrap);
                }                 
            }
            
            //before inserting a BOM we need to insert a stock Item in EXO, if BOM has output Code associated with it.
            if(!bomWrapperList.isEmpty()){
                list<Id> stockItemIds = new list<Id>();
                
                //creating stockItems first in Exo before creating BOM
                if(!outPutCodes.isEmpty()){
                    for(Product2 stck : [SELECT Id from product2 where output_Code__c IN: outPutCodes]){
                        stockItemIds.add(stck.Id);
                    }
                   // Rest_ExoOutboundHandler.upsertStockItemDetailsToEXO(stockItemIds);
                   // Rest_ExoOutboundHandler.upsertPriceBookDetailsToEXO(stockItemIds);
                } 
            }
            
            //sending out a request to create BOM now
            Rest_ExoWrappers.genericOutboundResponseWrapper bomResponseWrapper = new Rest_ExoWrappers.genericOutboundResponseWrapper();
            bomResponseWrapper = Rest_outboundCaller.postHttpRequestExo('/bom','',Json.serialize(bomWrapperList[0]));
            System.debug('Json.serialize(bomWrapperList) ' + Json.serialize(bomWrapperList));
          
            //logic to update order numner and order line item number starts from this point
            If(bomResponseWrapper.responseCode == 200){
                /** Parsing logic is yet to be added. TBD. **/
                system.debug('inside if--'+bomResponseWrapper.responseBody);
                
                
            }
        }
        
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_ExoOutboundHandler.upsertBOMToExo',e.getLineNumber());	    
        }
    }
}