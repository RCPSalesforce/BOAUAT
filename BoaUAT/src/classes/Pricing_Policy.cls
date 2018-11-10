global class Pricing_Policy {

     @InvocableMethod
    public static void PricingPolicy(List<Id> PolicyId){
        
        List<Account> accList = [select Id from Account WHERE RecordTypeId = '0120l000000BSDUAA4'];
        List<Pricing_Policy_with_Customer__c> ppcList = new List<Pricing_Policy_with_Customer__c>();
        for(Account acc : accList){ // for each account in accLis
        	
            Pricing_Policy_with_Customer__c ppc = new Pricing_Policy_with_Customer__c();
            ppc.Name = 'Special Off';
            ppc.Customers__c = acc.Id;
            ppc.Pricing_Policy__c = PolicyId[0];
            ppcList.add(ppc);
            //insert ppc;
    	}
        
        insert ppcList;
        
}
}