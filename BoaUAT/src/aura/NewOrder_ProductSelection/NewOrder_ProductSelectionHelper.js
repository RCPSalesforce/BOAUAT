({
    fetchData: function (component) {
        console.log('fetchData');
        var accountIdProductList = component.get("v.accountIdProductList");       
        if(accountIdProductList != '' && accountIdProductList != null){
            //alert('accountIdProductList ' + accountIdProductList);
            var action = component.get("c.priceBookData");
            action.setParams({
                "accId" : accountIdProductList
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = JSON.parse(response.getReturnValue());
                    if(resp.requiredFieldMissing){
                        this.showErrorToast(component,resp.requiredFieldMissing,'info');
                        return;
                    }
                    if(resp.error){                    
                        this.showErrorToast(component,resp.error,'error');
                        return;
                    }
                    else{
                        //console.log("Response " + response.getReturnValue());
                        resp = JSON.stringify(resp);
                        var basePrice = JSON.parse(resp)[0];
                        basePrice = basePrice.replace(/^"(.*)"$/, '$1');
                        switch (basePrice) {
                            case "retail":
                                basePrice = "Retail_Price__c";
                                break;
                            case "contractor":
                                basePrice = "Contractor_Price__c";
                                break;
                            case "trade":
                                basePrice = "Trade_Price__c";
                                break;
                            case "wholesale":
                                basePrice = "Wholesale_Price__c";
                                break;
                            case "dealer":
                                basePrice = "Dealer_Price__c";
                                break;
                            case "bulk buy":
                                basePrice = "Bulk_Buy_Price__c";
                                break;
                            default: 
                                basePrice = "UnitPrice";      
                                break;
                        }
                        var prodList = JSON.parse(JSON.parse(resp)[1]);
                        //console.log('prodList ' + JSON.stringify(JSON.parse(prodList)));
                        
                        if(prodList.length > 0){
                            for (var i = 0; i < prodList.length; i++) {
                                var row = prodList[i];
                                if (row.Product2){
                                    row.stockCode = row.Product2.Name;
                                    row.StockCodeUrl = row.Product2.Stock_Item_Url__c;
                                    //console.log('StockCode ' + row.Product2.Stock_Item_Url__c);
                                    row.stockDescription = row.Product2.ProductCode;
                                    
                                    switch (basePrice) {
                                        case "Retail_Price__c":                                    
                                            row.basePrice = row.Retail_Price__c;
                                            break;
                                        case "Contractor_Price__c":
                                            row.basePrice = row.Contractor_Price__c;
                                            break;
                                        case "Trade_Price__c":
                                            row.basePrice = row.Trade_Price__c;
                                            break;
                                        case "Wholesale_Price__c":
                                            row.basePrice = row.Wholesale_Price__c;
                                            break;
                                        case "Dealer_Price__c":
                                            row.basePrice = row.Dealer_Price__c;
                                            break;
                                        case "Bulk_Buy_Price__c":
                                            row.basePrice = row.Bulk_Buy_Price__c;
                                            break;
                                        default: 
                                            row.basePrice = row.UnitPrice; 
                                            break;
                                    }                             
                                    
                                }
                            }
                            
                            /*
                            component.set('v.productColumns', [
                                //{label: 'Stock Code', fieldName: 'stockCode', type: 'text'},	
                                {label: 'stockcode', fieldName: 'StockCodeUrl', type: 'url',typeAttributes: {label: { fieldName: 'stockCode'}}},
                                {label: 'Stock Description', fieldName: 'stockDescription', type: 'text'},	           
                                {label: 'Sales Price', fieldName: basePrice, type: 'currency'}	            
                            ]);
                            */
                            
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
                            if (errors[0] && errors[0].message) {}
                        } 
                        else {}
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
    },
    */
    searchProductHelper: function(component, event) {
        // show spinner message
        //component.find("Id_spinner").set("v.class" , 'slds-show');
        var accountIdProductList = component.get("v.accountIdProductList"); 
        var action = component.get("c.productSearch");
        action.setParams({
            "searchString": component.get("v.searchKeyword"),
            "accId" : accountIdProductList
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            //component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = JSON.parse(response.getReturnValue());
                
                if(storeResponse.error){                    
                    this.showErrorToast(component,resp.error,'error');
                }
                else{
                    storeResponse = JSON.stringify(storeResponse);
                    var basePrice = JSON.parse(storeResponse)[0];
                    basePrice = basePrice.replace(/^"(.*)"$/, '$1');
                    switch (basePrice) {
                        case "retail":
                            basePrice = "Retail_Price__c";
                            break;
                        case "contractor":
                            basePrice = "Contractor_Price__c";
                            break;
                        case "trade":
                            basePrice = "Trade_Price__c";
                            break;
                        case "wholesale":
                            basePrice = "Wholesale_Price__c";
                            break;
                        case "dealer":
                            basePrice = "Dealer_Price__c";
                            break;
                        case "bulk buy":
                            basePrice = "Bulk_Buy_Price__c";
                            break;
                        default: 
                            basePrice = "UnitPrice";  
                            break;
                    }
                    
                    var prodList = JSON.parse(JSON.parse(storeResponse)[1]);
                    
                    // if storeResponse size is 0 ,display no record found message on screen.
                    if (prodList.length == 0) {
                        component.set("v.searchedProductSize", true);
                    } else {
                        component.set("v.searchedProductSize", false);
                    }
                    if (prodList.length > 0){
                        // set searchResult list with return value from server.
                        for (var i = 0; i < prodList.length; i++) {
                            var row = prodList[i];
                            if (row.Product2){
                                row.stockCode = row.Product2.Name;
                                row.StockCodeUrl = row.Product2.Stock_Item_Url__c;
                                //console.log('StockCode ' + row.Product2.Stock_Item_Url__c);
                                row.stockDescription = row.Product2.ProductCode;
                                
                                switch (basePrice) {
                                    case "Retail_Price__c":                                    
                                        row.basePrice = row.Retail_Price__c;
                                        break;
                                    case "Contractor_Price__c":
                                        row.basePrice = row.Contractor_Price__c;
                                        break;
                                    case "Trade_Price__c":
                                        row.basePrice = row.Trade_Price__c;
                                        break;
                                    case "Wholesale_Price__c":
                                        row.basePrice = row.Wholesale_Price__c;
                                        break;
                                    case "Dealer_Price__c":
                                        row.basePrice = row.Dealer_Price__c;
                                        break;
                                    case "Bulk_Buy_Price__c":
                                        row.basePrice = row.Bulk_Buy_Price__c;
                                        break;
                                    default: 
                                        row.basePrice = row.UnitPrice;                        
                                }
                                
                            }
                        }
                        component.set("v.productData",prodList);
                    }
                    else{
                        component.set("v.productData",{});
                    }
                    /*
                component.set('v.productColumns', [
                    {label: 'Stock Code', fieldName: 'stockCode', type: 'text'},	
                    {label: 'stockcode', fieldName: 'StockCodeUrl', type: 'url',typeAttributes: {label: { fieldName: 'stockCode'}}},
                    {label: 'Stock Description', fieldName: 'stockDescription', type: 'text'},	           
                    {label: 'Sales Price', fieldName: basePrice, type: 'currency'}	            
                ]);
                */
                    
                    //console.log('Product Data Search' + JSON.stringify(prodList));
                } 
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {}
                    } 
                    else {}
                }
        });
        $A.enqueueAction(action);
    },
    newProductPrices: function(component,prodSelected){
        console.log('required products ' + JSON.stringify(prodSelected));
        // JSON with only required fields
        component.set("v.showSpinner",true);
        //var prodWithReuiredFields = [];
        var prodSelectedlength = prodSelected.length;
        var prodWithRequiredFields = [];
        for(var i = 0; i < prodSelectedlength; i++){
            var prod = {};
            prod.Id = prodSelected[i].Id;
            prod.productId = prodSelected[i].Product2.Id;
            prod.stockCode = prodSelected[i].Product2.Name;
            prod.quantity = prodSelected[i].quantity;
            prod.UnitPrice = prodSelected[i].UnitPrice;
            prod.discount = prodSelected[i].discount;
            prod.basePrice = prodSelected[i].basePrice;
            prod.priceGroup = prodSelected[i].Product2.Price_Group__c;
            prod.stockDescription = prodSelected[i].Product2.ProductCode;
            prod.pricingPolicyPrice = prodSelected[i].basePrice; // additional
            prod.pricingPolicyRuleId = ''; // additional
            prod.pricingPolicyquantity = prodSelected[i].quantity; // additional
            prod.fullCoilSize = prodSelected[i].Product2.Full_Coil_Size_metre__c;
            prod.prevCoilDiscStat = false;
            //prod.fullBoxCoilPercent = prodSelected[i].Product2.Full_Box_Coil_Percent__c;
            prodWithRequiredFields.push(prod);
        }
        
        console.log('required products ' + JSON.stringify(prodWithRequiredFields));
        var accountIdProductList = component.get("v.accountIdProductList"); 
        var action = component.get("c.productPriceForPolicy");
        action.setParams({
            "accId" : accountIdProductList,
            "selectedProdList" : JSON.stringify(prodWithRequiredFields)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = JSON.parse(response.getReturnValue());
                if(resp.error){                    
                    this.showErrorToast(component,resp.error,'error');
                }
                else{
                    resp = JSON.stringify(resp);
                    component.set("v.showSpinner",false);
                    component.set("v.selectedProducts",resp);
                    component.getEvent("selectedProductEvent").setParams({"prodSelected":resp}).fire();
                    component.find("searchField").set("v.value","");
                    component.set("v.productData",{});
                    component.set("v.selectedProducts",[]);
                    this.fetchData(component);
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