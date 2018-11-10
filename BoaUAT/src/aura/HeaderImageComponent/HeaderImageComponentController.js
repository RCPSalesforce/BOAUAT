({
	doInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        console.log(recordId);
        var action = component.get("c.getRecordType");
        action.setParams({
            "accountId": component.get("v.recordId")
        });
        // Register the callback function
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data == '0120l000000BSDUAA4'){
            	component.set("v.showEnterpriseCustomer",true);    
            }
            else if(data == '0120l000000BSDZAA4'){
            	component.set("v.showSupplierCustomer",true);     
            }
            else if(data == '0120l000000C6GfAAK'){
            	component.set("v.showRetailCustomer",true);     
            }
            console.log(data);            
        });
        // Invoke the service
        $A.enqueueAction(action);
	}
})