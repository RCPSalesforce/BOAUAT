({
    //Call the convertor
	init : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        var action = component.get("c.convertToPdfLightning");
        //alert(component.get("v.recordId"));
        action.setParams({"objectId": component.get("v.recordId"), "docConfigId": "a040Y000004e5It"});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                //alert(response.getReturnValue());
                component.set("v.documentId", response.getReturnValue());
            } else {
                console.log('There was a problem and the state is: '+state);
            }
        	$A.util.toggleClass(spinner, "slds-hide");
            $A.get('e.force:refreshView').fire();
        });
        
        $A.enqueueAction(action);
	}
})