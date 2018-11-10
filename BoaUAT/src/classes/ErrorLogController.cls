public class ErrorLogController {
    
    public static void createErrorLog(string errorId,string errorMessage,string methodName,integer errorLineNumber){
         error_log__c el = new error_log__c();
         el.Error_Id__c = errorId;
         el.Error_Message__c = errorMessage;
         el.method_Name__c = methodName;
         el.error_Line_Number__c = errorLineNumber;  
         insert el; 
        
    }
    
}