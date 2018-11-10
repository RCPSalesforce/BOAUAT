({
    doInit:function(component, event, helper) {
     //component.set("v.IsSpinner",false);
	},
    genpdf : function(component, event, helper) {
    	component.set("v.IsSpinner",true);
        var buttonClicked = event.getSource(); //the button
        var buttonLabel = buttonClicked.get("v.label"); //the button's label; 
        var action = component.get("c.Oppcon");
        action.setParams(
            {
                "DocId":component.get("v.recordId")
            }
        );	        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.IsSpinner",false);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success",
                    "message": "file",
                    "type":"success"
                });
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
                //alert("From server: " + response.getReturnValue());                               
            }
            
            else if (state === "INCOMPLETE") {
                System.debug("Error");
            }
            
            
            
        });
        $A.enqueueAction(action);
    }
})