({
    prodQtyDetails : function(component,event){
        component.set("v.showSpinner",true);
        var action = component.get("c.prodDetailsForLocation");            
        action.setParams({ "productId" : component.get("v.stockCode")});
        //console.log('productId ' + component.get("v.stockCode"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                var resp = JSON.parse(response.getReturnValue());
                if(resp.success == ''){       
                    component.set("v.showSpinner",false);
                    alertify.alert('No details available').setHeader('Quantity Details').set('movable', false);   
                    return;
                }
                if(resp.success != ''){
                    component.set("v.stockLocationList",resp.success);
                    component.set("v.showSpinner",false);
                    $A.util.toggleClass(component.find("stockLocationModal"),"slds-hide");
                }
                if(resp.error){
                    component.set("v.showSpinner",false);
                    this.showErrorToast(component,resp.error,'error');
                }
            }
            else if (state === "INCOMPLETE") {
                component.set("v.showSpinner",false);
                this.showErrorToast(component,'An unknown error occurred.Please contact your Administrato','error');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.showSpinner",false);
                            this.showErrorToast(component,'An unknown error occurred.Please contact your Administrato','error');
                        }
                    } else {
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,'An unknown error occurred.Please contact your Administrato','error');
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