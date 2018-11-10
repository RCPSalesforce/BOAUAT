/*
 * Description : Batch class to fetch account turnover and balance info from EXO and update to SF.
 * 				 This works for both Debtor and Creditor type of accounts.	
 * History : 
 * Initial Version : 14Sept2018 RohitP
*/

public class batchAccountInfoUpdateFromExo implements database.Batchable<sObject>,Database.AllowsCallouts {
	
    public list<account> start(Database.BatchableContext bc) {
        list<account> updateAccountList = new list<account>();
        // do get call to EXo to fetch debtor account balance info
        //string accessToken = Rest_outboundCaller.loginToExo();
        string accessToken = '';
        Rest_ExoWrappers.genericOutboundResponseWrapper debtresponseWrapper = Rest_outboundCaller.getHttpRequestExo('/account', accessToken);
        // do get call to EXo to fetch creditor account balance info
        //string crdAccessToken = Rest_outboundCaller.loginToExo();
        string crdAccessToken = '';
        Rest_ExoWrappers.genericOutboundResponseWrapper crdResponseWrapper = Rest_outboundCaller.getHttpRequestExo('/cr_account', crdAccessToken);
        
        if(debtresponseWrapper.responseCode == 200 && crdResponseWrapper.responseCode == 200){
            Rest_ExoWrappers.getAccountWrapper debtorResponseObj = (Rest_ExoWrappers.getAccountWrapper) JSON.deserialize(debtresponseWrapper.responseBody, Rest_ExoWrappers.getAccountWrapper.class);    
            Rest_ExoWrappers.getCreditorWrapper creditorResponseObj = (Rest_ExoWrappers.getCreditorWrapper) JSON.deserialize(crdResponseWrapper.responseBody, Rest_ExoWrappers.getCreditorWrapper.class);    
            //merging creditor account info to debtor list for single processing
             debtorResponseObj.accountData.addAll(creditorResponseObj.cr_accountData);
                        
            if(!debtorResponseObj.accountData.isEmpty()){
                for(Rest_ExoWrappers.cls_accountData accountData: debtorResponseObj.accountData){
                    if(string.isNotBlank(accountData.SalesforceID)){                        
                    	account updAcc = new account();
                    	//updAcc.Id = accountData.SalesforceID;
                    	updAcc.AccountNumber__c = integer.valueof(accountData.ACCNO);
                    	updAcc.Aged_Balance0__c = accountData.AGEDBAL0;
                    	updAcc.Aged_Balance1__c = accountData.AGEDBAL1;
                    	updAcc.Aged_Balance2__c = accountData.AGEDBAL2;
                    	updAcc.Aged_Balance3__c = accountData.AGEDBAL3;
                    	updAcc.Balance__c = accountData.BALANCE;
                    	updAcc.Last_Month_turnover__c = accountData.LASTMONTH;
                    	updAcc.Last_year_turnover__c = accountData.LASTYEAR;
                    	updAcc.This_Month_TurnOver__c = accountData.MONTHVAL;
                    	updAcc.This_year_Turnover__c = accountData.YEARVAL;
                		updateAccountList.add(updAcc);    
                    }
                }
                
            }
        
        }
        
        return updateAccountList;
    }
    
    public void execute(Database.BatchableContext bc, List<account> scope){
        system.debug('account list size-- '+scope.size());
        system.debug('accountList--'+scope);
        set<integer> accNumbers = new set<integer>();
        map<integer,id> existingCustomersMap = new map<Integer,id>();
        //actual list of customers to be updated
        list<account> updateCustomers = new list<account>();
        
        if(!scope.isEmpty()){
            for(account acc: scope){
                accNumbers.add(integer.valueOf(acc.AccountNumber__c));
            }
            
          	// populating existing customers map from SF
            for(account existingCustomers : [SELECT Id,AccountNumber__c FROM Account 
                                             WHERE AccountNumber__c IN:accNumbers and IsActive__c = true]){
                                                 
            	existingCustomersMap.put(integer.valueOf(existingCustomers.AccountNumber__c),existingCustomers.Id);               
            }
            
            
            //populate account list to update
            for(account acc: scope){
                if(existingCustomersMap.containskey(integer.valueOf(acc.AccountNumber__c))){
                    acc.Id = existingCustomersMap.get(integer.valueOf(acc.AccountNumber__c));
                    if(updateCustomers.contains(acc)!= null) {
                    	updateCustomers.add(acc);
                    } else {
                        system.debug('Duplicate: '+acc.id);
                    }
                }
            }
            
            if(!updateCustomers.isEmpty()){
            	system.debug('updateCustomers--'+updateCustomers);
                update updateCustomers;    
            }
            
        }    
         
    }
    
    public void finish(Database.BatchableContext bc){
         // do nothing   
          
    }    

    
    
}