({
    sendHelper: function(component, getEmail,getCc, getSubject, getbody, recId, selectedAttachments) {
        // call the server side controller method 	
        //alert('Helper Id -- '+recId+' -- flag -- '+attachFlag);
       
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'mMail': getEmail,
            'mCc': getCc,
            'mSubject': getSubject,
            'mbody': getbody,
            'recordId': recId,
            'selectedAttchIds': selectedAttachments
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var message = response.getReturnValue();
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                component.set("v.message",message);
                component.set("v.mailStatus", true);
            }
 
        });
        $A.enqueueAction(action);
    },
})