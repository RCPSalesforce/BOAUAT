public with sharing class FlowRedirectController  {
    public Object FlowRedirectController() {
     
        String unique_id = '0060l000004TF0WAAW';
if(unique_id == null){
    String url = '/lightning/page/home';
    return new PageReference(url); 
} 
        
    String OpportunityId =  [SELECT Id  FROM Opportunity ORDER BY CreatedDate DESC LIMIT 1].Id;
      
    
        if (OpportunityId == null) {
            String url = '/lightning/page/home'; 
            return new PageReference(url); 
        }
        
         String url = '/' + OpportunityId; 
        return new PageReference(url); 

    }
	

}