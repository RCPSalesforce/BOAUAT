trigger DemoLeadEmailDup on Lead (before insert) {
    Map <String,Lead> leadMap = new Map<String,Lead>();
    List<Lead> leadList = new List<Lead>();
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        for(lead leadVar : Trigger.new){
            if(!leadMap.containsKey(leadVar.Email))
            {
                leadMap.put(leadVar.Email, leadVar);

        system.debug('leadvar' +leadvar.Email);
            }
        }

        if(leadMap != Null && leadMap.size() > 0)
        {
            leadList = [Select Id,FirstName,LastName,Email,Phone,Company,Industry,Number_of_Times_Lead_Visited__c From Lead where email IN: leadMap.keySet() ];
            
        }
        system.debug('leadlist ' +leadlist);
        system.debug('leadlist ' +leadlist.size());

     /*    if(leadList != Null && leadList.size() > 0)
        {
            for(Lead leadVar1 : leadList)
            {
                if(leadMap.containsKey(leadVar1.email))                                                                        
                {
                        leadMap.get(leadVar1.email).Number_of_Times_Lead_Visited__c = leadMap.get(leadVar1.email).Number_of_Times_Lead_Visited__c + 300;
                }
            }
        }  */
        
        if(leadList != Null && leadList.size() > 0)
        {
            for(Lead leadVar1 : leadList)
            {
                if(leadMap.containsKey(leadVar1.email))                                                                        
                {
                    //for First Name             
                    leadMap.get(leadVar1.email).FirstName = leadMap.get(leadVar1.email).FirstName != Null ? leadMap.get(leadVar1.email).FirstName : leadVar1.FirstName;
                    //for Last Name             
                    leadMap.get(leadVar1.email).LastName = leadMap.get(leadVar1.email).LastName != Null ? leadMap.get(leadVar1.email).LastName : leadVar1.LastName;
                    //for Phone
                    leadMap.get(leadVar1.email).Phone = leadMap.get(leadVar1.email).Phone != Null ? leadMap.get(leadVar1.email).Phone : leadVar1.Phone;
                    //for Industry 
                    leadMap.get(leadVar1.email).Industry = leadMap.get(leadVar1.email).Industry  != Null ? leadMap.get(leadVar1.email).Industry  : leadVar1.Industry ;
                    //for Company
                    leadMap.get(leadVar1.email).Company = leadMap.get(leadVar1.email).Company != Null ? leadMap.get(leadVar1.email).Company : leadVar1.Company;
                    //for Count
                    //leadMap.get(leadVar1.email).Number_of_Times_Lead_Visited__c  = leadVar1.Number_of_Times_Lead_Visited__c + 1;
                    //Except email field
                         
                    
                    system.debug('visit ' +leadvar1.Number_of_Times_Lead_Visited__c);
                     system.debug('visit ' +leadvar1.Industry);
                     system.debug('leadvar1' +leadVar1);
                }
             }

            delete leadList;
        }
        
    }
    

    
}