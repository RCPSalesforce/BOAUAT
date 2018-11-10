({
    getAccountDetails : function(component) {
        component.set("v.showSpinner",true);
        var action = component.get("c.selectedAccInfo");
        action.setParams({
            "accId" : component.get("v.accountId"),
            "type"  : "customer"
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var g = JSON.parse(response.getReturnValue());
                if(g.error){
                    this.showErrorToast(component,'An error occurred.Please contact your Administrator','error');
                    component.set("v.showSpinner",false);
                }
                else{
                    component.set("v.accountDetails",JSON.parse(g[0]));  
                    component.set("v.accConversionRate",JSON.parse(g[1]));
                    component.set("v.defaultLocOptions",JSON.parse(g[2]));
                    
                    //Edit Order
                    var oppData = component.get("v.opportunityData");
                    var oppStages;
                    if(oppData === null){
                        var oppStages = JSON.parse(g[3]).filter(function(ops){
                            return this.indexOf(ops.value) === -1;
                        },['Closed Won']);
                    }
                    else{
                        oppStages = JSON.parse(g[3]);
                    }
                    
                    component.set("v.oppStages",oppStages);
                    component.set("v.showPricingPolicyMessage",g[4]);
                    component.set("v.deliveryAddr",JSON.parse(g[5]));
                    component.set("v.salesPersonOptions",JSON.parse(g[6]));
                    component.set("v.oppType",JSON.parse(g[7]).reverse());
                    
                    var newOrderSourceList = JSON.parse(g[8]).filter(function(osl){
                        return this.indexOf(osl.value) !== -1;
                    },['Phone','Email','Walk-In']);
                    
                    component.set("v.orderSource",newOrderSourceList);
                    component.set("v.noSelectedAccount",false);
                    component.set("v.showSpinner",false);
                    
                    // Edit Order
                    if(oppData != null){
                        
                        // Salesperson
                        var salesPerson = component.get("v.salesPersonOptions");
                        for(var i =0; i< salesPerson.length; i++){
                            if(salesPerson[i].value == oppData.OwnerId){
                                salesPerson[i].selected = true; 
                            }
                            else{
                                salesPerson[i].selected = false;
                            }
                        }
                        
                        // Address
                        component.set("v.accountDetails.ShippingStreet",oppData.Street__c);
                        component.set("v.accountDetails.ShippingCity",oppData.city__c);
                        component.set("v.accountDetails.ShippingPostalCode",oppData.postal_code__c);
                        component.set("v.accountDetails.ShippingState",oppData.state__c);
                        component.set("v.accountDetails.ShippingCountry",oppData.Country__c);
                        
                        // Order and close date
                        component.set("v.orderDate",oppData.Order_Date__c);
                        component.set("v.dueDate",oppData.CloseDate); 
                        
                        // Default Location
                        var defaultLoc = component.get("v.defaultLocOptions");
                        for(var i =0; i< defaultLoc.length; i++){
                            if(defaultLoc[i].value == oppData.default_Location__c){
                                defaultLoc[i].selected = true; 
                            }
                            else{
                                defaultLoc[i].selected = false;
                            }
                        }
                        
                        component.set("v.defaultLocSelectedVal",oppData.default_Location__c);
                        
                        // onhold
                        component.set("v.onHold",oppData.On_hold__c);
                        
                        // internalNote
                        component.set("v.internalNote",oppData.Internal_Note__c);
                        
                        // Customer Note
                        component.set("v.reference",oppData.reference__c);
                        
                        // Customer Order Number
                        component.set("v.customerOrderNo",oppData.customer_order_number__c);
                        
                        // Opp Stage
                        var oppStage = component.get("v.oppStages");
                        for(var i =0; i< oppStage.length; i++){
                            if(oppStage[i].value == oppData.StageName){
                                oppStage[i].selected = true; 
                            }
                            else{
                                oppStage[i].selected = false;
                            }
                        }
                        
                        component.set("v.selectedOppStage",oppData.StageName);
                        
                        // Closed Lost Reason
                        if(component.get("v.selectedOppStage") === 'Closed Lost'){
                            component.set("v.closedLostReason",oppData.Closed_Lost_Reason__c);
                        }
                        
                        // Opportunity Buisness Type
                        var oppBuisnessType = component.get("v.oppType");
                        for(var i =0; i< oppBuisnessType.length; i++){
                            if(oppBuisnessType[i].value == oppData.Type){
                                oppBuisnessType[i].selected = true; 
                            }
                            else{
                                oppBuisnessType[i].selected = false;
                            }
                        }  
                        
                        component.set("v.oppTypeSelectedVal",component.get("v.opportunityData.Type"));
                        
                        // Order Source
                        var ordSource = component.get("v.orderSource");
                        for(var i =0; i< ordSource.length; i++){
                            if(ordSource[i].value == oppData.Order_Source__c){
                                ordSource[i].selected = true; 
                            }
                            else{
                                ordSource[i].selected = false;
                            }
                        }
                        component.set("v.orderSourceSelectedVal",oppData.Order_Source__c);
                    }
                    
                    var accD = component.get("v.accountDetails");
                    if(accD.Pop_up_Alert__c != undefined){
                        alertify.alert(accD.Pop_up_Alert__c).setHeader('Customer Info').set('movable', false);                                         
                    }
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
    setTodaysDate : function(component) {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        
        if(dd<10) {
            dd = '0'+dd;
        } 
        
        if(mm<10) {
            mm = '0'+mm;
        } 
        
        today = yyyy + '-' + mm + '-' + dd; 
        component.set("v.todaysDate", today);
        component.set("v.orderDate", today);
        component.set("v.dueDate", today);
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