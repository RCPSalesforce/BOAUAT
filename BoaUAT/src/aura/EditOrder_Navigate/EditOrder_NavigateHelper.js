({
    handleEditOrderNav : function(component,event) {
        var recId = component.get("v.recordId");
        var accId = component.get("v.simpleRecord.AccountId");
        var recordTypeName = component.get("v.simpleRecord.RecordType.Name");
        var cmpName = recordTypeName == 'Sales order' ? 'c__NewOrder_Home' : 'c__NewOrder_PurchaseOrderHome';
        component.find("navService").navigate({
            type: "standard__component",
            attributes: {
                componentName: cmpName 
            },
            state: { "c__accountId": accId,"c__oppId": recId } 
        }, true);       
    }
    
})