({
    navigateToOrder : function(component,event) {
        var customerType = '';
        var orderType = event.getSource().get("v.value");
        var params = component.get("v.recordId");
        if(orderType == "sales"){
            window.open("/lightning/cmp/c__NewOrder_Home?c__accountId=" + params);
        }
        else if(orderType == "purchase"){
            window.open("/lightning/cmp/c__NewOrder_PurchaseOrderHome?c__accountId=" + params);
        } 
    }
})