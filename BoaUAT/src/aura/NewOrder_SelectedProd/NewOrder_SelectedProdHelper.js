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
        
        accDetails.onboardingStartDate = createOrder.onboardingStartDate;
        accDetails.onboardingCloseDate = createOrder.onboardingCloseDate;
        accDetails.onboardingContact = createOrder.onboardingContact;
        
        var allSelectedProducts = component.get("v.stockItemList");
        //console.log('Test order prod ' + JSON.stringify(allSelectedProducts));
        var orderProductDetails = [];
        for(var g = 0 ; g < allSelectedProducts.length ; g++){   
            //console.log('pricingPolicyPrice ' + allSelectedProducts[g].pricingPolicyPrice);
            //console.log('quantity ' + allSelectedProducts[g].quantity);
            if(allSelectedProducts[g].quantity == '' || allSelectedProducts[g].quantity == 0){
                //alert('Please enter a non-zero quantity for ' + allSelectedProducts[g].stockCode);     
                alertify.alert('Please enter a non-zero quantity in stock items').setHeader('').set('movable', false);
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].UnitPrice == '' || allSelectedProducts[g].UnitPrice == 0){
                //alert('Unit price for ' + allSelectedProducts[g].stockCode + ' is zero');     
                alertify.alert('Unit price for ' + allSelectedProducts[g].stockCode + ' is zero').setHeader('').set('movable', false);
                sendOrderDetails = false;
                component.set("v.showSpinner",false);
                break;
            }
            if(allSelectedProducts[g].BasePrice == '' || allSelectedProducts[g].BasePrice == 0){
                //alert('Please enter a non-zero sales price for ' + allSelectedProducts[g].stockCode);     
                alertify.alert('Please enter a non-zero sales price in stock items').setHeader('').set('movable', false);
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
                
                if((allSelectedProducts[g].pricingPolicyRuleId != '') && (allSelectedProducts[g].quantity != allSelectedProducts[g].pricingPolicyquantity)){
                    //console.log('Test1 ' + allSelectedProducts[g].pricingPolicyPrice);
                    //orderProductDetail.UnitPrice = allSelectedProducts[g].pricingPolicyPrice;
                    orderProductDetail.UnitPrice = allSelectedProducts[g].BasePrice;
                }
                else if((allSelectedProducts[g].pricingPolicyRuleId) != '' && (allSelectedProducts[g].quantity == allSelectedProducts[g].pricingPolicyquantity)){
                    //console.log('Test2 ' + allSelectedProducts[g].BasePrice);
                    orderProductDetail.UnitPrice = allSelectedProducts[g].BasePrice;                   
                }
                    else if(allSelectedProducts[g].pricingPolicyRuleId == ''){
                        //console.log('Test3 ' + allSelectedProducts[g].BasePrice);
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
        
        //console.log('Order Details1 ' + JSON.stringify(orderProductDetails));
        //console.log('Order Details2 ' + JSON.stringify(orderProductDetails));
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
                    /*
                    if(resp.emptyOrderProd){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.emptyOrderProd,'info');
                    }
                    if(resp.remainingCreditBalanceError){
                        component.set("v.showSpinner",false);
                        this.showErrorToast(component,resp.remainingCreditBalanceError,'info');
                    }
                    */
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
                    component.set("v.showSpinner",false);
                    this.showErrorToast(component,'An error occurred.Please contact your Administrator','error');
                }
                    else if (state === "ERROR") {
                        component.set("v.showSpinner",false);
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                //console.log("Error message: " + errors[0].message);
                                this.showErrorToast(component,errors[0].message,'error');
                            }
                        } 
                        else {
                            //console.log("Unknown error");
                            this.showErrorToast(component,'An unknown error occurred.Please contact your Administrator','error');
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
    }, 
    prodQtyDetails : function(component,event){
        var action = component.get("c.prodQtyDetailsForLocation");            
        action.setParams
        ({
            "productId" : component.get("v.currentProdId"),
            "oppDefaultLocation" : event.getParam('oppDefaultLocation')
        });        
        action.setCallback(this, function(response) {
            component.set("v.currentProdId","");
            var state = response.getState();
            if (state === "SUCCESS") {                   
                var resp = JSON.parse(response.getReturnValue());
                console.log('resp',resp.success);
                if(resp.success === '' || resp.success === 'no_details_available'){                    
                    //alertify.alert('No details available').setHeader('Quantity Details').set('movable', false);                                    	
                    //alertify.set('notifier','position', 'bottom-right');
                    //alertify.error('No details available');
                    return;
                }
                if(resp.success === 0){                    
                    //alertify.alert('Out of stock.Please check availability in other locations').setHeader('Quantity Details').set('movable', false);                                   	
                    alertify.set('notifier','position', 'bottom-right');
                    alertify.error('Out of stock.Please check availability in other locations');
                }
                if(resp.error){
                    this.showErrorToast(component,resp.error,'error');
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
                    } else {
                        this.showErrorToast(component,'An unknown error occurred.Please contact your Administrator','error');
                    }
                    
                }
        });
        
        $A.enqueueAction(action);
        
    },  
  /*     
    newProductPrices : function(component,event){
        var qty = event.getSource().get("v.value");
        var pprId = event.getSource().get("v.ariaDescribedBy");
        //console.log('pprId ' + JSON.stringify(pprId));
        component.set(pprId.BasePrice,4);
        //if(pprId != ''){} 
    },
    
    navigateToOrder : function(component,recId){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+recId
        });
        urlEvent.fire();
    }
 */
    createObjectData: function(component, event, createObjectType) {
        var orderEditStockList = component.get("v.selectedProducts");
        if(orderEditStockList.length === 0 || createObjectType === 'newStock'){
            var RowItemList = component.get("v.stockItemList");
            RowItemList.push({
                'Id':'',
                'productId':'',
                'stockCode':'',
                'quantity':'1',
                'priceGroup': '',
                'stockDescription':'',
                'UnitPrice':0,
                'discount':0,
                'BasePrice':0,
                'fullCoilSize':'',
                'prevCoilDiscStat':false,           
                'pricingPolicyPrice':'',
                'pricingPolicyRuleId': '',
                'pricingPolicyquantity': '',
                'fullCoilSizeDiscount': 0,
                'productAlert':null
            });
            component.set("v.stockItemList", RowItemList);
        }
        else{
            component.set("v.stockItemList", JSON.parse(component.get("v.selectedProducts")));
        }        
        component.set("v.searchedstockItemList",[]);
    },
    searchProductHelper: function(component, searchTerm) {
        var action = component.get("c.productSearch");
        action.setParams({
            "accId" : component.get("v.accountIdProductList"),
            "searchString" : searchTerm
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {          
                var storeResponse = JSON.parse(response.getReturnValue());
                if(storeResponse.error){                    
                    //console.log('error');
                    this.showErrorToast(component,storeResponse.error,'error');
                }
                else{
                    component.set("v.searchedstockItemList",storeResponse);
                }                
            }            
            else if (state === "INCOMPLETE") {
                //console.log('error');
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
    selectedStockPrices: function(component,event,stockItemIndex){
        var selectedItem = event.currentTarget;        
        var stockItemIndex = selectedItem.dataset.index;
        var searchResults = document.getElementById(stockItemIndex);  
        $A.util.addClass(searchResults,"displaySearchResults"); 
        
        var stockSel = component.get("v.stockItemList");
        for(var i = 0; i < stockSel.length; i++){            
            if(stockSel[i].stockCode == selectedItem.title){
                var retVal = confirm("Stock item " + stockSel[i].stockCode + " already exists. Do you want to continue ?");
                if( retVal === false ){
                    return;
                }
            }
        }
        
        stockSel[stockItemIndex].Id = selectedItem.dataset.record;
        stockSel[stockItemIndex].productId = selectedItem.dataset.productid;
        stockSel[stockItemIndex].stockCode = selectedItem.title;
        stockSel[stockItemIndex].isBOM = selectedItem.dataset.isbom;
        stockSel[stockItemIndex].sbom = [];
        stockSel[stockItemIndex].hideBOMItems = 'true';
        
        var action = component.get("c.productPriceForPolicy");
        action.setParams({
            "accId" : component.get("v.accountIdProductList"),
            "selectedProd": JSON.stringify(stockSel[stockItemIndex])
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var storeResponse = JSON.parse(response.getReturnValue());
                //console.log('storeResponse ' + JSON.stringify(storeResponse));
                
                if(storeResponse.error){                    
                    //console.log('error');
                    this.showErrorToast(component,storeResponse.error,'error');
                }
                else{
                    if(storeResponse.productAlert != null){
                        alertify.alert(storeResponse.productAlert).setHeader('Stock Item Info').set('movable', false);
                    }
                    
                    stockSel[stockItemIndex] = storeResponse;
                    component.set("v.stockItemList",stockSel);
                    component.set("v.searchedstockItemList",[]);
                    component.set("v.currentProdId",selectedItem.dataset.productid);
                    var accountLoc = $A.get("e.c:NewOrder_SelectedProdToAcctDetails");
                    accountLoc.fire();
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
    }
    
})