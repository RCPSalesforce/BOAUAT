trigger AccountTrigger on Account (before insert, before update,after insert, after update) {

       
    TriggerDispatcher.Run(new AccountTriggerHandler());
    
    
}