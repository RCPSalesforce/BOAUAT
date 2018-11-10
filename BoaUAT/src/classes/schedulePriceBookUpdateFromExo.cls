global class schedulePriceBookUpdateFromExo implements schedulable{
	
    global void execute(SchedulableContext sc){
        batchStockPricesUpdateToExo b = new batchStockPricesUpdateToExo();
        Database.executeBatch(b);
    }
}