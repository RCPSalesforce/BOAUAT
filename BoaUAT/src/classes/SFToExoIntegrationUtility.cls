/*
* Description - Class handles methods for generic SF to EXO integration functionality.
* Author - Centelon Team 
*/

public class SFToExoIntegrationUtility {
//method to assign Exo staff code for various objects like account, contact etc..    
    @InvocableMethod(label='Assign EXO staff code' description='assigns value to sales person code in Exo field, used for integration purpose')    
    public static void assignExoStaffCode(list<id> recordIds){
        try{ 
            string objName = recordIds[0].getSObjectType().getDescribe().getName();
            string ownerName;
            map<id,string> ownerNamesToRecordId = new map<id,string>();
            list<account> updateAccounts = new list<account>();
            list<contact> updateContacts = new list<contact>();
            
            if(objName.equalsIgnoreCase('Account')){
                list<account> accList = [select id,ownerId,owner.Name from account where id IN: recordIds];    
                for(account a: accList){
                    ownerNamesToRecordId.put(a.id, a.owner.name);
                }
            }
            
            if(!ownerNamesToRecordId.isEmpty()){ 
                map<string,sales_person__c> salesPersonMap = sales_person__c.getAll();
                for(id recordId: ownerNamesToRecordId.keyset()){
                    
                    sales_person__c salesPerson = salesPersonMap.get(ownerNamesToRecordId.get(recordId)); 
                    if(salesPerson ==  null){
                        salesPerson = salesPersonMap.get('Integration User');     
                    }
                    if(objName.equalsIgnoreCase('Account')){
                        account updAcc =  new account();
                        updAcc.Id = recordId;
                        updAcc.Sales_Person_Code_in_Exo__c = salesPerson.staff_number__c;
                        updateAccounts.add(updAcc);
                        
                    }
                    
                    if(objName.equalsIgnoreCase('Contact')){
                        contact updCon =  new contact();
                        updCon.Id = recordId;

                        
                    }
                    
                }
                        
                //update list of objects 
                if(!updateAccounts.isEmpty()) update updateAccounts;
                if(!updateContacts.isEmpty()) update updateContacts;
                
            }
            
        }  
        catch(Exception e)
        {
            System.debug(e);
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'SFToExoIntegrationUtility.assignExoStaffCode',e.getLineNumber());  
            
            
        }  
    }

    //method to get picklist label from picklist value
    public static string getPicklistLabel(string sObjName,string objField,string picklistApiValue){
        try{
        string picklistLabel;
        List<Schema.DescribeSObjectResult> describeResults = Schema.describeSObjects(new List<String>{sobjName});
        List<Schema.PicklistEntry> picklistEntries = describeResults[0].fields.getMap().get(objField).getDescribe().getPicklistValues();
        
        
        for(Schema.PicklistEntry ple :picklistEntries){
            if(ple.getValue() == picklistApiValue){
                picklistLabel =  ple.getLabel();
            }
            
        }        
        
        return picklistLabel;
        }catch(exception e){
            System.debug(e);
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'SFToExoIntegrationUtility.getPicklistLabel',e.getLineNumber());  
            return e.getMessage();
        }  
        
    }
    
}