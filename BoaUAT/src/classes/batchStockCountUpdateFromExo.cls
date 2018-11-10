/*
 * Description : Batch class to fetch stock location and count info from EXO and update to SF.
 * History : 
 * Initial Version : 14Sept2018 RohitP
*/


public class batchStockCountUpdateFromExo implements database.Batchable<Rest_ExoWrappers.cls_stockCountInfo>,Database.AllowsCallouts,Database.Stateful {
	public map<integer,Id> LocationCodeToIdMap = new map<integer,Id>();
    
    public list<Rest_ExoWrappers.cls_stockCountInfo> start(Database.BatchableContext bc) {
        // get locations info and update to SF before starting stock count update process
        list<Stock_Location__c> locationList = new list<stock_Location__c>();
        list<Stock_Count_Per_Location__c> stockCountList = new list<Stock_Count_Per_Location__c>();
        list<Rest_ExoWrappers.cls_stockCountInfo> allStockCountList = new list<Rest_ExoWrappers.cls_stockCountInfo>();
        // do get call to EXo to fetch stock locations first
        //string accessToken = Rest_outboundCaller.loginToExo();
        string accessToken = '';
        Rest_ExoWrappers.genericOutboundResponseWrapper locationResponseWrapper = Rest_outboundCaller.getHttpRequestExo('/stockloc', accessToken);
      
        if(locationResponseWrapper.responseCode == 200){
            
            Rest_ExoWrappers.cls_stockLocationInfoWrapper locationInfo = (Rest_ExoWrappers.cls_stockLocationInfoWrapper) JSON.deserialize(locationResponseWrapper.responseBody,Rest_ExoWrappers.cls_stockLocationInfoWrapper.class);    
            list<Rest_ExoWrappers.cls_stockLocationInfo> locationInfoList = locationInfo.stockLocationData;   
            
            if(!locationInfoList.isEmpty()){
                for(Rest_ExoWrappers.cls_stockLocationInfo locationData : locationInfoList){
                    if(locationData.LOCNO != null && locationData.ISACTIVE == 'Y'){
                    	Stock_Location__c upsertLocation = new Stock_Location__c();
                    	upsertLocation.Location_Number_Exo__c = locationData.LOCNO;
                        upsertLocation.Location_Code__c = locationData.LCODE;
                        upsertLocation.Name = locationData.LNAME;
                        upsertLocation.Is_Active__c = locationData.ISACTIVE == 'Y'? true : false;
                        upsertLocation.Execlude_from_Valuation__c = locationData.EXCLUDE_FROMVALUATION == 'Y'? true : false;
                        upsertLocation.Exclude_from_free_stock__c = locationData.EXCLUDE_FROMFREE_STOCK == 'Y'? true : false;
                        upsertLocation.Exclude_from_sales__c = locationData.EXCLUDE_FROMSALES == 'Y'? true : false;
                        upsertLocation.Street_address__c = locationData.DELADDR1;
                        upsertLocation.Suburb__c = locationData.DELADDR2;
                        upsertLocation.City__c = locationData.DELADDR3;
                        upsertLocation.Country__c = locationData.DELADDR4;
                        upsertLocation.Postal_Code__c = locationData.DELADDR5;
                        upsertLocation.Is_WIP_Location__c = locationData.IS_WIPLOCATION == 'Y'? true : false;
                    	locationList.add(upsertLocation);    
                    }
                }
                
            }
        
        }
        
        //check if locationList is not empty to proceed
        if(!locationList.isEmpty()){
            try{
            	
            	//start processing for stock counts now by each location
                for(Stock_Location__c loc : locationList){
                    string locNo = string.valueOf(loc.Location_Number_Exo__c);
                    if(string.isNotBlank(locNo) && loc.Is_Active__c){
                        //call api for each location
                        //string token = Rest_outboundCaller.loginToExo();
                        string token='';
        				Rest_ExoWrappers.genericOutboundResponseWrapper stockCountResponse = Rest_outboundCaller.getHttpRequestExo('/stockinfo/'+integer.valueOf(loc.Location_Number_Exo__c),token);
                        if(stockCountResponse.responseCode == 200){
                            system.debug('Stock count JSON--'+stockCountResponse);
                        	Rest_ExoWrappers.stockCountInfoWrapper stockCountInfoList = (Rest_ExoWrappers.stockCountInfoWrapper) JSON.deserialize(stockCountResponse.responseBody,Rest_ExoWrappers.stockCountInfoWrapper.class);
                            // if stock count list received for given location is not Empty
                            if(!stockCountInfoList.stockinfoData.isEmpty()){
                				allStockCountList.addAll(stockCountInfoList.stockinfoData);              
                            }
                                
                        }
                        
                    }
                }
                
				//upsert latest location info to salesforce
                upsert locationList Location_Number_Exo__c; 
                //fill out location code to Id map
                for(Stock_Location__c loc : locationList){
                	LocationCodeToIdMap.put(integer.valueOf(loc.Location_Number_Exo__c),loc.Id);    
                }
                system.debug('LocationCodeToIdMap--'+LocationCodeToIdMap);
                        
            }catch(exception e){
                errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'batchStockCountUpdateFromExo.Start',e.getLineNumber());
            }
            
        }
        
        return allStockCountList;
    }
    
    public void execute(Database.BatchableContext bc, List<Rest_ExoWrappers.cls_stockCountInfo> scope){
        system.debug('stock count list size-- '+scope.size());
        system.debug('stock count List--'+scope);
        list<Stock_Count_Per_Location__c> updStockCountList = new list<Stock_Count_Per_Location__c>();
        set<string> stockCodes = new set<string>();
        map<string,id> stockCodeToIdMap = new map<string,id>();
        
        if(!scope.isEmpty()){
            //getting stockCodes set populated
            for(Rest_ExoWrappers.cls_stockCountInfo stckInfo : scope){
                if(string.isNotBlank(stckInfo.STOCKCODE)){
                    stockCodes.add(stckInfo.STOCKCODE);
                }
            }
            //getting stockCodeToIdMap populated
            for(product2 prd: [SELECT id,Name FROM Product2 WHERE Name IN: stockCodes] ){
            	 stockCodeToIdMap.put(prd.Name, prd.Id);   
            }
            
            //looping Scope list now to update stock count in SF.
            for(Rest_ExoWrappers.cls_stockCountInfo stckCountInfo : scope){
                if(stockCodeToIdMap.containsKey(stckCountInfo.STOCKCODE) && LocationCodeToIdMap.containsKey(stckCountInfo.LOCATION)){
                	Stock_Count_Per_Location__c updStockCount = new Stock_Count_Per_Location__c();
            		updStockCount.Stock_Item__c = stockCodeToIdMap.get(stckCountInfo.STOCKCODE);
                    updStockCount.Stock_Location__c = LocationCodeToIdMap.get(stckCountInfo.LOCATION);
                    updStockCount.Maximum_Stock__c = stckCountInfo.MAXSTOCK;
                    updStockCount.Minimum_Stock__c = stckCountInfo.MINSTOCK;
                    updStockCount.MYOB_code_in_EXO__c = stckCountInfo.Myob;
                    updStockCount.Physical_Quantity__c = stckCountInfo.QTY;
             		updStockCountList.add(updStockCount);       
                }
                
            }
            
        }
        
        //upsert stock count per location object in SF
        upsert updStockCountList MYOB_code_in_EXO__c;
         
    }
    
    public void finish(Database.BatchableContext bc){
         // do nothing   
          
    }    

    
}