({
    createOrderHelper : function(component,event) {
        component.set("v.showSpinner",true);
        var sendOrderDetails = true;
        var createOrder = event.getParam("createOrder");      
        var accDetails = {};
       /* 
        if(createOrder.Name == '' || createOrder.Name == null){
            alert('Please enter a customer name in Account Details Section');
            return;
        }
       */ 
        accDetails.Id = createOrder.Id;
        accDetails.AccountName = createOrder.Name;
        accDetails.ShippingStreet = createOrder.ShippingStreet;
        accDetails.ShippingCity = createOrder.ShippingCity;
        accDetails.ShippingPostalCode = createOrder.ShippingPostalCode;
        accDetails.ShippingState = createOrder.ShippingState;
        accDetails.ShippingCountry = createOrder.ShippingCountry;
        accDetails.OwnerId = createOrder.OwnerId;
        accDetails.CurrencyIsoCode = createOrder.CurrencyIsoCode;
        accDetails.orderDate = createOrder.orderDate;
        accDetails.dueDate = createOrder.dueDate;
        accDetails.reference = createOrder.reference; 
        accDetails.internalNote = createOrder.internalNote;
        accDetails.selecteddLocVal = createOrder.selecteddLocVal;
        accDetails.onHold = createOrder.onHold;
        accDetails.customerOrderNo = createOrder.customerOrderNo;
        accDetails.selecteddOppStageVal = createOrder.selecteddOppStageVal;
        accDetails.selectedContactId = createOrder.selectedContactId;
        accDetails.salesPersonSelectedVal = createOrder.salesPersonSelectedVal;
        accDetails.closedLostReason = createOrder.closedLostReason;
        accDetails.opportunityId = createOrder.opportunityId;
        accDetails.oppTypeSelectedVal = createOrder.oppTypeSelectedVal;
        accDetails.oppOrderSource = createOrder.oppOrderSource;
        
        var allSelectedProducts = component.get("v.allSelectedProducts");
        console.log('Test order prod ' + JSON.stringify(allSelectedProducts));
        var orderProductDetails = [];
        for(var g = 0 ; g < allSelectedProducts.length ; g++){   
            console.log('pricingPolicyPrice ' + allSelectedProducts[g].pricingPolicyPrice);
            if(allSelectedProducts[g].quantity == ''){
                alert('Please enter the required fields in Selected Products Section');     
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].BasePrice == ''){
                alert('Please enter the required fields in Selected Products Section');     
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].pricingPolicyPrice == ''){
                alert('Please enter the required fields in Selected Products Section');     
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].UnitPrice != null && allSelectedProducts[g].quantity != null){
                var orderProductDetail = {};
                orderProductDetail.Id = allSelectedProducts[g].Id;
                orderProductDetail.ProductCode = allSelectedProducts[g].ProductCode;
                orderProductDetail.Quantity = allSelectedProducts[g].quantity;
                //orderProductDetail.UnitPrice = allSelectedProducts[g].UnitPrice;
                
                if((allSelectedProducts[g].pricingPolicyRuleId) != '' && (allSelectedProducts[g].quantity != allSelectedProducts[g].pricingPolicyquantity)){
                    console.log('Test1 ' + allSelectedProducts[g].pricingPolicyPrice);
                    orderProductDetail.UnitPrice = allSelectedProducts[g].pricingPolicyPrice;
                }
                else if((allSelectedProducts[g].pricingPolicyRuleId) != '' && (allSelectedProducts[g].quantity == allSelectedProducts[g].pricingPolicyquantity)){
                    console.log('Test2 ' + allSelectedProducts[g].BasePrice);
                    orderProductDetail.UnitPrice = allSelectedProducts[g].BasePrice;                   
                }
                else if(allSelectedProducts[g].pricingPolicyRuleId == ''){
                    console.log('Test3 ' + allSelectedProducts[g].BasePrice);
                    orderProductDetail.UnitPrice = allSelectedProducts[g].BasePrice;                    
                }
  				
                if((allSelectedProducts[g].discount) == '' || (allSelectedProducts[g].discount == null)){
                    console.log('discount');
                    orderProductDetail.Discount = 0.0;
                }
                else{
                   orderProductDetail.Discount = allSelectedProducts[g].discount; 
                }
                //orderProductDetail.UnitPrice = allSelectedProducts[g].BasePrice;
                //orderProductDetail.Discount = allSelectedProducts[g].discount;
                orderProductDetail.stockDescription = allSelectedProducts[g].stockDescription;
                //orderProductDetail.opptId = createOrder.opportunityId;
                orderProductDetails.push(orderProductDetail);
            }            
        }
        
        console.log('Order Details ' + JSON.stringify(orderProductDetails));
        //console.log('Product Details ' + JSON.stringify(orderProductDetails));
        if(sendOrderDetails == true){
            var action = component.get("c.createOrder");
            
            action.setParams(
                { 
                    "orderData"   : JSON.stringify(accDetails),
                    "productData" : JSON.stringify(orderProductDetails)
                }
            );
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = JSON.parse(response.getReturnValue());
                    if(resp.success){
                        component.set("v.showSpinner",false);
                        this.showSuccessToast(component,createOrder.opportunityId);
                        //$A.get('e.force:refreshView').fire();
                        //this.navigateToOrder(component,resp.success);
                        var aTag = document.createElement('a');
                        aTag.setAttribute('href',"/lightning/r/Account/" + resp.success + '/view');
                        aTag.click();
                    }
                    if(resp.emptyOrderProd){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.emptyOrderProd,'info');
                    }
                    if(resp.remainingCreditBalanceError){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.remainingCreditBalanceError,'info');
                    }
                    if(resp.creditBalanceError){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.creditBalanceError,'info');
                    }
                    if(resp.error){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.error,'error');
                    }
                    if(resp.unknownerror){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.unknownerror,'info');
                    }
                }
                else if (state === "INCOMPLETE") {
                    
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                //console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            //console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
    },
    prodQtyDetails : function(component,event){
        var accountDefaultLoc = event.getParam("accountDefaultLoc");
        var action = component.get("c.prodDetailsForLocation");            
        action.setParams(
            { 
                "accLocation"   : accountDefaultLoc,
                "productId" : component.get("v.currentProdId")
            }
        );
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                console.log('resp ',response.getReturnValue());
                var resp = JSON.parse(response.getReturnValue());
                if(resp.success == ''){                    
                    alertify.alert('No details available').setHeader('Quantity Details').set('movable', false);                    
                }
                if(resp.success != ''){
                    var phyStock = resp.success.Physical_Quantity__c == undefined ? 'No details available' : resp.success.Physical_Quantity__c;
                    var maxStock = resp.success.Maximum_Stock__c == undefined ? 'No details available' : resp.success.Maximum_Stock__c;
                    var minStock = resp.success.Minimum_Stock__c == undefined ? 'No details available' : resp.success.Minimum_Stock__c;
                    alertify.alert('Physical Quantity: <b>' + phyStock + 
                                   '</b><br/>Maximum Stock: <b>' + maxStock + '</b>' +
                                   '</b><br/>Minimum Stock: <b>' + minStock + '</b>'                            
                                  ).setHeader('Quantity Details').set('movable', false); 
                }
                if(resp.error){
                    this.showErrorToast(component,resp.error,'error');
                }
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        //console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        // pass loc and prodid
        // get physical qty
        // display physical qty
        
    },
    newProductPrices : function(component,event){
        var qty = event.getSource().get("v.value");
        var pprId = event.getSource().get("v.ariaDescribedBy");
        console.log('pprId ' + JSON.stringify(pprId));
        component.set(pprId.BasePrice,4);
        //if(pprId != ''){} 
    },
    showSuccessToast : function(component,opptStat) {
        var operationType = opptStat === '' ? 'Order created successfully' : 'Order updated successfully';
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : '',
            message: operationType,
            type: 'success'
        });
        toastEvent.fire();
    },
    showErrorToast : function(component,error,msgtype) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : '',
            message: error,
            type: msgtype
        });
        toastEvent.fire();
    },
    navigateToOrder : function(component,recId){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+recId
        });
        urlEvent.fire();
    }
    
})