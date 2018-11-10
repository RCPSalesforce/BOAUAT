({
    handleChangedAccId: function(component, event, helper) {
        var accountId = component.get("v.accountId");
        if(accountId == '' || accountId == null){
            component.find("searchField").set("v.disabled",true);
            component.set("v.searchKeyword","");
            var removeButton = component.find("removeButton");
            $A.util.removeClass(removeButton,"clearSelection");
            component.set("v.contactList",[]);
        }
        else{
            component.find("searchField").set("v.disabled",false);
            var removeButton = component.find("removeButton");
            $A.util.addClass(removeButton,"clearSelection");
        }
    },
    searchContact: function(component, event, helper) {
        var accId = component.get("v.accountId");
        if(component.get("v.searchKeyword").length > 0 && accId != '' && accId != null){
            helper.contactSearchHelper(component);
        }
        else{
            var searchResults = component.find("searchResults"); 
            $A.util.addClass(searchResults,"displaySearchResults");
        }        
    },
    selectedContact: function(component, event, helper) {
        var searchResults = component.find("searchResults"); 
        var selectedItem = event.currentTarget;        
        if(selectedItem.dataset.record){
            component.find("searchField").set("v.value",selectedItem.title);
            component.set("v.selectedContactId",selectedItem.dataset.record);
            console.log('selectedContactEmail ' + component.get("v.selectedContactId"));
            $A.util.addClass(searchResults,"displaySearchResults");          
        }
    },
    removeSelectedItem: function(component, event, helper) {
        component.find("searchField").set("v.value","");  
        component.set("v.contactList",[]);
    }
})