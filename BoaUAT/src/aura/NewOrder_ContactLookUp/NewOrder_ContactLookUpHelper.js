({
    contactSearchHelper: function(component, event) {
        var searchResults = component.find("searchResults"); 
        $A.util.removeClass(searchResults,"displaySearchResults");
        console.log('accId' + component.get("v.accountId"));
        console.log('searchKeyword' + component.get("v.searchKeyword"));
        var action = component.get("c.searchContacts");
        action.setParams({
            "accId" : component.get("v.accountId"),
            "cntName": component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {              
                component.set("v.contactList",JSON.parse(response.getReturnValue()));
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } 
                    else {
                    }
                }
        });
        $A.enqueueAction(action);
    }
})