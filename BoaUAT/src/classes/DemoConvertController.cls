global class DemoConvertController {

    webService static String convertToPdf(Id docConfigId, Id objectId) {
    	/**/
        System.debug('docConfig: ' + docConfigId);
        System.debug('objectId: ' + objectId);
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('recordId', objectId);
        cadmus.DocGenerationWrapper result;
        if(docConfigId != null) {
        	result = cadmus.DocumentDataHandler.generate(docConfigId, objectId, inputMap);
        } else {
            result = new cadmus.DocGenerationWrapper();
        }
        
        return result.attachmentId;
        //return null;
    }
    
	@AuraEnabled
    global static String convertToPdfLightning(Id docConfigId, Id objectId) {
        
        return convertToPdf(docConfigId, objectId);
        //return null;
    }
}