trigger DeletePricingPolicy on Pricing_Policy_with_Customer__c (before delete) {
    
    List<Id> ppcIds = new List<Id>();
    for(Pricing_Policy_with_Customer__c ppc : trigger.old){
        ppcIds.add(ppc.Id);           
    }
    //Outbound request to Web Portal
    Rest_WebPortalOutbondController.callOutPricingPolicyWithCustomerDelete(ppcIds);
    
    
}