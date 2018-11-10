@isTest
public class SFToExoIntegrationUtilityTest{
    static testMethod void testSFTOEXOIntegrationUtility(){
        
        list<id> recordIds= new list<id>();           
        Account testAccount = new Account();
        testAccount.Name='Account' ;
        testAccount.Region__c='CHINA';
        testAccount.Base_Price__c='Retail';
        testAccount.Customer_Class__c='AA(A Active)';
        testAccount.Email__c='krutika@centelon.com';
        upsert testAccount;
       // update testAccount; 
        Contact cont = new Contact();
        cont.LastName='Test';
         //cont.Accountid= testAccount.id;
        upsert cont;
       //update cont;
        recordIds.add(testAccount.id);
        recordIds.add(cont.AccountId);

        // recordIds.add('asdc','test','opl'); 
       // Account Acc = [select id,name from Account where Id='0010l00000QJwpd'];
       // Acc.Name='CA';
 // A
       // update Acc;
         //update = recordIds;
        // if(!updateAccounts.isEmpty()) update updateAccounts;
             //   if(!updateContacts.isEmpty()) update updateContacts;
                
        SFToExoIntegrationUtility.assignExoStaffCode(recordIds);
      
    }
    static testMethod void testSFTOEXOIntegrationUtility2(){
     
   list<id> recIds= new list<id>();
        Account acc = new Account();
            acc.Name = 'testaccount';
            acc.Region__c='CHINA';
        acc.Base_Price__c='Retail';
        acc.Customer_Class__c='AA(A Active)';
        acc.Email__c='krutika@centelon.com';
                 insert acc;      
           map<id,string> ownerNamesToRecordId = new map<id,string>();
        
        map<string,sales_person__c> salesPersonMap = sales_person__c.getAll();
        
                for(id recordId: ownerNamesToRecordId.keyset()){
                    
                    sales_person__c salesPerson = salesPersonMap.get(ownerNamesToRecordId.get(recordId)); 
                    if(salesPerson ==  null){
                        salesPerson = salesPersonMap.get('Integration User');     
                    }     
                        
        Contact con = new Contact();
            //AccountId = acc.id;
             acc.Id=con.AccountId;
            con.LastName = 'testcontact';
            con.Sales_Person_Code_in_Exo__c= salesPerson.staff_number__c;
       
            
            //,RecordTypeId = contExhibitorRT.Id //Set this contact to the exhibitor record type
        
        insert con;

        acc.Region__c = 'Aukland';      
        Test.startTest();
        update acc;
        Test.stopTest();
        

        //Requery the contact record and check to make sure it was updated.
        Contact result = [Select Lastname,Department,MailingAddress From Contact ];
        //System.assertEquals(con.FirstName,result.Lastname);
         SFToExoIntegrationUtility.assignExoStaffCode(recIds);
    
}
    }
}