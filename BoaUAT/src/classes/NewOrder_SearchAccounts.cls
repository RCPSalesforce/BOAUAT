public with sharing class NewOrder_SearchAccounts {
    
    @AuraEnabled
    public static String searchAcc(String accountName,String objType,String type){
        if(type == 'customer'){
            try{
                if(accountName.length() == 0){
                    return null;
                }
                else{               
                    String sobject_type = objType;
                    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
                    Id retailCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                    Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
                    Map<String, Schema.SObjectField> object_fields_map = global_describe.get(sobject_type).getDescribe().fields.getMap();
                    for (String fieldName: object_fields_map.keySet()) {
                        if(fieldName == 'name'){
                            String objList = 'SELECT Id,Name,Pop_up_Alert__c FROM ' + objType + ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(accountName) + '%\' AND RecordTypeId IN (:customerRecordTypeId,:retailCustomerRecordTypeId) LIMIT 10';                                      
                            List<Sobject> acc = Database.query(objList);
                            return JSON.serialize(acc);
                        }
                        
                    }    
                    return '{"error": "Field name does not exists on ' + objType + ' Object"}';
                } 
            }
            catch(Exception e){
                return '{"error":"'+e.getMessage()+'"}';
            }
        }
        else if(type =='supplier'){
			try{
                if(accountName.length() == 0){
                    return null;
                }
                else{               
                    String sobject_type = objType;
		            Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Supplier').getRecordTypeId();
                    Id retailCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                    Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
                    Map<String, Schema.SObjectField> object_fields_map = global_describe.get(sobject_type).getDescribe().fields.getMap();
                    for (String fieldName: object_fields_map.keySet()) {
                        if(fieldName == 'name'){
                            String objList = 'SELECT Id,Name,Pop_up_Alert__c FROM ' + objType + ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(accountName) + '%\' AND RecordTypeId =: supplierRecordTypeId  LIMIT 10';                                      
                            List<Sobject> acc = Database.query(objList);
                            return JSON.serialize(acc);
                        }
                        
                    }    
                    return '{"error": "Field name does not exists on ' + objType + ' Object"}';
                } 
            }
            catch(Exception e){
                return '{"error":"'+e.getMessage()+'"}';
            }
        }
        else{
            return '{"error": "An error occurred"}';
        }
    }
    
    // Supplier Account
    @AuraEnabled
    public static String searchSupplierAcc(String accountName,String objType){
        try{
            if(accountName.length() == 0){
                return null;
            }
            else{               
                String sobject_type = objType;
                Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Supplier').getRecordTypeId();
                Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectField> object_fields_map = global_describe.get(sobject_type).getDescribe().fields.getMap();
                for (String fieldName: object_fields_map.keySet()) {
                    if(fieldName == 'name'){
                        String objList = 'SELECT Id,Name,Pop_up_Alert__c FROM ' + objType + ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(accountName) + '%\' AND RecordTypeId =: supplierRecordTypeId';                                      
                        List<Sobject> acc = Database.query(objList);
                        return JSON.serialize(acc);
                    }
                    
                }    
                return '{"error": "Field name does not exists on ' + objType + ' Object"}';
            } 
        }
        catch(Exception e){
            return '{"error":"'+e.getMessage()+'"}';
        }
    }
    
    @AuraEnabled
    public static String selectedAccDetails(String accId){
        String accObj = 'SELECT Id,Name FROM Account WHERE Id =:accId';
        try{
            Account acc = Database.query(accObj);  
            return JSON.serialize(acc);
        }
        catch(Exception e){
            return '{"error":"'+e.getMessage()+'"}';
        }       
    }
    
    @AuraEnabled
    public static String selectedAccInfo(String accId, String type){
        if(type == 'customer'){
            System.debug('customer');
            String accObj = 'SELECT Id,Name,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Pop_up_Alert__c, Owner.Name, CurrencyIsoCode, Sea_Freight_Lead_Time__c, Air_Freight_Lead_Time__c, Need_Order_Number__c,(SELECT Customers__c, City__c,Country__c,Is_Primary__c,Postal_Code__c,Region__c,State__c,Street__c FROM Delivery_Addresses__r) FROM Account WHERE Id =:accId';
            String accPricingPolicy = 'SELECT Id FROM Pricing_Policy_with_Customer__c WHERE Customers__c =: accId';
            try{
                Account acc = Database.query(accObj);
                List<Delivery_Address__c> deladdr = acc.Delivery_Addresses__r;
                List<Pricing_Policy_with_Customer__c> accPricingP = Database.query(accPricingPolicy);
                String CurrencyIsoCode = acc.CurrencyIsoCode;
                String currencyInfo = 'SELECT ConversionRate FROM CurrencyType WHERE IsoCode =:CurrencyIsoCode AND IsActive = true';
                CurrencyType ct = Database.query(currencyInfo);
                String accountD = JSON.serialize(acc);
                String currencyT = JSON.serialize(ct);
                String oppLocList = picklistValues('Opportunity','default_Location__c');
                String oppStageList = picklistValues('Opportunity','StageName');
                String accPricingPExist = accPricingP.size() > 0 ? 'True' : 'False';
                String deliveryAddress = JSON.serialize(deladdr);
                String userList = JSON.serialize(salesUsersList());
                String oppTypeList = picklistValues('Opportunity','Type');
                String oppOrderSource = picklistValues('Opportunity','Order_Source__c');
                List<String> accDetailsWithCurrency = new List<String>();
                accDetailsWithCurrency.add(accountD);
                accDetailsWithCurrency.add(currencyT);
                accDetailsWithCurrency.add(oppLocList);
                accDetailsWithCurrency.add(oppStageList);
                accDetailsWithCurrency.add(accPricingPExist);
                accDetailsWithCurrency.add(deliveryAddress);
                accDetailsWithCurrency.add(userList);
                accDetailsWithCurrency.add(oppTypeList);
                accDetailsWithCurrency.add(oppOrderSource);
                return JSON.serialize(accDetailsWithCurrency);
            }
            catch(Exception e){
                return '{"error":"'+e.getMessage()+'"}';
            } 
        }
        else if(type == 'supplier'){
            String accObj = 'SELECT Id,Name,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Pop_up_Alert__c, Owner.Name, CurrencyIsoCode, Sea_Freight_Lead_Time__c, Air_Freight_Lead_Time__c, Need_Order_Number__c FROM Account WHERE Id =:accId';
            //String accPricingPolicy = 'SELECT Id FROM Pricing_Policy_with_Customer__c WHERE Customers__c =: accId';
            try{
                Account acc = Database.query(accObj);
                //List<Pricing_Policy_with_Customer__c> accPricingP = Database.query(accPricingPolicy);
                String CurrencyIsoCode = acc.CurrencyIsoCode;
                String currencyInfo = 'SELECT ConversionRate FROM CurrencyType WHERE IsoCode =:CurrencyIsoCode AND IsActive = true';
                CurrencyType ct = Database.query(currencyInfo);
                String accountD = JSON.serialize(acc);
                String currencyT = JSON.serialize(ct);
                String oppLocList = picklistValues('Opportunity','default_Location__c');
                String oppStageList = picklistValues('Opportunity','StageName');
                String oppLeadTimeList = picklistValues('Opportunity','Lead_Time__c');
                String userList = JSON.serialize(salesUsersList());
                //String accPricingPExist = accPricingP.size() > 0 ? 'True' : 'False';              
                    
                List<String> accDetailsWithCurrency = new List<String>();
                accDetailsWithCurrency.add(accountD);
                accDetailsWithCurrency.add(currencyT);
                accDetailsWithCurrency.add(oppLocList);
                accDetailsWithCurrency.add(oppStageList);
                //accDetailsWithCurrency.add(accPricingPExist);
                accDetailsWithCurrency.add(oppLeadTimeList);
                accDetailsWithCurrency.add(userList);
                
                return JSON.serialize(accDetailsWithCurrency);
            }
            catch(Exception e){
                return '{"error":"'+e.getMessage()+'"}';
            } 
        }
        else{
            return '{"error": "An error occurred"}';
        }
              
    }

    public static List<PickListEntries> salesUsersList(){
        
        List<PickListEntries> options = new List<PickListEntries>();
        String[] userL = Label.Sales_Users.split(',');
        List<User> salesUsersList = [SELECT Id,Name,Profile.Name FROM User WHERE Profile.Name IN : userL AND Name NOT IN ('Integration User') AND IsActive = true];
        
        for(User u : salesUsersList){
            options.add(new PickListEntries(u.Id,u.Name));
        }
        return options;
    }
    
    // Search contacts for Customer with Customer/Retail RecordType
    @AuraEnabled
    public static String searchContacts(String accId,String cntName){
        String cntObj = 'SELECT Id,Name,Email FROM Contact WHERE AccountId =:accId AND Name LIKE \'%' + String.escapeSingleQuotes(cntName) + '%\'';
        try{
            List<Contact> cnt = Database.query(cntObj);
            return JSON.serialize(cnt);
        }
        catch(Exception e){
            return '{"error":"'+e.getMessage()+'"}';
        }
    }
    
    public static String picklistValues(String objectName,String fieldName){
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectResults = sobjType.getDescribe();
        Map<String,Schema.SObjectField> objectFields = objectResults.fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectFields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<PickListEntries> options = new List<PickListEntries>();
        for( Schema.PicklistEntry f : ple){
            if(f.isActive() == true){
                options.add(new PickListEntries(f.getValue(),f.getLabel()));               
            }
        }     
        return JSON.serialize(options);
    }
    
    public class PickListEntries{
        public String value;
        public String label;
        
        public PickListEntries(String value,String label){
            this.value = value;
            this.label = label;
        }
    }
}