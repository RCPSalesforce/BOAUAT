({ 
    doInit : function(component, event, helper) {
        component.set("v.showAccountLookup",true);
        component.set("v.closedLostReason",'');
        
        var oppData = component.get("v.opportunityData");
        if(oppData != null){
            component.set("v.oppIdExists",true);
            helper.getAccountDetails(component);
            if(oppData.Order_Placed_By__c !== undefined){
                component.set("v.selectedContactId",oppData.Order_Placed_By__c);
                component.set("v.contactSearchField",oppData.Order_Placed_By__r.Name);               
            }
        }      
        else{
            var accountId = component.get("v.accountId");
            helper.setOrderDateIfAccountNotPresent(component);
            if(accountId != null){
                helper.getAccountDetails(component);
            }
        }
    },
    handleSelectedAccount : function(component, event, helper) {
        var accId = event.getParam("loopkUpAccountId");
        component.set("v.accountId",accId);
        if(accId != ""){
            helper.getAccountDetails(component);            
        }
        else{
            component.set("v.accountDetails",{});
            component.set("v.accConversionRate",{});
            helper.setOrderDateIfAccountNotPresent(component);           
            component.set("v.noSelectedAccount",true);
            component.set("v.showPricingPolicyMessage",'False');
        }
    },
    allOrderDetails : function(component, event, helper) {
        var stage = component.get("v.selectedOppStage");
     
        var userProfileName = component.get("v.userProfileName");
        var operationProfileUsersList = $A.get("$Label.c.Operation_Profile_Users").split(',');
        
        if(stage == 'Closed Won' && operationProfileUsersList.indexOf(userProfileName) === -1){
            alertify.alert('You do not have the permission to update the stage to Closed Won').setHeader('Required field missing').set('movable', false);
            return;
        }  

        var accId = component.get("v.accountDetails");
        var dueDateValidation = component.find("dueDate").reportValidity();
        var orderDateValidation = component.find("orderDate").reportValidity();
        
        if(accId === undefined || accId === null){
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(Object.keys(accId).length === 0) {
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(dueDateValidation === false){
            alertify.alert('Please enter Due Date').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(orderDateValidation === false){
            alertify.alert('Please enter Order Date').setHeader('Incorrect date format').set('movable', false);
            return;
        }
        if(stage == 'Closed Lost'){
            var lostReasonValidation = component.find("lostReason").reportValidity();
            if(lostReasonValidation === false){
                alertify.alert('Please enter Order Lost Reason').setHeader('Required field missing').set('movable', false);
                return;
            }
        }
        var defaultLocSelectedVal = component.get("v.defaultLocSelectedVal"); 
        defaultLocSelectedVal = defaultLocSelectedVal == '' ? '1' : defaultLocSelectedVal;
        
        var selecteddOppStageVal = stage;
        selecteddOppStageVal = selecteddOppStageVal == '' ? 'Prospecting' : selecteddOppStageVal;
        
        var selectedLeadTime = component.get("v.selectedLeadTime");
        selectedLeadTime = selectedLeadTime == '' ? 'Sea Freight Lead Time' : selectedLeadTime;
        
        var salesPersonSelectedVal = component.get("v.salesPersonSelectedVal");
        salesPersonSelectedVal = salesPersonSelectedVal == '' ? component.get("v.salesPersonOptions")[0].value : salesPersonSelectedVal; 

        var accountD = component.get("v.accountDetails");
        var orderDate = component.get("v.orderDate");
        var dueDate = component.get("v.dueDate");
        var reference = component.get("v.reference");
        var internalNote = component.get("v.internalNote");
        var selectedContactId = component.get("v.selectedContactId");
        var closedLostReason =  component.get("v.closedLostReason");

        accountD.orderDate = orderDate;
        accountD.dueDate = dueDate;
        accountD.reference = reference;
        accountD.internalNote = internalNote;
        accountD.selecteddLocVal = defaultLocSelectedVal;
        accountD.selecteddOppStageVal = selecteddOppStageVal;
        accountD.selectedLeadTime = selectedLeadTime;
        accountD.salesPersonSelectedVal = salesPersonSelectedVal;
        accountD.selectedContactId = selectedContactId;
        accountD.closedLostReason = selecteddOppStageVal == 'Closed Lost' ? closedLostReason : '';
        var oppData = component.get("v.opportunityData");
        if(oppData != null){
            accountD.opportunityId = oppData.Id;
        }
        else{
            accountD.opportunityId = '';
        }
        var OrdProducts = $A.get("e.c:NewOrder_SendCustomerDetails");
        OrdProducts.setParams({
            "createOrder" : accountD
        });
        OrdProducts.fire();
    }
})