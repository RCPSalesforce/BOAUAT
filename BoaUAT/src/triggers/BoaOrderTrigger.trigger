trigger BoaOrderTrigger on Opportunity (before insert, before update, after insert, after update) {

     TriggerDispatcher.Run(new BoaOrderTriggerHandler());
}