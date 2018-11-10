({    
    invoke : function(component, event, helper) {
        var record = component.get("v.recordId");
        window.location.href = '/lightning/r/Opportunity/' + record + '/view';
    }
})