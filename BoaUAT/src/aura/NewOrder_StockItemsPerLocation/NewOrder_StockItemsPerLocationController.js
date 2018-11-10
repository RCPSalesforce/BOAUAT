({
    closeModal : function(component) {
		$A.util.toggleClass(component.find("stockLocationModal"),"slds-hide");
	},
    handleProductQtyDetails : function(component, event, helper) {
        helper.prodQtyDetails(component, event);
    }
})