global class scheduleAccountInfoUpdateFromExo implements schedulable{
	
    global void execute(SchedulableContext sc){
        batchAccountInfoUpdateFromExo b = new batchAccountInfoUpdateFromExo();
        Database.executeBatch(b);
    }
}