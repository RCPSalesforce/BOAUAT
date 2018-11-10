({
    doInit : function(component, event, helper) {
        var pg = component.get("v.pageReference").state.c__accountId;
        var oppId = component.get("v.pageReference").state.c__oppId;
        if(oppId !== undefined){
            component.set("v.oppId",oppId);
            helper.getOrderProd(component);
        }
        else{
            if(pg !== null || pg !== undefined){
                component.set("v.showProduct",true);
            }
            component.set("v.accountId",pg);
            component.set("v.showAccount",true);            
        }
        
    },
    handleSelectedProducts : function(component, event) {
        var ps = event.getParam("prodSelected");
        component.set("v.selectedProducts",ps);
    },
    handleSelectedAccount : function(component, event) {
        var accId = event.getParam("loopkUpAccountId");
        if(accId === ''){
            component.set("v.showProduct",false);   
        }
        else{
            component.set("v.showProduct",true);   
        }
        component.set("v.selectedProducts",[]); 
    },
    handleSave : function(component) {
        var orderAccount = component.find("orderAccount");
        orderAccount.orderDetails();
    },
    handleCancel : function(component){
        var windowLoc = window.location.href;
        var params = {};
        var parser = document.createElement('a');
        parser.href = windowLoc;
        var query = parser.search.substring(1);
        var vars = query.split('?');
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split('=');
            params[pair[0]] = decodeURIComponent(pair[1]);
        }
        var oppId = component.get("v.oppId");
        if(oppId !== ''){
            parser.setAttribute('href',"/lightning/r/Opportunity/" + oppId + '/view');
            parser.click();
            return;
        }
        if(params.c__accountId !== 'undefined'){
            parser.setAttribute('href',"/lightning/r/Account/" + params.c__accountId + '/view');
            parser.click();
            return;
        }
        else{
            parser.setAttribute('href',"/lightning/o/Opportunity/list?filterName=Recent");
            parser.click();
            return;
        }
    }
})