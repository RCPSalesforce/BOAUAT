({
    searchProducts: function(component, event, helper) {
        if(component.get("v.searchKeyword").length > 0){
            helper.searchProductHelper(component);
        }
        else{
            var searchResults = component.find("searchResults"); 
            $A.util.addClass(searchResults,"displaySearchResults");
        }        
    },
    selectedProd: function(component, event, helper) {
        var searchResults = component.find("searchResults"); 
        var selectedItem = event.currentTarget;
        if(selectedItem.dataset.record){
            component.find("searchField").set("v.value",selectedItem.title);
            $A.util.addClass(searchResults,"displaySearchResults");          
        }
    },
    removeSelectedItem: function(component, event, helper) {
        component.find("searchField").set("v.value","");        
    }
})