({ 
    doInit : function(component, event, helper) {
        if($A.get("$Browser.isPhone")){
            component.set("v.deviceSize",true);
        }
        component.set("v.showAccountLookup",true);
        component.set("v.closedLostReason",'');
        
        var oppData = component.get("v.opportunityData");
        if(oppData != null){
            component.set("v.oppIdExists",true);
            helper.setTodaysDate(component);
            helper.getAccountDetails(component);
            if(oppData.Order_Placed_By__c !== undefined){
                component.set("v.selectedContactId",oppData.Order_Placed_By__c);
                component.set("v.contactSearchField",oppData.Order_Placed_By__r.Name);               
            }
        }      
        else{
            var accountId = component.get("v.accountId");
            helper.setTodaysDate(component);
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
            helper.setTodaysDate(component);           
            component.set("v.noSelectedAccount",true);
            component.set("v.showPricingPolicyMessage",'False');
            component.set("v.deliveryAddr",[]);
        }
    },
    allOrderDetails : function(component, event, helper) {
        var userProfileName = component.get("v.userProfileName");
        var operationProfileUsersList = $A.get("$Label.c.Operation_Profile_Users").split(',');
        var stage = component.get("v.selectedOppStage");
        if(stage == 'Closed Won' && operationProfileUsersList.indexOf(userProfileName) === -1){
            alertify.alert('You do not have the permission to update the stage to Closed Won').setHeader('Required field missing').set('movable', false);
            return;
        }
        var accId = component.get("v.accountDetails");
        var customerOrderNo = component.find("customerOrderNo").reportValidity();
        var dueDateValidation = component.find("dueDate").reportValidity();
        var orderDateValidation = component.find("orderDate").reportValidity();
        if(stage == 'Closed Lost'){
            var lostReasonValidation = component.find("lostReason").reportValidity();
            if(lostReasonValidation === false){
                alertify.alert('Please enter order lost reason').setHeader('Required field missing').set('movable', false);
                return;
            }
        }
        
        if(accId === undefined || accId === null){
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(Object.keys(accId).length === 0) {
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(customerOrderNo === false){
            alertify.alert('Please enter customer order no').setHeader('Required field missing').set('movable', false);
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
        if(customerOrderNo){
            var defaultLocSelectedVal = component.get("v.defaultLocSelectedVal"); 
            defaultLocSelectedVal = defaultLocSelectedVal == '' ? '1' : defaultLocSelectedVal;
            
            var selecteddOppStageVal = stage;
            selecteddOppStageVal = selecteddOppStageVal == '' ? 'Prospecting' : selecteddOppStageVal;
            
            var salesPersonSelectedVal = component.get("v.salesPersonSelectedVal");
            salesPersonSelectedVal = salesPersonSelectedVal == '' ? component.get("v.salesPersonOptions")[0].value : salesPersonSelectedVal; 
            
            var oppTypeSelectedVal = component.get("v.oppTypeSelectedVal");
            oppTypeSelectedVal = oppTypeSelectedVal == '' ? component.get("v.oppType")[0].value : oppTypeSelectedVal;
            
            var oppOrderSource = component.get("v.orderSourceSelectedVal");
            oppOrderSource = oppOrderSource == '' ? component.get("v.orderSource")[0].value : oppOrderSource;
            
            var accountD = component.get("v.accountDetails");
            var orderDate = component.get("v.orderDate");
            var dueDate = component.get("v.dueDate");
            var reference = component.get("v.reference");
            var internalNote = component.get("v.internalNote");
            var onHold = component.get("v.onHold");
            var customerOrderNo = component.get("v.customerOrderNo");
            var selectedContactId = component.get("v.selectedContactId");
            var closedLostReason =  component.get("v.closedLostReason");            
            var onboardingStartDate = null;
            var onboardingCloseDate = null;
            var onboardingContact = null;
            var buisnessType = component.get("v.oppTypeSelectedVal");
            if(stage === 'Closed Won' && buisnessType === 'New Business'){
                onboardingStartDate = component.find("onboardingStartDate").get("v.value");
                onboardingCloseDate = component.find("onboardingCloseDate").get("v.value");
                onboardingContact = component.find("onboardingContact").get("v.value");
                
                if((stage === 'Closed Won') && (onboardingStartDate === null  || onboardingCloseDate === null || onboardingContact === null)){
                    alertify.alert('Please enter Onboarding start,end date and point of contact when stage is Closed Won').setHeader('Required field missing').set('movable', false);
                    return;
                }
            }
            
            var oppData = component.get("v.opportunityData");
            if(oppData != null){
                accountD.opportunityId = oppData.Id;
            }
            else{
                accountD.opportunityId = '';
            }
            
            accountD.orderDate = orderDate;
            accountD.dueDate = dueDate;
            accountD.reference = reference;
            accountD.internalNote = internalNote;
            accountD.selecteddLocVal = defaultLocSelectedVal;
            accountD.onHold = onHold;
            accountD.customerOrderNo = customerOrderNo;
            accountD.selecteddOppStageVal = selecteddOppStageVal;
            accountD.selectedContactId = selectedContactId;
            accountD.salesPersonSelectedVal = salesPersonSelectedVal;
            accountD.closedLostReason = selecteddOppStageVal == 'Closed Lost' ? closedLostReason : '';
            accountD.oppTypeSelectedVal = oppTypeSelectedVal;
            accountD.oppOrderSource = oppOrderSource;            
            accountD.onboardingStartDate = onboardingStartDate;
            accountD.onboardingCloseDate = onboardingCloseDate;
            accountD.onboardingContact = onboardingContact;
            
            var OrdProducts = $A.get("e.c:NewOrder_SendCustomerDetails");
            OrdProducts.setParams({
                "createOrder" : accountD
            });
            component.set("v.closedLostReason",'');
            OrdProducts.fire();
        }
        
    }, 
    handleSelectedProdToAcc : function(component, event){
        var defaultLoc = '';
        if(component.get("v.defaultLocSelectedVal") === ''){
            defaultLoc = '1';
        }
        else{
            defaultLoc = component.get("v.defaultLocSelectedVal");
        }
        var sendAccLoc = $A.get("e.c:NewOrder_AcctDetailsToSelectedProd");
        sendAccLoc.setParams({
            "oppDefaultLocation" : defaultLoc 
        });
        sendAccLoc.fire();
    }, 
    handleUpdateDeliveryAddress : function(component, event){
        var delAddress = event.getParam("delAddress");
        var accAddress = component.get("v.accountDetails");
        accAddress.ShippingStreet = delAddress.Street__c;
        accAddress.ShippingCity = delAddress.City__c;
        accAddress.ShippingPostalCode = delAddress.Postal_Code__c;
        accAddress.ShippingState = delAddress.State__c;
        accAddress.ShippingCountry = delAddress.Country__c;
        component.set("v.accountDetails",accAddress);
    }
})({ 
    doInit : function(component, event, helper) {
        if($A.get("$Browser.isPhone")){
            component.set("v.deviceSize",true);
        }
        component.set("v.showAccountLookup",true);
        component.set("v.closedLostReason",'');
        
        var oppData = component.get("v.opportunityData");
        if(oppData != null){
            component.set("v.oppIdExists",true);
            helper.setTodaysDate(component);
            helper.getAccountDetails(component);
            if(oppData.Order_Placed_By__c !== undefined){
                component.set("v.selectedContactId",oppData.Order_Placed_By__c);
                component.set("v.contactSearchField",oppData.Order_Placed_By__r.Name);               
            }
        }      
        else{
            var accountId = component.get("v.accountId");
            helper.setTodaysDate(component);
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
            helper.setTodaysDate(component);           
            component.set("v.noSelectedAccount",true);
            component.set("v.showPricingPolicyMessage",'False');
            component.set("v.deliveryAddr",[]);
        }
    },
    allOrderDetails : function(component, event, helper) {
        var userProfileName = component.get("v.userProfileName");
        var operationProfileUsersList = $A.get("$Label.c.Operation_Profile_Users").split(',');
        var stage = component.get("v.selectedOppStage");
        if(stage == 'Closed Won' && operationProfileUsersList.indexOf(userProfileName) === -1){
            alertify.alert('You do not have the permission to update the stage to Closed Won').setHeader('Required field missing').set('movable', false);
            return;
        }
        var accId = component.get("v.accountDetails");
        var customerOrderNo = component.find("customerOrderNo").reportValidity();
        var dueDateValidation = component.find("dueDate").reportValidity();
        var orderDateValidation = component.find("orderDate").reportValidity();
        if(stage == 'Closed Lost'){
            var lostReasonValidation = component.find("lostReason").reportValidity();
            if(lostReasonValidation === false){
                alertify.alert('Please enter order lost reason').setHeader('Required field missing').set('movable', false);
                return;
            }
        }
        
        if(accId === undefined || accId === null){
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(Object.keys(accId).length === 0) {
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(customerOrderNo === false){
            alertify.alert('Please enter customer order no').setHeader('Required field missing').set('movable', false);
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
        if(customerOrderNo){
            var defaultLocSelectedVal = component.get("v.defaultLocSelectedVal"); 
            defaultLocSelectedVal = defaultLocSelectedVal == '' ? '1' : defaultLocSelectedVal;
            
            var selecteddOppStageVal = stage;
            selecteddOppStageVal = selecteddOppStageVal == '' ? 'Prospecting' : selecteddOppStageVal;
            
            var salesPersonSelectedVal = component.get("v.salesPersonSelectedVal");
            salesPersonSelectedVal = salesPersonSelectedVal == '' ? component.get("v.salesPersonOptions")[0].value : salesPersonSelectedVal; 
            
            var oppTypeSelectedVal = component.get("v.oppTypeSelectedVal");
            oppTypeSelectedVal = oppTypeSelectedVal == '' ? component.get("v.oppType")[0].value : oppTypeSelectedVal;
            
            var oppOrderSource = component.get("v.orderSourceSelectedVal");
            oppOrderSource = oppOrderSource == '' ? component.get("v.orderSource")[0].value : oppOrderSource;
            
            var accountD = component.get("v.accountDetails");
            var orderDate = component.get("v.orderDate");
            var dueDate = component.get("v.dueDate");
            var reference = component.get("v.reference");
            var internalNote = component.get("v.internalNote");
            var onHold = component.get("v.onHold");
            var customerOrderNo = component.get("v.customerOrderNo");
            var selectedContactId = component.get("v.selectedContactId");
            var closedLostReason =  component.get("v.closedLostReason");            
            var onboardingStartDate = null;
            var onboardingCloseDate = null;
            var onboardingContact = null;
            var buisnessType = component.get("v.oppTypeSelectedVal");
            if(stage === 'Closed Won' && buisnessType === 'New Business'){
                onboardingStartDate = component.find("onboardingStartDate").get("v.value");
                onboardingCloseDate = component.find("onboardingCloseDate").get("v.value");
                onboardingContact = component.find("onboardingContact").get("v.value");
                
                if((stage === 'Closed Won') && (onboardingStartDate === null  || onboardingCloseDate === null || onboardingContact === null)){
                    alertify.alert('Please enter Onboarding start,end date and point of contact when stage is Closed Won').setHeader('Required field missing').set('movable', false);
                    return;
                }
            }
            
            var oppData = component.get("v.opportunityData");
            if(oppData != null){
                accountD.opportunityId = oppData.Id;
            }
            else{
                accountD.opportunityId = '';
            }
            
            accountD.orderDate = orderDate;
            accountD.dueDate = dueDate;
            accountD.reference = reference;
            accountD.internalNote = internalNote;
            accountD.selecteddLocVal = defaultLocSelectedVal;
            accountD.onHold = onHold;
            accountD.customerOrderNo = customerOrderNo;
            accountD.selecteddOppStageVal = selecteddOppStageVal;
            accountD.selectedContactId = selectedContactId;
            accountD.salesPersonSelectedVal = salesPersonSelectedVal;
            accountD.closedLostReason = selecteddOppStageVal == 'Closed Lost' ? closedLostReason : '';
            accountD.oppTypeSelectedVal = oppTypeSelectedVal;
            accountD.oppOrderSource = oppOrderSource;            
            accountD.onboardingStartDate = onboardingStartDate;
            accountD.onboardingCloseDate = onboardingCloseDate;
            accountD.onboardingContact = onboardingContact;
            
            var OrdProducts = $A.get("e.c:NewOrder_SendCustomerDetails");
            OrdProducts.setParams({
                "createOrder" : accountD
            });
            component.set("v.closedLostReason",'');
            OrdProducts.fire();
        }
        
    }, 
    handleSelectedProdToAcc : function(component, event){
        var defaultLoc = '';
        if(component.get("v.defaultLocSelectedVal") === ''){
            defaultLoc = '1';
        }
        else{
            defaultLoc = component.get("v.defaultLocSelectedVal");
        }
        var sendAccLoc = $A.get("e.c:NewOrder_AcctDetailsToSelectedProd");
        sendAccLoc.setParams({
            "oppDefaultLocation" : defaultLoc 
        });
        sendAccLoc.fire();
    }, 
    handleUpdateDeliveryAddress : function(component, event){
        var delAddress = event.getParam("delAddress");
        var accAddress = component.get("v.accountDetails");
        accAddress.ShippingStreet = delAddress.Street__c;
        accAddress.ShippingCity = delAddress.City__c;
        accAddress.ShippingPostalCode = delAddress.Postal_Code__c;
        accAddress.ShippingState = delAddress.State__c;
        accAddress.ShippingCountry = delAddress.Country__c;
        component.set("v.accountDetails",accAddress);
    }
})({ 
    doInit : function(component, event, helper) {
        if($A.get("$Browser.isPhone")){
            component.set("v.deviceSize",true);
        }
        component.set("v.showAccountLookup",true);
        component.set("v.closedLostReason",'');
        
        var oppData = component.get("v.opportunityData");
        if(oppData != null){
            component.set("v.oppIdExists",true);
            helper.setTodaysDate(component);
            helper.getAccountDetails(component);
            if(oppData.Order_Placed_By__c !== undefined){
                component.set("v.selectedContactId",oppData.Order_Placed_By__c);
                component.set("v.contactSearchField",oppData.Order_Placed_By__r.Name);               
            }
        }      
        else{
            var accountId = component.get("v.accountId");
            helper.setTodaysDate(component);
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
            helper.setTodaysDate(component);           
            component.set("v.noSelectedAccount",true);
            component.set("v.showPricingPolicyMessage",'False');
            component.set("v.deliveryAddr",[]);
        }
    },
    allOrderDetails : function(component, event, helper) {
        var userProfileName = component.get("v.userProfileName");
        var operationProfileUsersList = $A.get("$Label.c.Operation_Profile_Users").split(',');
        var stage = component.get("v.selectedOppStage");
        if(stage == 'Closed Won' && operationProfileUsersList.indexOf(userProfileName) === -1){
            alertify.alert('You do not have the permission to update the stage to Closed Won').setHeader('Required field missing').set('movable', false);
            return;
        }
        var accId = component.get("v.accountDetails");
        var customerOrderNo = component.find("customerOrderNo").reportValidity();
        var dueDateValidation = component.find("dueDate").reportValidity();
        var orderDateValidation = component.find("orderDate").reportValidity();
        if(stage == 'Closed Lost'){
            var lostReasonValidation = component.find("lostReason").reportValidity();
            if(lostReasonValidation === false){
                alertify.alert('Please enter order lost reason').setHeader('Required field missing').set('movable', false);
                return;
            }
        }
        
        if(accId === undefined || accId === null){
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(Object.keys(accId).length === 0) {
            alertify.alert('Please select a customer').setHeader('Required field missing').set('movable', false);
            return;
        }
        if(customerOrderNo === false){
            alertify.alert('Please enter customer order no').setHeader('Required field missing').set('movable', false);
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
        if(customerOrderNo){
            var defaultLocSelectedVal = component.get("v.defaultLocSelectedVal"); 
            defaultLocSelectedVal = defaultLocSelectedVal == '' ? '1' : defaultLocSelectedVal;
            
            var selecteddOppStageVal = stage;
            selecteddOppStageVal = selecteddOppStageVal == '' ? 'Prospecting' : selecteddOppStageVal;
            
            var salesPersonSelectedVal = component.get("v.salesPersonSelectedVal");
            salesPersonSelectedVal = salesPersonSelectedVal == '' ? component.get("v.salesPersonOptions")[0].value : salesPersonSelectedVal; 
            
            var oppTypeSelectedVal = component.get("v.oppTypeSelectedVal");
            oppTypeSelectedVal = oppTypeSelectedVal == '' ? component.get("v.oppType")[0].value : oppTypeSelectedVal;
            
            var oppOrderSource = component.get("v.orderSourceSelectedVal");
            oppOrderSource = oppOrderSource == '' ? component.get("v.orderSource")[0].value : oppOrderSource;
            
            var accountD = component.get("v.accountDetails");
            var orderDate = component.get("v.orderDate");
            var dueDate = component.get("v.dueDate");
            var reference = component.get("v.reference");
            var internalNote = component.get("v.internalNote");
            var onHold = component.get("v.onHold");
            var customerOrderNo = component.get("v.customerOrderNo");
            var selectedContactId = component.get("v.selectedContactId");
            var closedLostReason =  component.get("v.closedLostReason");            
            var onboardingStartDate = null;
            var onboardingCloseDate = null;
            var onboardingContact = null;
            var buisnessType = component.get("v.oppTypeSelectedVal");
            if(stage === 'Closed Won' && buisnessType === 'New Business'){
                onboardingStartDate = component.find("onboardingStartDate").get("v.value");
                onboardingCloseDate = component.find("onboardingCloseDate").get("v.value");
                onboardingContact = component.find("onboardingContact").get("v.value");
                
                if((stage === 'Closed Won') && (onboardingStartDate === null  || onboardingCloseDate === null || onboardingContact === null)){
                    alertify.alert('Please enter Onboarding start,end date and point of contact when stage is Closed Won').setHeader('Required field missing').set('movable', false);
                    return;
                }
            }
            
            var oppData = component.get("v.opportunityData");
            if(oppData != null){
                accountD.opportunityId = oppData.Id;
            }
            else{
                accountD.opportunityId = '';
            }
            
            accountD.orderDate = orderDate;
            accountD.dueDate = dueDate;
            accountD.reference = reference;
            accountD.internalNote = internalNote;
            accountD.selecteddLocVal = defaultLocSelectedVal;
            accountD.onHold = onHold;
            accountD.customerOrderNo = customerOrderNo;
            accountD.selecteddOppStageVal = selecteddOppStageVal;
            accountD.selectedContactId = selectedContactId;
            accountD.salesPersonSelectedVal = salesPersonSelectedVal;
            accountD.closedLostReason = selecteddOppStageVal == 'Closed Lost' ? closedLostReason : '';
            accountD.oppTypeSelectedVal = oppTypeSelectedVal;
            accountD.oppOrderSource = oppOrderSource;            
            accountD.onboardingStartDate = onboardingStartDate;
            accountD.onboardingCloseDate = onboardingCloseDate;
            accountD.onboardingContact = onboardingContact;
            
            var OrdProducts = $A.get("e.c:NewOrder_SendCustomerDetails");
            OrdProducts.setParams({
                "createOrder" : accountD
            });
            component.set("v.closedLostReason",'');
            OrdProducts.fire();
        }
        
    }, 
    handleSelectedProdToAcc : function(component, event){
        var defaultLoc = '';
        if(component.get("v.defaultLocSelectedVal") === ''){
            defaultLoc = '1';
        }
        else{
            defaultLoc = component.get("v.defaultLocSelectedVal");
        }
        var sendAccLoc = $A.get("e.c:NewOrder_AcctDetailsToSelectedProd");
        sendAccLoc.setParams({
            "oppDefaultLocation" : defaultLoc 
        });
        sendAccLoc.fire();
    }, 
    handleUpdateDeliveryAddress : function(component, event){
        var delAddress = event.getParam("delAddress");
        var accAddress = component.get("v.accountDetails");
        accAddress.ShippingStreet = delAddress.Street__c;
        accAddress.ShippingCity = delAddress.City__c;
        accAddress.ShippingPostalCode = delAddress.Postal_Code__c;
        accAddress.ShippingState = delAddress.State__c;
        accAddress.ShippingCountry = delAddress.Country__c;
        component.set("v.accountDetails",accAddress);
    }
})