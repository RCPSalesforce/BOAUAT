trigger LeadCount on Lead (before insert) {

    List<String> lstEmail = new List<String>();
    
        for(lead le:trigger.new)
        {
            lstEmail.add(le.Email);
         }
    
        List<lead> lstLead=[select id from lead where email IN :lstEmail];
         
        for(lead le1:trigger.new)
        {
        if(lstLead.size() > 0)
        {
            le1.Number_of_Times_Lead_Visited__c= le1.Number_of_Times_Lead_Visited__c + 1;
        }

    }
}