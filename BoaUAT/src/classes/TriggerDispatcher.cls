public class TriggerDispatcher {
    
    public static void Run(ITriggerHandler handler){
 
        // Before trigger logic
        if (Trigger.IsBefore){
            system.debug('in before');
            if (Trigger.IsInsert){
                handler.BeforeInsert(trigger.new);   
            }
            
            if (Trigger.IsUpdate){
                system.debug('in update dipatcher');
                handler.BeforeUpdate(trigger.newMap, trigger.oldMap);   
            }
            
            if (Trigger.IsDelete){
                handler.BeforeDelete(trigger.oldMap);   
            }
            
        }
         
        // After trigger logic
        if (Trigger.IsAfter){
            
            if (Trigger.IsInsert){
             	handler.AfterInsert(Trigger.newMap);   
            }
 
            if (Trigger.IsUpdate){
             	handler.AfterUpdate(trigger.newMap, trigger.oldMap);   
            }
 
            if (trigger.IsDelete){
             	handler.AfterDelete(trigger.oldMap);   
            }
 
            if (trigger.isUndelete){
             	handler.AfterUndelete(trigger.oldMap);   
            }
            
        }
        
    }
    
}