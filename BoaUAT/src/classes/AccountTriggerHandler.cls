public class AccountTriggerHandler implements ITriggerHandler {

    public void BeforeInsert(List<SObject> newItems) {
		Set<Id> accountIds = new Set<Id>();
        for(SObject s: newItems){
            accountIds.add(s.Id);
        }
        List<Account> accountList = [SELECT Id,Name,Onboarding_status__c from Account WHERE Id IN:accountIds];
        for(Account a : accountList){
            if(a.Onboarding_status__c == 'Complete'){
                a.Is_New_Business__c = false;
            }
        }
        
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
		List<Account> newAccountList = newItems.values(); 
        List<Account> oldAccountList = oldItems.values();
        for(Account a : newAccountList){
            if(a.Onboarding_status__c == 'Complete'){
                a.Is_New_Business__c = false;
            }
        }
        
        Map<Id,Account> newAccountsMap = new Map<Id,Account>();
        Map<Id,Account> oldAccountsMap = new Map<Id,Account>();
        
        //List<Account> newAccountList = newItems.values(); 
        for(Account newAccount : newAccountList){
            newAccountsMap.put(newAccount.Id,newAccount);
        }
        
        //List<Account> oldAccountList = oldItems.values(); 
        for(Account oldAccount : oldAccountList){
            oldAccountsMap.put(oldAccount.Id,oldAccount);
        }
        
        AccountTriggerClass.calculateRemainingCreditBalance(newAccountsMap, oldAccountsMap);
        
        
    }

    public void BeforeDelete(Map<Id, SObject> oldItems) {
       
    }

    public void AfterInsert(Map<Id, SObject> newItems) {
        
    List<Account> newAccounts =  newItems.values();
    AccountTriggerClass.insertCustomerToPortalAndExo(newAccounts);
    
    }

    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Account> newAccountsMap = new Map<Id,Account>();
        Map<Id,Account> oldAccountsMap = new Map<Id,Account>();
        
        List<Account> newAccountList = newItems.values(); 
        for(Account newAccount : newAccountList){
            newAccountsMap.put(newAccount.Id,newAccount);
        }
        
        List<Account> oldAccountList = oldItems.values(); 
        for(Account oldAccount : oldAccountList){
            oldAccountsMap.put(oldAccount.Id,oldAccount);
        }
        system.debug('newAccountsMap: ' + newAccountsMap);
        system.debug('oldAccountsMap: ' + oldAccountsMap);
        
        //
        AccountTriggerClass.updateCustomerToPortalAndExo(newAccountsMap,oldAccountsMap);
        //AccountTriggerClass.calculateRemainingCreditBalance(newAccountsMap, oldAccountsMap);
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {
    }

    public void AfterUndelete(Map<Id, SObject> oldItems) {
    }
    
}