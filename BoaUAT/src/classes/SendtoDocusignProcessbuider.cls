public class SendtoDocusignProcessbuider {
    @InvocableMethod
    public Static void SendtoDocuFuture(List<Id> CreditappId){
        System.debug('CreditappId ' + CreditappId);
        SendToDocuSignweb.SendNow(CreditappId[0]);
        //Credit_Application_Form__c c = new Credit_Application_Form__c(Id=CreditappId[0]);
        //c.ProcessRefrence__c = false;
        //update c;
        
        //System.debug('after future finish');
        
    }
    
    @future(callout=true)
        public Static void conPdfFuture(String CreditappId){
            SendToDocuSignweb.SendNow(CreditappId);
            Credit_Application_Form__c c = new Credit_Application_Form__c(Id=CreditappId);
            c.ProcessRefrence__c = false;
            update c;
        }
    }