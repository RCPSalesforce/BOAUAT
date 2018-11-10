({
    getOrderProd: function (component) {
        var accId = component.get("v.pageReference").state.c__accountId;
        var oppId = component.get("v.pageReference").state.c__oppId;
        var action = component.get("c.salesOrderEdit");
        action.setParams({
            "oppId": oppId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var g = JSON.parse(response.getReturnValue());
                if (!g.error) {
                    if (g.length > 0) {
                        component.set("v.userProfileName", g[2]);
                        if (g[1].length === 0) {
                            component.set("v.selectedProducts", []);
                        }
                        else {
                            component.set("v.selectedProducts", g[1]);
                        }
                        
                        component.set("v.opportunityData", JSON.parse(g[0]));
                        component.set("v.accountId", accId);
                        component.set("v.showAccount", true);
                        component.set("v.showProduct", true);
                    }
                }
                else {
                    this.showErrorToast(component,g.error,'error');
                }
            }
            else if (state === "INCOMPLETE") {
                this.showErrorToast(component,'An error occurred.Please contact your Administrator','error');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.showErrorToast(component,errors[0].message,'error');
                        }
                    }
                    else {
                        this.showErrorToast(component,'An unknown error occurred.Please contact your Administrator','error');
                    }
                }
        });
        $A.enqueueAction(action);
    },
    showErrorToast : function(component,error,msgtype) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : '',
            message: error,
            type: msgtype
        });
        toastEvent.fire();
    }
})