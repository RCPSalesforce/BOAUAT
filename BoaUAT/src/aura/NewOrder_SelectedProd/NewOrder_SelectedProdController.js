({
    doInit : function(component, event, helper) {
        //component.set("v.showCreateHose",true);
        //component.set("v.allSelectedProducts",component.get("v.selectedProducts"));
        component.set("v.stockItemList", []);
        helper.createObjectData(component, event, '');
    },
    handleSelectedProducts : function(component, event, helper) {
        var sp = component.get("v.selectedProducts");
        //console.log('sp ' + sp);	
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
    /*
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
    */
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
            //helper.createOrderHelper(component, event, 'newStock');
            helper.createOrderHelper(component, event);    
        }        		
    },
 /*
    handleProductQtyDetails : function(component, event, helper) {
        var prodId = event.getSource().get("v.value");
        component.set("v.currentProdId",prodId);
        //console.log('prodId' + prodId);
        
        //var accountLoc = $A.get("e.c:NewOrder_SelectedProdToAcctDetails");
        //accountLoc.fire();
        helper.prodQtyDetails(component, event);
    },
*/
    handleAcctToSelectedProd : function(component, event, helper) {
        helper.prodQtyDetails(component, event);
    },
 /*
    updateStockItem : function(component, event, helper) {
        helper.newProductPrices(component,event);
    },
 */  
    calculateDiscount : function(component, event) {
        var prodQty = parseInt(event.getSource().get("v.value"));
        var allProducts = component.get("v.stockItemList");
        //console.log('prodQty ' + prodQty);
        
        var selProdIndex = event.getSource().get("v.ariaLabel");
        //console.log('selProdIndex ' + selProdIndex);
        
        var selectedProdDetail = allProducts[selProdIndex];
        //console.log('selectedProdDetail' + JSON.stringify(selectedProdDetail));
        /*
         if(selectedProdDetail.pricingPolicyRuleId != ""){
            if(selectedProdDetail.quantity != selectedProdDetail.pricingPolicyquantity){
                selectedProdDetail.discount = 50;
                allProducts[selProdIndex] = selectedProdDetail;
                component.set("v.stockItemList",allProducts);
            }
        }
        */
        if(selectedProdDetail.pricingPolicyRuleId == "" && selectedProdDetail.fullCoilSize != null){
            console.log('discount');
            var fullCoilSizeList = selectedProdDetail.fullCoilSize.split(",");
            var fullCoilSizeDiscount = selectedProdDetail.fullCoilSizeDiscount === null ? 0 : selectedProdDetail.fullCoilSizeDiscount;
            for(var n = 0; n < fullCoilSizeList.length; n++){
                console.log('fullCoilSizeList ' + fullCoilSizeList[n]);
                var fullCoilSize = parseInt(fullCoilSizeList[n]);
                var prodMultipleRemainder = prodQty % fullCoilSize
                //var boxCoilDiscount = selectedProdDetail.fullBoxCoilPercent == null ? 0 : parseFloat(selectedProdDetail.fullBoxCoilPercent);
                if(((prodQty == fullCoilSize || prodMultipleRemainder == 0) && selectedProdDetail.prevCoilDiscStat == false)){
                    selectedProdDetail.discount = parseFloat(selectedProdDetail.discount) + parseFloat(fullCoilSizeDiscount); // change hardcoded percentage 
                    if(selectedProdDetail.discount <= 100){
                        selectedProdDetail.prevCoilDiscStat = true;                
                        allProducts[selProdIndex] = selectedProdDetail;
                        component.set("v.stockItemList",allProducts);
                        //console.log('val changed ' + allProducts[selProdIndex].prevCoilDiscStat);
                        break;
                    }
                    
                }
                else if((prodQty != fullCoilSize) && selectedProdDetail.prevCoilDiscStat == true){
                    selectedProdDetail.discount = parseFloat(selectedProdDetail.discount) - parseFloat(fullCoilSizeDiscount);
                    selectedProdDetail.prevCoilDiscStat = false;
                    allProducts[selProdIndex] = selectedProdDetail;
                    //console.log('val changed2 ');
                    component.set("v.stockItemList",allProducts);
                    break;
                }
            }        
        }
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
        /* 
         var stockName = event.getSource().get("v.ariaLabel");
        var allRowsList = component.get("v.stockItemList");
        for(var d = 0; d < allRowsList; d++){
            console.log('stocklist ' + allRowsList[d].stockItem);
            if(allRowsList[d].stockItem == stockName){
                allRowsList.splice(d,1);
                break;
            }
        }
       component.set("v.stockItemList", allRowsList);   
        console.log('index ' + index);
        var allRowsList = component.get("v.stockItemList");
        allRowsList.splice(index, 1);
        component.set("v.stockItemList", allRowsList);
        */
    },
    toggleContent : function(component, event, helper) {
        var buttonId = event.target.id;
        console.log('buttonId ' + buttonId);
        var secDetails = document.getElementById(buttonId);
        $A.util.toggleClass(secDetails,"slds-is-open");
        
        //var secDetails = component.find("section1");
        //console.log('secDetails ' + secDetails);
        //secIcon = secIcon == "utility:chevronright" ? "utility:switch" : "utility:chevronright"; 
        
        /*var secIcon = component.get("v.section1Icon");
        var secDetails = component.find("section1");
        console.log('secDetails ' + secDetails);
        secIcon = secIcon == "utility:chevronright" ? "utility:switch" : "utility:chevronright";
        component.set("v.section1Icon",secIcon);
        $A.util.toggleClass(secDetails,"slds-is-open");
        */
        
    }
})