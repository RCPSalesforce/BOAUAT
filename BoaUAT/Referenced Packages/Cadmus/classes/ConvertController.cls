/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ConvertController {
    global ConvertController() {

    }
    webService static String convert(cadmus.ConvertController.ConvertDataModel data) {
        return null;
    }
    @AuraEnabled
    global static String convertAura(cadmus.ConvertController.ConvertDataModel data) {
        return null;
    }
    webService static String convertToDocx(Id docConfigId, Id objectId) {
        return null;
    }
    @AuraEnabled
    global static String convertToDocxAura(Id docConfigId, Id objectId) {
        return null;
    }
    webService static String convertToPdf(Id docConfigId, Id objectId) {
        return null;
    }
    @AuraEnabled
    global static String convertToPdfAura(Id docConfigId, Id objectId) {
        return null;
    }
    webService static cadmus.DocGenerationWrapper convertWithWrapper(cadmus.ConvertController.ConvertDataModel data) {
        return null;
    }
global class ConvertDataModel {
    webService String alternativeName {
        get;
        set;
    }
    webService String country {
        get;
        set;
    }
    webService Id docConfigId {
        get;
        set;
    }
    webService String language {
        get;
        set;
    }
    webService String locale {
        get;
        set;
    }
    webService Id objectId {
        get;
        set;
    }
    webService String targetType {
        get;
        set;
    }
    global ConvertDataModel() {

    }
}
}
