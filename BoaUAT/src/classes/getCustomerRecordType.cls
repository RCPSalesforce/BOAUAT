public class getCustomerRecordType {
    
    @AuraEnabled
    public static string getRecordType(String accountId){
        Account acc = [SELECT Id, recordTypeId FROM Account WHERE Id =: accountId];
        return acc.recordTypeId;
    }

}