trigger ContactTrigger on Contact (before insert, before update,after insert, after update) {
	TriggerDispatcher.Run(new ContactTriggerHandler());
}