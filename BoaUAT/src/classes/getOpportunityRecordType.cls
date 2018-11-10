public class getOpportunityRecordType {
 @AuraEnabled
    public static string getRecordType(String opportunityId){
        Opportunity opp = [SELECT Id, recordTypeId FROM Opportunity WHERE Id =: opportunityId];
        return opp.recordTypeId;
    }

}