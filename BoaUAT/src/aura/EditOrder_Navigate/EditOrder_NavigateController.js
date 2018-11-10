({
    editOrderNav : function(component, event, helper) { 
 		helper.handleEditOrderNav(component, event);
    },
    handleRecordUpdated: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var location = window.location.href;
        if(location.indexOf('/lightning/r/Opportunity/' + recordId + '/edit') >= 0){
            helper.handleEditOrderNav(component, event);
        }        
        
    }
})