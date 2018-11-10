({
    fetchData: function (component) {
        console.log('fetchData');
        var accountIdProductList = component.get("v.accountIdProductList");   
        //console.log('accountIdProductList ' + accountIdProductList);
        if(accountIdProductList != '' && accountIdProductList != null){
            //alert('accountIdProductList ' + accountIdProductList);
            var action = component.get("c.poPriceBookDataWithoutSearch");
            action.setParams({
                "accId" : accountIdProductList
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = JSON.parse(response.getReturnValue());   
                    if(resp.error){
                        // show error toast
                        showErrorToast(component,resp,error,'error');
                    }
                    else{
                        //console.log("Response " + response.getReturnValue());
                        resp = JSON.stringify(resp);            
                        var prodList = JSON.parse(resp);
                        console.log('prodList ' + JSON.stringify(prodList));
                        if(prodList.length > 0){
                            for (var i = 0; i < prodList.length; i++) {
                                var row = prodList[i];
                                row.stockCode = row.Product2.Name;
                                row.StockCodeUrl = row.Product2.Stock_Item_Url__c;
                                //console.log('StockCode ' + row.Product2.Stock_Item_Url__c);
                                row.stockDescription = row.Product2.ProductCode;
                            }
                            
                            component.set('v.productColumns', [
                                /*{label: 'Stock Code', fieldName: 'stockCode', type: 'text'},*/	
                                {label: 'stockcode', fieldName: 'StockCodeUrl', type: 'url',typeAttributes: {label: { fieldName: 'stockCode'}}},
                                {label: 'Stock Description', fieldName: 'stockDescription', type: 'text'},	           
                                {label: 'Sales Price', fieldName: 'UnitPrice', type: 'currency'}	            
                            ]);
                            
                            component.set("v.productData",prodList);
                            //console.log('Product Data ' + JSON.stringify(prodList));
                            component.set("v.showProductList",true);
                            component.set("v.showProductListError",false);
                            component.set("v.productListCount",false);
                        }
                        else{
                            component.set("v.productListCount",true); 
                            component.set("v.showProductList",false);
                            component.set("v.showProductListError",false);
                        }
                    }
                }
                else if (state === "INCOMPLETE") {
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                
                            }
                        } 
                        else {
                        }
                    }
                
            });
            $A.enqueueAction(action); 	
        }
        else{
            component.set("v.showProductListError",true);
            component.set("v.showProductList",false);
            component.set("v.productListCount",false); 
        }
    },
    /*  
    updateProduct: function (component,event) {
        var draftValues = event.getParam('draftValues');
        //console.log(draftValues);
        var action = component.get("c.productUpdate");
        action.setParams({"productList" : draftValues});
        action.setCallback(this,function(response){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type":"success",
                "message": response.getReturnValue() + " products have been updated successfully."
            });
            toastEvent.fire();
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);               
    }
  */  
    searchProductHelper: function(component, event) {
        // show spinner message
        //component.find("Id_spinner").set("v.class" , 'slds-show');
        var accountIdProductList = component.get("v.accountIdProductList"); 
        var action = component.get("c.poPriceBookDataWithSearch");
        action.setParams({
            "searchString": component.get("v.searchKeyword"),
            "accId" : accountIdProductList
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            //component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = JSON.parse(response.getReturnValue());   
                if(resp.error){
                    // show error toast
                    showErrorToast(component,resp,error,'error');
                }
                else{
                    //console.log("Response " + response.getReturnValue());
                    resp = JSON.stringify(resp); 
                    //console.log("Response " + response.getReturnValue());
                    var prodList = JSON.parse(resp);
                    if (prodList.length == 0) {
                        component.set("v.searchedProductSize", true);
                        component.set("v.productData",{});
                    } 
                    else {
                        component.set("v.searchedProductSize", false);
                    }
                    //console.log('prodList ' + JSON.stringify(prodList));
                    if(prodList.length > 0){
                        for (var i = 0; i < prodList.length; i++) {
                            var row = prodList[i];
                            row.stockCode = row.Product2.Name;
                            row.StockCodeUrl = row.Product2.Stock_Item_Url__c;
                            //console.log('StockCode ' + row.Product2.Stock_Item_Url__c);
                            row.stockDescription = row.Product2.ProductCode;
                        }
                        component.set("v.productData",prodList);
                    }
                }
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } 
                    else {
                    }
                }
        });
        $A.enqueueAction(action);
    },
    newProductPrices: function(component,prodSelected){
        //console.log('required products ' + JSON.stringify(prodSelected));
        // JSON with only required fields
        component.set("v.showSpinner",true);
        //var prodWithRequiredFields = [];
        var prodSelectedlength = prodSelected.length;
        var prodWithRequiredFields = [];
        for(var i = 0; i < prodSelectedlength; i++){
            var prod = {};
            prod.Id = prodSelected[i].Id;
            prod.productId = prodSelected[i].Product2.Id;
            prod.stockCode = prodSelected[i].Product2.Name;
            prod.stockDescription = prodSelected[i].Product2.ProductCode;
            prod.orderedQuantity = prodSelected[i].orderedQuantity;
            prod.quantity = prodSelected[i].quantity;
            prod.UnitPrice = prodSelected[i].UnitPrice;
            prod.packPrice = prodSelected[i].packPrice;
            prod.discount = prodSelected[i].discount;
            prod.supplierCode = prodSelected[i].supplierCode;
            prodWithRequiredFields.push(prod);
        }
        
        //console.log('formatted required products' + JSON.stringify(prodWithRequiredFields));
        var accountIdProductList = component.get("v.accountIdProductList"); 
        //console.log('accid ' + accountIdProductList); 
        var action = component.get("c.productPriceForPurchaseOrder");
        action.setParams({
            "accId" : accountIdProductList,
            "selectedProdList" : JSON.stringify(prodWithRequiredFields)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                 var resp = response.getReturnValue();
                console.log('purchase order prod ' + JSON.stringify(resp));
                component.getEvent("selectedProductEvent").setParams({"prodSelected":resp}).fire();
                component.find("searchField").set("v.value","");
                component.set("v.productData",{});
                component.set("v.selectedProducts",[]);
                this.fetchData(component);
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } 
                    else {
                    }
                }
        });
        $A.enqueueAction(action);       
        
    },
    showErrorToast : function(component,error,msgtype) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Following error occurred',
            message: error,
            type: msgtype
        });
        toastEvent.fire();
    }
})