({
	init : function(component, event, helper) {
		
        console.log(component.get("v.recordId"));
        
        //var spinner = component.find("mySpinner");
        var action = component.get("c.initServer");
        //alert(component.get("v.recordId"));
        action.setParams({"docConfigIds": component.get("v.docConfigIds")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                //alert(response.getReturnValue());
                if(response.getReturnValue()) {
                    var json = JSON.parse(response.getReturnValue());
                    var docConfigs = json.docConfigs;
                    var currentUser = json.currentUser;
                    component.set("v.docConfigs", docConfigs);
                    component.set("v.currentUser", currentUser);
                    
                    //check to show DOCX button
                    var showDocxProfilesTemp = component.get("v.showDocxProfiles");
                    if( showDocxProfilesTemp !== undefined && showDocxProfilesTemp != "" ) {
                    	var showDocxProfiles = showDocxProfilesTemp.split(",");
                        if(showDocxProfiles.indexOf(currentUser.Profile.Name) > -1) {
                            component.set("v.showDocxButton", true);
                        } else {
                            component.set("v.showDocxButton", false);
                        }
                    } else {
                        component.set("v.showDocxButton", true);
                    }
                    var showPdfProfilesTemp = component.get("v.showPdfProfiles");
                    if( showPdfProfilesTemp !== undefined && showPdfProfilesTemp != "" ) {
                    	var showPdfProfiles = showPdfProfilesTemp.split(",");
                        if(showPdfProfiles.indexOf(currentUser.Profile.Name) > -1) {
                            component.set("v.showPdfButton", true);
                        } else {
                            component.set("v.showPdfButton", false);
                        }
                    } else {
                    	component.set("v.showPdfButton", true);
                    }
                }
            } else {
                console.log('There was a problem and the state is: '+state);
            }
        	//$A.util.toggleClass(spinner, "slds-hide");
        });
        
        $A.enqueueAction(action);
	},
	genPdf : function(component, event, helper) {
        console.log("genPdf");
        helper.convert("PDF", component, event);
    },
	genDocx : function(component, event, helper) {
        console.log("genDocx");
        helper.convert("DOCX", component, event);
    }
})