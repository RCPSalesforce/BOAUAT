trigger operation_trigger on Account (Before Insert , Before Update) {
  
    List<Account> customObjList = new List<Account>();

    For(Account acc:Trigger.new)
    {
    if(Trigger.IsInsert) {
        // possibly add custom objects to update
        acc.Operation__c='I';
    }

    if(Trigger.IsUpdate) {
        // possibly add custom objects to update
        acc.Operation__c='U';
    }
    }
    update customObjList;
}