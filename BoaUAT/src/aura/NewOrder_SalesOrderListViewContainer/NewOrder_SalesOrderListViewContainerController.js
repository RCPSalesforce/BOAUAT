({
	navigateToSalesOrderComponent : function(component, event, helper) {
        component.find("navService").navigate({
            type: "standard__component",
            attributes: {
                componentName: "c__NewOrder_Home" 
            },
            state: { "c__accountId": null } 
        }, true); 		
	}
})