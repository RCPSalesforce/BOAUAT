({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log(recordId);
        var action = component.get("c.getRecordType");
        action.setParams({
            "opportunityId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            if(data=='0120l000000CH3ZAAW'){
                component.set("v.showsalesorder",true);
            }
            else if(data=='0120l000000CH3eAAG'){
                component.set("v.showpurchaseorder",true);
            }
            console.log(data);
        });
        $A.enqueueAction(action);
    }
})