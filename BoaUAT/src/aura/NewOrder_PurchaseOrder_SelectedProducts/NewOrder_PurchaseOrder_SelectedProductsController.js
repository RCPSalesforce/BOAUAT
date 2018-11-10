({
    doInit : function(component, event, helper) {
        component.set("v.allSelectedProducts",component.get("v.selectedProducts"));
    },
    handleSelectedProducts : function(component, event, helper) {
        var sp = component.get("v.selectedProducts");
        console.log('selected price' + sp);	
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
        helper.createOrderHelper(component,event);		
    }
    /*
    updateStockItem : function(component, event, helper) {
        helper.newProductPrices(component,event);
    }
    */
})