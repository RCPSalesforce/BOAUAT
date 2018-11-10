({
    init: function (component, event, helper) {
        helper.fetchData(component);
    },
    handleChangedAccountId: function (component, event, helper) {
        helper.fetchData(component);
    },
  /*  
    updateProduct: function(component, event, helper) {
        //helper.updateProduct(component,event);  
    }
  */
    getSelectedRows: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        
        //var prevselectedRows = component.get("v.selectedProducts");
        //console.log('selectedRows ' + JSON.stringify(selectedRows));
        //console.log('prevselectedRows ' + JSON.stringify(prevselectedRows));
        // Display that fieldName of the selected rows
         //for (var i = 0; i < selectedRows.length; i++){
                //if(selectedRows[i].Product2.pop_up_alert__c !== 'NULL'){
                    //alertify.alert(selectedRows[i].Product2.pop_up_alert__c).setHeader('Stock Item Info').set('movable', false);
                //}
            //}  
            
         var allSelectedProd = component.get("v.selectedProducts");
        var l = selectedRows;
        if(allSelectedProd.length > 0){
            console.log('second' + allSelectedProd.length);
            console.log('selectedrowslength ' + l.length);
            for(var i = 0, len = allSelectedProd.length; i < len; i++){            
                for(var j = 0, len2 = l.length; j < len2; j++){
                    if(allSelectedProd[i].Name === l[j].Name){
                        l.splice(selectedRows[j],1);
                        len2=l.length;                     
                    }                      
                }           
            }
            
            for(var k = 0; k < l.length;  k++){  
                console.log('test');
                allSelectedProd.push(l[k]);
            }
            console.log('third' + allSelectedProd.length);
            component.set("v.selectedProducts",allSelectedProd); 
        }
        else{
            console.log('first');
            component.set("v.selectedProducts",selectedRows); 
        }
         
        console.log('selectedRows ' + JSON.stringify(component.get("v.selectedProducts")));
		
        //component.set("v.selectedProducts",[]);
    },
    handleRemoveOnly : function(component, event){
        var removeItem = event.getSource().get("v.name");
        console.log('removeItem ' + removeItem);
        var selectedProd = component.get("v.selectedProducts");
        //console.log('selectedProd ' + JSON.stringify(selectedProd));
        for(var i = 0 ; i < selectedProd.length ; i++){ 
            if(selectedProd[i].Id == removeItem){
                var index = selectedProd.indexOf(selectedProd[i]);
                if (index > -1) {
                    var prodStat = document.getElementById(selectedProd[i].Id);
                    if(prodStat !== null){
                        document.getElementById(selectedProd[i].Id).checked = false;
                    }
                    selectedProd.splice(index, 1);                   
                }
            }
        }
        component.set("v.selectedProducts",selectedProd);
    },
    selectedVal : function(component, event){
        var prodClicked = event.target.checked;
        var f = event.target.value;
        var prodData = component.get("v.productData");
        var selectedProd = component.get("v.selectedProducts");
        if(prodClicked === true){
            selectedProd.push(prodData[f]);
        }
        if(prodClicked === false){
            var index = selectedProd.indexOf(prodData[f]);
            if (index > -1) {
                selectedProd.splice(index, 1);
            }
        }
        component.set("v.selectedProducts",selectedProd);
    },
    searchProducts: function(component, event, helper) {
        helper.searchProductHelper(component);
    },
    addSelectedProducts: function(component, event, helper) {
        var prodSelected = component.get("v.selectedProducts");
        console.log('prodSelected ' + component.get("v.accountIdProductList"));
        if(prodSelected.length > 0){
            var prodSelectedlength = prodSelected.length; 
            var allProductAlerts = '';
            for(var i = 0; i < prodSelectedlength; i++){
                if(prodSelected[i].Product2.pop_up_alert__c != "NULL" && prodSelected[i].Product2.pop_up_alert__c != undefined){
                    allProductAlerts += '<br/>Stock Item: <b>' + prodSelected[i].Name + '</b><br/> Message : <b>'+ prodSelected[i].Product2.pop_up_alert__c +'</b><br/>';
                }
                prodSelected[i].quantity = 1;
                prodSelected[i].discount = 0;
            }
                      
            
            if(allProductAlerts != '' && allProductAlerts != 'NULL'){
                alertify.alert(allProductAlerts).setHeader('Stock Item Info').set('movable', false);
            }      
            
            // call apex class
            helper.newProductPrices(component,prodSelected);
            // update prodSelected
            // send details to selected products component
            //component.getEvent("selectedProductEvent").setParams({"prodSelected":prodSelected}).fire();
        }
        else{
            alert('Please select a product to add');
        }
        
    }
})