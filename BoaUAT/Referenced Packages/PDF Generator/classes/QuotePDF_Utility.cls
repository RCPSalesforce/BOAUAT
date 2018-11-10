/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class QuotePDF_Utility implements Database.AllowsCallouts, System.Queueable {
    global static Boolean isTriggerRunning {
        get;
        set;
    }
    global QuotePDF_Utility(Map<String,String> sObj_rule_id, Map<Id,String> sObj_id_name) {

    }
    global static void copyRecipient(String sObjName, List<SObject> sObjRecords) {

    }
    @Deprecated
    @Future(callout=true)
    global static void createPDFAndEmail(Map<String,String> sObj_rule_id, Map<Id,String> sObj_id_name) {

    }
    global static void createPDFAndEmail(String sObjName, List<SObject> sObjRecords) {

    }
    @Deprecated
    @Future(callout=true)
    global static void createPDF(Map<String,String> sObj_template_id) {

    }
    @Future(callout=true)
    global static void createPDF(String attachmentName, String sObjId, String pdfTemplateId, Set<String> recipientIds) {

    }
    global void execute(System.QueueableContext context) {

    }
    global static Schema.DescribeFieldResult getNameField(Schema.SObjectType sobjectType) {
        return null;
    }
}
