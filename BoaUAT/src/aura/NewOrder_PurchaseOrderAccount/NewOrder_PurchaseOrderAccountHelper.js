({
    getAccountDetails : function(component) {
        component.set("v.showSpinner",true);
        var action = component.get("c.selectedAccInfo");
        action.setParams({
            "accId" : component.get("v.accountId"),
            "type"  : "supplier"
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
                    component.set("v.oppStages",JSON.parse(g[3]));
                    component.set("v.leadTime",JSON.parse(g[4]));
                    component.set("v.salesPersonOptions",JSON.parse(g[5]));
                    component.set("v.noSelectedAccount",false);
                    component.set("v.showSpinner",false);
                    component.set("v.todaysDate", this.setTodaysDate());
                    this.setOrderDateIfAccountPresent(component);
                    
                    // Edit Order
                    var oppData = component.get("v.opportunityData");
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
                        
                        // Lead Time
                        var leadTime = component.get("v.leadTime");
                        for(var i =0; i< leadTime.length; i++){
                            if(leadTime[i].value == oppData.Lead_Time__c){
                                leadTime[i].selected = true; 
                            }
                            else{
                                leadTime[i].selected = false;
                            }
                        }
                        
                        // internalNote
                        component.set("v.internalNote",oppData.Internal_Note__c);
                        
                        // Customer Note
                        component.set("v.reference",oppData.reference__c);
                        
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
    setOrderDateIfAccountPresent : function(component){
        if(component.get("v.accountDetails").Sea_Freight_Lead_Time__c != null){
            var newdate = new Date();
            newdate.setDate(newdate.getDate() + (component.get("v.accountDetails").Sea_Freight_Lead_Time__c));
            
            var dd = newdate.getDate();
            var mm = newdate.getMonth()+1; //January is 0!
            var yyyy = newdate.getFullYear();
            
            if(dd<10) {
                dd = '0'+dd;
            } 
            
            if(mm<10) {
                mm = '0'+mm;
            } 
            
            var formattedNewDate = yyyy + '-' + mm + '-' + dd;
            
            component.set("v.orderDate", this.setTodaysDate());
            component.set("v.dueDate", formattedNewDate);
        }
        else{
            component.set("v.orderDate", this.setTodaysDate());
            component.set("v.dueDate", this.setTodaysDate());
        }
    },
    setOrderDateIfAccountNotPresent : function(component) {
        var todaysDate = this.setTodaysDate();
        component.set("v.orderDate", todaysDate);
        component.set("v.dueDate", todaysDate);
    },
    setTodaysDate : function() {
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
        return today;
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