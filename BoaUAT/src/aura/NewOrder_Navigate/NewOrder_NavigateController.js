({
    doInit : function(component, event, helper) {
        var location = window.location.href;
        if(location.indexOf('/lightning/o/Opportunity/new') >= 0){
            var recordType = component.get("v.pageReference");
            if(recordType != null){
                var recordTypeId = recordType.state.recordTypeId;
                var boaSalesOrderRecordType = $A.get("$Label.c.BoaSalesOrderRecordType").length === 18 ? $A.get("$Label.c.BoaSalesOrderRecordType").slice(0,-3) : $A.get("$Label.c.BoaSalesOrderRecordType");
                var boaPurchaseOrderRecordType = $A.get("$Label.c.BoaPurchaseOrderRecordType").length === 18 ? $A.get("$Label.c.BoaPurchaseOrderRecordType").slice(0,-3) : $A.get("$Label.c.BoaPurchaseOrderRecordType");
                if(recordTypeId === boaSalesOrderRecordType){
                    window.location.href = "/lightning/cmp/c__NewOrder_Home?c__accountId";
                }
                if(recordTypeId === boaPurchaseOrderRecordType){
                    window.location.href = "/lightning/cmp/c__NewOrder_PurchaseOrderHome?c__accountId";
                }
            }                    
        }
    },
    newOrder : function(component, event, helper) {
        helper.navigateToOrder(component,event);       
    }
})