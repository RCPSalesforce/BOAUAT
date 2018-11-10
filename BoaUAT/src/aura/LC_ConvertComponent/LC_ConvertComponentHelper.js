({
	convert : function(targetType, component, event) {
		
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        var action = component.get("c.convert");
        
    	var selectedItem = event.currentTarget;
        var docConfigId = selectedItem.dataset.record;
        var recordId = component.get("v.recordId");
        var locale = component.get("v.locale");
        var alternative = component.get("v.alternative");
        
        action.setParams({"docConfigId": docConfigId, "objectId":recordId, "locale":locale,"alternative":alternative,"targetType":targetType});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                //alert(response.getReturnValue());
                if(response.getReturnValue()) {
                    var docConfigData = JSON.parse(response.getReturnValue());
                    
                    if(docConfigData.base64) {
                        var dlnk = document.getElementById('fileDownload');
                        dlnk.href = "data:application/octet-stream;base64," + docConfigData.base64;  // Adds the pdf to the html anchor
                        dlnk.download = docConfigData.title; //  Sets the title (filename) of the document to download
                        dlnk.click();  //  initiates the download automatically when the document is generated, no user has to click 
                    }
                    for (var i = 0; i < docConfigData.issues.length; i++) {
                        var issue = docConfigData.issues[i];
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": issue.level,
                            "message": issue.description,
                            "type": issue.level.toLowerCase()
                        });
                        toastEvent.fire();
                    }
                }
            } else {
                console.log('There was a problem and the state is: '+state);
            }            
        	$A.util.toggleClass(spinner, "slds-hide");
        });
        
        $A.enqueueAction(action);
	}
})