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
        //accDetails.OwnerId = createOrder.OwnerId;
        accDetails.CurrencyIsoCode = createOrder.CurrencyIsoCode;
        accDetails.orderDate = createOrder.orderDate;
        accDetails.dueDate = createOrder.dueDate;
        accDetails.reference = createOrder.reference; 
        accDetails.internalNote = createOrder.internalNote;
        accDetails.selecteddLocVal = createOrder.selecteddLocVal;
        //accDetails.onHold = createOrder.onHold;
        //accDetails.customerOrderNo = createOrder.customerOrderNo;
        accDetails.selecteddOppStageVal = createOrder.selecteddOppStageVal;
        accDetails.selectedLeadTime = createOrder.selectedLeadTime;
        accDetails.salesPersonSelectedVal = createOrder.salesPersonSelectedVal;
        accDetails.selectedContactId = createOrder.selectedContactId;
        accDetails.closedLostReason = createOrder.closedLostReason;
        accDetails.opportunityId = createOrder.opportunityId;
		//console.log('createOrder ' + JSON.stringify(createOrder));   
        
        var allSelectedProducts = component.get("v.allSelectedProducts");
        console.log('Test order prod ' + JSON.stringify(allSelectedProducts));
        var orderProductDetails = [];
        for(var g = 0 ; g < allSelectedProducts.length ; g++){          
            if(allSelectedProducts[g].orderedQuantity == '' || allSelectedProducts[g].orderedQuantity == null){
                alert('Please enter the required fields in Selected Products Section');     
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].orderedQuantity < 0 || allSelectedProducts[g].orderedQuantity == 0 || allSelectedProducts[g].packPrice < 0){
                alert('Ordered Quantity cannot be less than 1');     
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].discount == '' || allSelectedProducts[g].discount == null){
                //alert('Discount field cannot be kept empty.Please enter a value of 0 to proceed');     
                //sendOrderDetails = false;
                //component.set("v.showSpinner",false);
                //break;
                allSelectedProducts[g].discount = 0.00;
            }
            if(allSelectedProducts[g].discount > 100 || allSelectedProducts[g].discount < 0){
                alert('Please enter discount between 0 to 100%');     
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].packPrice === '' || allSelectedProducts[g].packPrice === null){
                console.log('nmbmbmm');
                alert('Please enter the required fields in Selected Products Section');    
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].orderedQuantity !== '' && allSelectedProducts[g].orderedQuantity !== null && allSelectedProducts[g].packPrice !== '' && allSelectedProducts[g].packPrice !== null){
                var orderProductDetail = {};
                orderProductDetail.id = allSelectedProducts[g].Id;
                orderProductDetail.stockCode = allSelectedProducts[g].productId;
                orderProductDetail.orderedQuantity = allSelectedProducts[g].orderedQuantity;
                //orderProductDetail.packPrice = allSelectedProducts[g].packPrice == 0.00 ? allSelectedProducts[g].UnitPrice : allSelectedProducts[g].packPrice;
                orderProductDetail.packPrice = allSelectedProducts[g].packPrice;
                orderProductDetail.discount = allSelectedProducts[g].discount;
                orderProductDetail.stockDescription = allSelectedProducts[g].stockDescription;
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
                        aTag.setAttribute('href',"/lightning/r/Opportunity/" + resp.success + '/view');
                        aTag.click();
                    }
                    if(resp.emptyProdList){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.emptyProdList,'info');
                    }
                    if(resp.error){
                        component.set("v.showSpinner",false);
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
        }
    },
    /*
    newProductPrices : function(component,event){
        var qty = event.getSource().get("v.value");
        var pprId = event.getSource().get("v.ariaDescribedBy");
        console.log('pprId ' + JSON.stringify(pprId));
        component.set(pprId.BasePrice,4);
        //if(pprId != ''){} 
    }
   */
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