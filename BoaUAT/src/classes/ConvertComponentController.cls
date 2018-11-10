global class ConvertComponentController {

	@AuraEnabled
    global static String initServer(String docConfigIds) {
        
        System.debug('docConfigIds: ' + docConfigIds);
        InitData data = new InitData();
        if( !String.isEmpty(docConfigIds) ) {
            List<String> ids = docConfigIds.split(',');        
            data.docConfigs = [SELECT Id, Name FROM cadmus__Doc_Config__c WHERE Id IN :ids];
            
            //get User info
            Id userId = UserInfo.getUserId();
            data.currentUser = [SELECT IsActive,Profile.Name FROM User WHERE Id = :userId];
        } else {
            data.docConfigs = new List<cadmus__Doc_Config__c>();
        }
        
        return JSON.serialize(data);
    }
    
    global class InitData {
        global List<cadmus__Doc_Config__c> docConfigs {get;set;}
        global User currentUser {get;set;}
    }
    
	@AuraEnabled
    global static String convert(Id docConfigId, Id objectId, String locale, String alternative, String targetType) {
        
        cadmus.ConvertController.ConvertDataModel cdm = new cadmus.ConvertController.ConvertDataModel();
        cdm.docConfigId = docConfigId;
        cdm.objectId = objectId;
        cdm.targetType = targetType;
        cdm.alternativeName = alternative;
        cdm.locale = locale;
        cdm.country = null;
        cdm.language = null;
        
        try {
            cadmus.DocGenerationWrapper result = cadmus.ConvertController.convertWithWrapper(cdm);
            JSONGenerator jgen = JSON.createGenerator(true);
    		jgen.writeStartObject();
            jgen.writeStringField('title', result.response.metadata.targetName);
            jgen.writeStringField('base64', EncodingUtil.base64Encode(result.response.base64));
            jgen.writeFieldName('issues');
            jgen.writeStartArray();
            for(cadmus.CadmusHttpResponse.Issue issue : result.response.issues) {
                jgen.writeStartObject();
            	jgen.writeStringField('level', issue.level);
            	jgen.writeStringField('description', issue.description);
                jgen.writeEndObject();
            }
            jgen.writeEndArray();
            jgen.writeEndObject();
            //return the PDF base64 to diplay
            return jgen.getAsString();
            //return '{"title":"' + result.response.metadata.targetName +'","base64":"' + EncodingUtil.base64Encode(result.response.base64) + '","issues":"' + JSON.serialize(result.response.issues) + '"}';
        } catch(Exception ex) {
            JSONGenerator jgen = JSON.createGenerator(true);
    		jgen.writeStartObject();
            jgen.writeFieldName('issues');
            jgen.writeStartArray();
                jgen.writeStartObject();
            	jgen.writeStringField('level', 'ERROR');
            	jgen.writeStringField('description', ex.getMessage());
                jgen.writeEndObject();
            jgen.writeEndArray();
            jgen.writeEndObject();
            return jgen.getAsString();
        }
    }
}