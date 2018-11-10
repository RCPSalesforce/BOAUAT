public class CustomerController {
    
    public class responseWrapper{
        public boolean isSuccess;
        public string message;
        public string contactId;
        public string customerId;
        public boolean isActive;
        public string deliveryAddressId;
    }
    
    public class orderResponseWrapper{
        public boolean isSuccess;
        public string message;
        public string orderId;
        public string name;
        public string orderStatus;
    } 
    
    public class leadResponseWrapper{
        public boolean isSuccess;
        public string message;
        public string leadId;            
    }
    
    
    
    /* This method  - 1. Will create a contact in salesforce and account creation / linkage has to be taken care manually 
by BOA sales team*/    
    public static responseWrapper customerSignUpForRetailCustomer(string signupInfo){
        responseWrapper response = new responseWrapper();
        try{
            Rest_WebPortalWrappers.signupInformation signupInfoDetails = (Rest_WebPortalWrappers.signupInformation)JSON.deserialize(signupInfo, Rest_WebPortalWrappers.signupInformation.class); 
            System.debug('signupInfoDetails deserialize: ' + signupInfoDetails);
            if(signupInfoDetails.typeOfCustomer == 'Retail Customer'){
                Account a = new Account();
                a.RecordTypeId = label.Account_Record_Type_Retail_Customers;
                a.FirstName = signupInfoDetails.pFirstName;
                a.LastName = signupInfoDetails.pLastName;
                a.PersonEmail = signupInfoDetails.personEmail;
                a.PersonMobilePhone = signupInfoDetails.personMobilePhone;
                a.Type_of_Business__c = signupInfoDetails.typeOfBusiness;
                a.Base_Price__c = 'Retail';
                a.Verified__pc = signupInfoDetails.verified;
                // active as portal user
                a.IsActive__c = true;
                a.Portal_Customer__c = true;
                
                insert a;
                
                List<Contact> conList = [SELECT Id FROM Contact WHERE Email =: a.PersonEmail LIMIT 1];
                
                response.isSuccess = true;
                response.message = 'User successfully created  in salesforce';
                response.customerId = a.Id;
                response.contactId = conList[0].Id;
                response.isActive = a.IsActive__c;              
                
                
            }
            
            if(signupInfoDetails.typeOfCustomer == 'Enterprise Customer'){                
                return customerSignUpForEnterpriseCustomer(signupInfo);
            }          
            
        }
        catch(exception e){
            response.isSuccess = false;
            response.message = 'Something went wrong...';
            
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.customerSignUpForRetailCustomer',e.getLineNumber());    
        }       
        
        return response;
    }
    /* This method will create Enterprise customer ahd contact in Salesforce */
    public static responseWrapper customerSignUpForEnterpriseCustomer(string signupInfo){
        System.debug('Enterprise...');
        responseWrapper response = new responseWrapper();
        try{
            Rest_WebPortalWrappers.signupInformation signupInfoDetails = (Rest_WebPortalWrappers.signupInformation)JSON.deserialize(signupInfo, Rest_WebPortalWrappers.signupInformation.class); 
            System.debug('signupInfoDetails deserialize: ' + signupInfoDetails);            
            
            contact newPortalUser = new contact();
            
            newPortalUser.firstName = signupInfoDetails.firstName;
            newPortalUser.lastName = signupInfoDetails.lastName;
            newPortalUser.email = signupInfoDetails.email;
            newPortalUser.MobilePhone = signupInfoDetails.mobileNumber;
            newPortalUser.OtherPhone = signupInfoDetails.officePhoneNumber;
            newPortalUser.Customer_Name_from_Portal__c = signupInfoDetails.companyName;
            newPortalUser.Role__c = signupInfoDetails.userRole;
            newPortalUser.Industry_Type_from_Portal__c = signupInfoDetails.Industry;
            newPortalUser.verified__c = signupInfoDetails.verified;
            //assigning default flags on contact
            newPortalUser.Active__c = false;
            newPortalUser.Portal_Contact__c = true;
            
            insert newPortalUser;
            
            response.isSuccess = true;
            response.message = 'User successfully created  in salesforce';
            response.contactId = newPortalUser.Id;
            response.isActive = newPortalUser.Active__c;
            
        }
        catch(exception e){
            response.isSuccess = false;
            response.message = 'Something went wrong...';
            
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.customerSignUpForEnterpriseCustomer',e.getLineNumber());    
        }       
        
        return response;		    
    }
    
    /* This method will create credit application form in salesforce submitted from web portal*/
    public static responseWrapper createCAForm(string caform){
        Savepoint sp = Database.setSavepoint();
        responseWrapper response = new responseWrapper();        
        try{
            Rest_WebPortalWrappers.creditAformInformation cafinfowrap = (Rest_WebPortalWrappers.creditAformInformation)JSON.deserialize(caform, Rest_WebPortalWrappers.creditAformInformation.class);
            Credit_Application_Form__c caf = new Credit_Application_Form__c();
            caf.Customer_Name__c = cafinfowrap.customerId;
            caf.Submitted_By__c = cafinfowrap.submittedby;
            caf.Postal_Address__c = cafinfowrap.postaladdress;
            caf.Physical_Address__c = cafinfowrap.physicaladdress;
            caf.Date_Business_Started__c = cafinfowrap.businessstarteddate;
            caf.Registered_Office_Address__c = cafinfowrap.registeredofcadd;
            caf.Company_Registration_Number__c = cafinfowrap.companyregistrationno;
            caf.Type_Of_Business__c = cafinfowrap.typeofbusiness;
            caf.Fax__c = cafinfowrap.fax;
            caf.Phone__c = cafinfowrap.phone;
            caf.Email__c = cafinfowrap.email;
            caf.Bank_Name__c = cafinfowrap.bankname;
            caf.Branch_Name__c = cafinfowrap.branchname;
            caf.Manager__c = cafinfowrap.manager;
            caf.Manager_s_Email__c = cafinfowrap.memail;
            caf.Accounts__c = cafinfowrap.accounts;
            caf.Accounts_Email__c = cafinfowrap.aemail;
            caf.Purchasing__c = cafinfowrap.purchasing;
            caf.Purchasing_Email__c = cafinfowrap.pemail;
            caf.Reference1__c = cafinfowrap.reference1;
            caf.Reference_1_Phone__c = cafinfowrap.ref1phone;
            caf.Reference_2__c = cafinfowrap.reference2;
            caf.Reference_2_Phone__c = cafinfowrap.ref2phone;
            caf.Reference_3__c = cafinfowrap.reference3;
            caf.Reference_3_Phone__c = cafinfowrap.ref3phone;
            
            insert caf;
            
            response.isSuccess = true;
            response.message = 'Form submitted successfully in salesforce';
        }
        catch(exception e){
            database.rollback(sp);
            response.isSuccess = false;
            response.message = 'Something went wrong...';
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.createCaform',e.getLineNumber());    
            
        }
        return response;
    }
    
    /*This method will create order in Salesforce submitted from web portal*/
    public static orderResponseWrapper createorder(string orderinfo){
        system.debug('orderinfo ' + orderinfo);
        Savepoint sp = Database.setSavepoint();
        orderResponseWrapper ordResponse = new orderResponseWrapper();	
        try{
            Set<String> allOpportunityProductsName = new Set<String>();
            Map<String,PriceBookEntry> prodNameToPbeMap = new Map<String,PriceBookEntry>();
            List<OpportunityLineItem> insertOppLineItemList = new List<OpportunityLineItem>();
            
            
            Rest_WebPortalWrappers.orderInfo ord = (Rest_webPortalWrappers.orderInfo)JSON.deserialize(orderinfo, Rest_webPortalWrappers.orderInfo.class);
            system.debug('After deserialize...');
            if(ord.billOfMaterial == true){
                //if there are BOMS in order will try to insert them first.
                List<Rest_WebPortalWrappers.bomProducts> receivedBomListFromPortal  = ord.bomProducts;
                if(!receivedBomListFromPortal.isEmpty()){
                    Set<Id> insertedBomIds = Rest_WebPortalOutboundHandler.insertBomProducts(receivedBomListFromPortal);
                    // now insert pricing for these BOMs
                    system.debug('insertedBomIds ' + insertedBomIds);
                    List<PriceBookEntry> insertedPbe = Rest_WebPortalOutboundHandler.insertBomPrices(insertedBomIds);
                	system.debug('insertedPbe ' + insertedPbe);
                }
                
                //get set of all opportunity standard products name
            	for(Rest_WebPortalWrappers.bomProducts bomItem : ord.bomProducts){
                	allOpportunityProductsName.add(bomItem.StockCode);
            	}
            }
            
            //get set of all opportunity standard products name
            for(Rest_WebPortalWrappers.orderProducts oppitem : ord.orderProductsWrap){
                allOpportunityProductsName.add(oppItem.StockCode);
            }
            
            //get set of all opportunity standard products name
            /*for(Rest_WebPortalWrappers.bomProducts bomItem : ord.bomProducts){
                allOpportunityProductsName.add(bomItem.StockCode);
            }*/
            
            //insert opportunity first
            Opportunity opp = new Opportunity();
            ObjectAutoNumber__c so = ObjectAutoNumber__c.getInstance('Opportunity');            
            so.Number__c += 1;
            update so;
            opp.Name = string.valueOf(Integer.valueOf(so.Number__c));
            opp.AccountId = ord.customerId;
            opp.Order_Placed_By__c = ord.orderPlacedBy;
            opp.RecordTypeId = label.BoaSalesOrderRecordType;
            opp.CloseDate = system.today() + 30;
            opp.StageName = 'Prospecting';
            opp.CurrencyIsoCode = ord.orderCurrency;
            opp.Order_Date__c = ord.orderDate;
            opp.Order_Source__c = ord.orderSource;
            opp.Payment_type__c = ord.paymentType;
            if(ord.paymentType == 'BOA Credit'){
                opp.Web_Portal_Order_Status__c = 'WP-Confirmed';
            }
            else if(ord.paymentType == 'Payment Express'){
                opp.Web_Portal_Order_Status__c = 'WP-PaymentInitiated';    
            }
            opp.customer_order_number__c = ord.customerOrderNumber;
            opp.reference__c = ord.reference;
            opp.subtotal__c = ord.subTotal;
            opp.tax_total__c = ord.taxTotal;
            opp.Amount = ord.orderTotal;
            
            opp.Street__c = ord.address.street;
            opp.city__c = ord.address.city;
            opp.state__c = ord.address.state;
            opp.postal_code__c = ord.address.postalcode;
            opp.Country__c = ord.address.country; 
            insert opp;
             
            // fetch all related priceBookEntries
            for(PriceBookEntry pbe : [SELECT Id, Product2Id, Product2.Name FROM PriceBookEntry WHERE isActive = true AND PriceBook2.isStandard = true AND 
                                      Product2.Name IN: allOpportunityProductsName AND CurrencyIsoCode =: ord.customerCurrency])
            {
                prodNameToPbeMap.put(pbe.Product2.Name,pbe);
                system.debug('');
            }
            
            //insert standard product Opportunity Line Items
            for(Rest_WebPortalWrappers.orderProducts oppitem : ord.orderProductsWrap){
                OpportunityLineItem item = new OpportunityLineItem();
                item.OpportunityId = opp.Id;
                //item.Product2Id = ;
                item.PricebookEntryId = prodNameToPbeMap.get(oppitem.stockCode).Id;
                item.Description = oppitem.lineitemdescription;
                item.Quantity = oppitem.quantity;
                item.UnitPrice = oppitem.salesprice;
                insertOppLineItemList.add(item);
            }
            
            //  insert bom product as opportunity Line Items
            if(ord.billOfMaterial == true){
                for(Rest_WebPortalWrappers.bomProducts bomitem : ord.bomProducts){
                    OpportunityLineItem bomOli = new OpportunityLineItem();
                    bomOli.OpportunityId = opp.Id;
                    bomOli.PricebookEntryId = prodNameToPbeMap.get(bomitem.stockCode).Id;                    
                    bomOli.UnitPrice = bomitem.salesprice;
                    bomOli.Quantity = bomitem.quantity;
                    bomOli.Make_at_Boa__c = bomitem.makeAtBoa;
                    bomOli.Description = bomitem.lineItemDescription;
                    insertOppLineItemList.add(bomOli);                           	
                }
            }    
            
            //insert all opportunity line items
            if(!insertOppLineItemList.isEmpty()){
                insert insertOppLineItemList;
                
                ordResponse.isSuccess = true;
                ordResponse.message = 'Order Placed successfully';
                ordResponse.orderId = opp.Id;
                ordResponse.name = opp.Name;
                ordResponse.orderStatus = opp.Web_Portal_Order_Status__c;
            }
        }
        Catch(Exception e){
        	database.rollback(sp);
        	ordResponse.isSuccess = false;
            ordResponse.message = e.getMessage();
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.createorder',e.getLineNumber());    
        }
        
        return ordResponse;
        
    }
    
    
    public static orderResponseWrapper updateOrder(string orderInfo){
        Savepoint sp = Database.setSavepoint();
        orderResponseWrapper ordResponse = new orderResponseWrapper();
        try{
            Rest_WebPortalWrappers.orderInfo ordUpdate = (Rest_WebPortalWrappers.orderInfo)JSON.deserialize(orderInfo, Rest_WebPortalWrappers.orderInfo.class);
            List<Opportunity> oppList = [SELECT Id,Web_Portal_Order_Status__c,Transaction_Id__c  FROM Opportunity WHERE Id =: ordUpdate.salesforceId];
            if(!oppList.isEmpty()){
                oppList[0].Web_Portal_Order_Status__c = ordUpdate.webPortalOrderStatus;
                oppList[0].Transaction_Id__c = ordUpdate.transactionId;
                
                update oppList;
                
                ordResponse.isSuccess = true;
                ordResponse.message = 'Order Updated Successfully...';
                //ordResponse.                
            }
        }
        catch(Exception e){
            database.rollback(sp);
            ordResponse.isSuccess = false;
            ordResponse.message = 'Something went wrong...';
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.updateOrder',e.getLineNumber());	    
        }
        
        return ordResponse;
    }
    /* This method will delete delivery address in Salesforce*/
    public static responsewrapper deleteaddress(string addressinfo){
        Savepoint sp = Database.setSavepoint();
        ResponseWrapper response = new ResponseWrapper();
        try{
            Rest_WebPortalWrappers.deliveryAddressInfo addr = (Rest_WebPortalWrappers.deliveryAddressInfo)JSON.deserialize(addressinfo, Rest_WebPortalWrappers.deliveryAddressInfo.class);
            List<Delivery_address__c> addList = [SELECT Id FROM Delivery_address__c WHERE Id =: addr.deliveryAddressId];
            if(addList.size()>0){
                delete addList;
                response.isSuccess = true;
                response.message = 'Address deleted Sucessfully';
            }
        }
        catch(Exception e){
            database.rollback(sp);
            response.isSuccess = false;
            response.message = 'Something went wrong...';
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.deleteaddress',e.getLineNumber());
        }
        
        return response;
        
    }
    
    /* This method will update/insert delivery address in salesforce from webportal */
    public static responsewrapper updateDelAddress(string addressinfo){
        ResponseWrapper response = new ResponseWrapper();
        try{
            Rest_WebPortalWrappers.delAddressInfoUpdate deladdr = (Rest_WebPortalWrappers.delAddressInfoUpdate)JSON.deserialize(addressinfo, Rest_WebPortalWrappers.delAddressInfoUpdate.class);
            System.debug('deladdr ' + deladdr);
            String id = String.valueOf(deladdr.deliveryAddressId);
            if(string.isNotBlank(id)){
                System.debug('deladdr.deliveryAddressId ' + String.valueOf(deladdr.deliveryAddressId));
                List<Delivery_Address__c> daList = [SELECT Id FROM Delivery_Address__c WHERE Id =: deladdr.deliveryAddressId];                
                daList[0].Street__c = deladdr.deliveryAddress.street;
                daList[0].City__c = deladdr.deliveryAddress.city;
                daList[0].State__c = deladdr.deliveryAddress.state;
                daList[0].Country__c = deladdr.deliveryAddress.country;
                daList[0].Postal_Code__c = deladdr.deliveryAddress.postalcode;
                daList[0].Is_Primary__c = deladdr.deliveryAddress.isPrimary;
                
                update daList;
                
                response.isSuccess = true;
                response.message = 'Record updated successfully';
            }
            else{
                Account acc = [SELECT Id FROM Account WHERE id =: deladdr.customerId];
                Delivery_Address__c da = new Delivery_Address__c();
                da.Customers__c = acc.Id;
                da.Street__c = deladdr.deliveryAddress.street;
                da.City__c = deladdr.deliveryAddress.city;
                da.State__c = deladdr.deliveryAddress.state;
                da.Country__c = deladdr.deliveryAddress.country;
                da.Postal_Code__c = deladdr.deliveryAddress.postalcode;
                da.Is_Primary__c = deladdr.deliveryAddress.isPrimary;
                
                insert da;
                
                response.deliveryAddressId = da.Id;
                response.isSuccess = true;
                response.message = 'Record created successfully';
            }
            
            
        }
        catch(Exception e){
            response.isSuccess = false;
            response.message = 'Something went wrong...';
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.updateDelAddress',e.getLineNumber());
        } 
        
        return response;
    }
    
    public static LeadResponseWrapper insertLead(string leadinfo){
        //responseWrapper response = new responseWrapper();
        LeadResponseWrapper response = new LeadResponseWrapper();
        try{
            Rest_WebPortalWrappers.leadInfo lead = (Rest_WebPortalWrappers.leadInfo)JSON.deserialize(leadinfo, Rest_WebPortalWrappers.leadInfo.class);
            system.debug('lead json ' + lead);           
            List<Lead> lList = [SELECT Id,No_of_Hydraulic_Equipment__c,Requested_Demo__c,Viewed_Contact_Details__c,Number_of_Times_Lead_Visited__c,Industry,No_of_Hoses__c,FirstName,LastName,Company,Email,Phone,BOA_Offered_Cost__c,Current_Spend__c,Down_Time_in_Hrs_per_month__c,Existing_Cost__c,Hydraulic_Oil_Usage_Ltrs__c FROM Lead WHERE Email =: lead.email];
            System.debug('lList ' + lList);
            if(lList.size()>0){
                //l.Id = l.id;
                lList[0].FirstName = lead.firstName;
                lList[0].LastName = lead.lastName;
                lList[0].Company = lead.company;
                lList[0].Email = lead.email;
                lList[0].Phone = lead.phone;
                lList[0].BOA_Offered_Cost__c = lead.boaOfferrdCost;
                lList[0].Current_Spend__c = lead.currentSpend;
                lList[0].Down_Time_in_Hrs_per_month__c = lead.downTimeInHrs;
                lList[0].Existing_Cost__c = lead.existingCost;
                lList[0].Hydraulic_Oil_Usage_Ltrs__c = lead.hydraulicOilUsage;
                lList[0].Industry = lead.industry;
                lList[0].No_of_Hoses__c = lead.numberOfHose;
                lList[0].No_of_Hydraulic_Equipment__c = lead.NoOfHydraulicEquipment;
                //if(lead.rquestedDemo!=null){
                lList[0].Requested_Demo__c = lead.rquestedDemo;
                //}
                //if(lead.rquestedDemo!=null){
                lList[0].Viewed_Contact_Details__c = lead.viewBoaContactDetails;
                //}    
                //lList[0].Number_of_Times_Lead_Visited__c += 1;
                
                if(lead.flagcheck){
                    lList[0].Number_of_Times_Lead_Visited__c += 1;	    
                }
                
                update lList;
                response.isSuccess = true;
                response.message = 'Lead updated successfully';
                response.leadId =  lList[0].Id;                   
                
            }
            else {
                Lead newlead = new Lead();
                newlead.FirstName = lead.firstName;
                newlead.LastName = lead.lastName;
                newlead.Company = lead.company;
                newlead.Email = lead.email;
                newlead.Phone = lead.phone;
                newlead.BOA_Offered_Cost__c = lead.boaOfferrdCost;
                newlead.Current_Spend__c = lead.currentSpend;
                newlead.Down_Time_in_Hrs_per_month__c = lead.downTimeInHrs;
                newlead.Existing_Cost__c = lead.existingCost;
                newlead.Hydraulic_Oil_Usage_Ltrs__c = lead.hydraulicOilUsage;
                newlead.Industry = lead.industry;
                newlead.No_of_Hoses__c = lead.numberOfHose;
                newlead.LeadSource = 'Website';
                newlead.Number_of_Times_Lead_Visited__c = 1;
                newlead.No_of_Hydraulic_Equipment__c = 0;
                
                insert newlead;
                database.DMLOptions dmo = new database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                newlead.setOptions(dmo);
                response.isSuccess = true;
                response.message = 'Lead created successfully';
                response.leadId = newlead.Id;
                
            } 
            
            
        }
        catch(Exception e){
            response.isSuccess = false;
            response.message = e.getMessage();
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.insertLead',e.getLineNumber());            
        }
        
        return response;
    }
    
    public static leadResponseWrapper createLeadTask(string taskInfo){
        leadResponseWrapper response = new leadResponseWrapper();
        try{
            Rest_WebPortalWrappers.LeadTask taskDetails = (Rest_WebPortalWrappers.LeadTask)JSON.deserialize(taskInfo, Rest_WebPortalWrappers.LeadTask.class);
            task t = new task();
            t.WhoId = taskDetails.leadId;
            t.Subject = taskDetails.subject;
            t.OwnerId = taskDetails.owner;
            t.ActivityDate = taskDetails.dueDate;
            t.Description = taskDetails.description;
            
            insert t;
            response.isSuccess = true;
            response.message = 'Task created successfully';
            
        }
        catch(Exception e){
            response.isSuccess = false;
            response.message = e.getMessage();
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.createLeadTask',e.getLineNumber());    
        }
        return response;
    }
    
    public static responseWrapper updateContact(string contactInfo){
        Savepoint sp = Database.setSavepoint();
        responseWrapper response = new responseWrapper();
        try{
            Rest_WebPortalWrappers.signupInformation conInfo = (Rest_WebPortalWrappers.signupInformation)JSON.deserialize(contactInfo, Rest_WebPortalWrappers.signupInformation.class);	    
            if(conInfo.typeOfCustomer == 'enterprise'){
                List<Contact> conList = [SELECT Id,Verified__c,FirstName,LastName,Email,MobilePhone,OtherPhone FROM Contact WHERE Id =: conInfo.contactId];
                if(conList.size()==1){
                    conList[0].FirstName = conInfo.firstName;
                    conList[0].LastName = conInfo.LastName;
                    conList[0].email = conInfo.email;
                    conList[0].MobilePhone = conInfo.mobileNumber;
                    conList[0].OtherPhone = conInfo.officePhoneNumber;
                    conList[0].verified__c = conInfo.verified;
                    
                    update conList;
                    response.isSuccess = true;
                    response.message = 'User updated successfully';
                    
                }
            } 
            if(conInfo.typeOfCustomer == 'retail'){
                List<Account> accList = [SELECT Id,Verified__pc,FirstName,LastName,PersonEmail,PersonMobilePhone,Phone FROM Account WHERE Id =: conInfo.contactId];
                if(accList.size()==1){
                    accList[0].FirstName = conInfo.pFirstName;
                    accList[0].LastName = conInfo.pLastName;
                    accList[0].PersonEmail = conInfo.personEmail;
                    accList[0].PersonMobilePhone = conInfo.personMobilePhone;
                    accList[0].Phone = conInfo.officePhoneNumber;
                    accList[0].verified__pc = conInfo.verified;
                    update accList;
                    response.isSuccess = true;
                    response.message = 'User updated successfully';
                }
            }
        }
        catch(exception e){
            database.rollback(sp);
            response.isSuccess = false;
            response.message = 'Something went wrong...';
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'customerController.updateContact',e.getLineNumber());
        }
        
        return response;
    }
    
}