({
    doInit : function(component, event, helper) {
        //component.set("v.allSelectedProducts",component.get("v.selectedProducts"));
        component.set("v.stockItemList", []);	
        helper.createObjectData(component, event, '');
    },
    handleSelectedProducts : function(component, event, helper) {
        var sp = component.get("v.selectedProducts");
        console.log('selected price' + sp.length);	
        if(sp.length > 0){            
            var l = JSON.parse(sp);
            console.log('sp ' + JSON.stringify(l));
            var allSp = component.get("v.allSelectedProducts");
            
            for(var i = 0, len = allSp.length; i < len; i++){            
                for(var j = 0, len2 = l.length; j < len2; j++){
                    if(allSp[i].stockCode === l[j].stockCode){
                        var retVal = confirm("Stock item " + l[j].stockCode + " already exists. Do you want to continue ?");
                        if( retVal === false ){
                            l.splice(sp[j],1);
                            len2=l.length;
                        }                       
                    }                      
                }           
            }
            
            for(var k = 0; k < l.length;  k++){           
                allSp.push(l[k]);
            }
            
            component.set("v.allSelectedProducts",allSp);
            //console.log('stockcode' + JSON.stringify(component.get("v.allSelectedProducts")));
        }
        else{
            component.set("v.allSelectedProducts",[]);
        }
    },
    handleRemoveProduct : function(component, event, helper) {
        var productId = event.getSource().get("v.value");
        var allSelProd = component.get("v.allSelectedProducts");
        var allSelProdLength = allSelProd.length;
        for(var d = 0; d < allSelProdLength; d++){
            if(allSelProd[d].Id == productId){
                allSelProd.splice(d,1);
                break;
            }
        }
        
        component.set("v.allSelectedProducts",allSelProd);
        
    },
    /*
    saveprod : function(component, event, helper) {
        var allSProd = component.get("v.allSelectedProducts");
        var allSProdLength = allSProd.length;
        for(var p = 0; p < allSProdLength; p++){
            alert(allSProd[p].quantity);
        }
    },
    calculateTotalAmt : function(component, event, helper) {
        component.set("v.updateTotal",!component.get("v.updateTotal"));
    },
    calculateTotal : function(component, event, helper) {
        var sourceCl = event.getSource().get("v.class").split('-')[1];
        var sourceQtyVal = event.getSource().get("v.value");
        
        var unitP = document.getElementById("utPrice-"+ sourceCl).innerHTML;
        console.log('Unit price ' + unitP);
        
        var qtyVal = document.getElementById("qty-"+ sourceCl).innerHTML;
        console.log('Unit price ' + unitP);
        
        var totalVal = parseInt(unitP) + parseInt(qtyVal);
        document.getElementById("total-"+sourceCl).innerHTML = totalVal
        
        //console.log(event.getSource().get("v.class"));
        //console.log(f);  
        //var totalVal = parseInt(document.getElementById("total-"+cl).innerHTML) + parseInt(qtyVal);
        //document.getElementById("total-"+cl).innerHTML = totalVal
        //console.log("totalVal " + totalVal); 
        
        //var total = component.find(f+'-'+'total');
        //var totalVal = total + e;
        //component.set(total,totalVal);  
    },
    */
    handleCreateOrder : function(component, event, helper) {
        var allSelectedProducts = component.get("v.stockItemList");
        if(allSelectedProducts.length == 1 && allSelectedProducts[0].Id == ''){
            alertify.alert('Order cannot be created without stock item/s').setHeader('No order items').set('movable', false);
            return;
        }
        else{
            helper.createOrderHelper(component,event);    
        }        
    },
    addNewRow: function(component, event, helper) {
        component.set("v.searchedstockItemList",[]);
        helper.createObjectData(component, event, 'newStock');
    },
    removeDeletedRow: function(component, event, helper) {
        var index = event.getSource().get("v.ariaLabel");
        //console.log('index ' + index);
        var allRowsList = component.get("v.stockItemList");
        for(var d = 0; d < allRowsList.length; d++){
            if(allRowsList[d].stockCode == index){
                allRowsList.splice(d,1);
                break;
            }
        }
        component.set("v.stockItemList", allRowsList);
        component.set("v.searchedstockItemList",[]);
    },
    searchProducts: function(component, event, helper) {
        var searchTerm = event.getSource().get("v.value");
        if(searchTerm.length === 0){
            component.set("v.searchedstockItemList",[]);
            return;
        }
        var currentStockInput = event.getSource().get("v.ariaLabel");
        var searchResults = document.getElementById(currentStockInput);    
        $A.util.removeClass(searchResults,"displaySearchResults"); 
        
        var allRowsList = component.get("v.stockItemList");
        for(var d = 0; d < allRowsList.length; d++){
            if(d != currentStockInput){
                var searchResults = document.getElementById(d);    
                $A.util.addClass(searchResults,"displaySearchResults"); 
            }
        }
        helper.searchProductHelper(component,searchTerm);
    },
    selectedStock: function(component, event, helper) {
        helper.selectedStockPrices(component,event);        
    }
    /*
    updateStockItem : function(component, event, helper) {
        helper.newProductPrices(component,event);
    }
    */
})