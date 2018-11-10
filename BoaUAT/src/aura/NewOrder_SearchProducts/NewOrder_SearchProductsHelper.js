({
    searchProductHelper: function(component, event) {
        var searchResults = component.find("searchResults"); 
        $A.util.removeClass(searchResults,"displaySearchResults");
        var action = component.get("c.productData");
        action.setParams({
            "searchString": component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            //component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {              
                component.set("v.productList",response.getReturnValue());
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