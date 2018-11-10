global class scheduleStockCountUpdateFromExo implements Schedulable {
	
    global void execute(SchedulableContext sc){
        batchStockCountUpdateFromExo b = new batchStockCountUpdateFromExo();
        Database.executeBatch(b);
    }
  
}