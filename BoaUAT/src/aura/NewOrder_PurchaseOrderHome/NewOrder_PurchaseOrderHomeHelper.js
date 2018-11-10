({
    getOrderProd : function(component) {
        var accId = component.get("v.pageReference").state.c__accountId;
        var oppId = component.get("v.pageReference").state.c__oppId;
        var action = component.get("c.purchaseOrderEdit");
        action.setParams({
            "oppId"  : oppId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var g = JSON.parse(response.getReturnValue());
                var oppInfo = JSON.parse(g[0]);
                
                if(!g.error){ 
                    //console.log('torder');
                    //console.log(oppInfo.Order_Placed_By__c);
                    if(g.length > 0){
                        component.set("v.userProfileName",g[2]);
                        if(g[1].length == 0){
                            component.set("v.selectedProducts",[]);
                        }
                        else{
                            component.set("v.selectedProducts",g[1]);
                        }
                        
                       component.set("v.opportunityData",oppInfo);
                        component.set("v.accountId",accId);
                        component.set("v.showAccount",true);
                        component.set("v.showProduct",true); 
                    }
                    
                }
                else{
                   console.log('testorder'); // add error logic
                }
            }
            else if (state === "INCOMPLETE") {
                // add toast message here
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            // add toast message here
                        }
                    } 
                    else {
                        // add toast message here
                    }
                }
        });
        $A.enqueueAction(action);
    }
})