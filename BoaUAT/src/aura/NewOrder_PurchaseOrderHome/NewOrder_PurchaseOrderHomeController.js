({
    /* initial
    doInit : function(component, event, helper) {
        var pg = component.get("v.pageReference").state.c__accountId;
        component.set("v.accountId",pg);
        component.set("v.showAccount",true);
        component.set("v.showProduct",true);
    }
    */
    doInit : function(component, event, helper) {
        var pg = component.get("v.pageReference").state.c__accountId;
        var oppId = component.get("v.pageReference").state.c__oppId;
        if(oppId !== undefined){
            component.set("v.oppId",oppId);
            helper.getOrderProd(component,event);
        }
        else{
            if(pg !== null || pg !== undefined){
                component.set("v.showProduct",true);
            }
            component.set("v.accountId",pg);
            component.set("v.showAccount",true);
        }

    },
    handleSelectedProducts : function(component, event, helper) {

        var ps = event.getParam("prodSelected");
        //var showSelectedP = component.get("v.showSelectedProduct");
        //if(showSelectedP == false){
        //    component.set("v.showSelectedProduct",true);
        //}
        component.set("v.selectedProducts",ps);
        //component.set("v.activeSectionName","selectedProductDetails");
        
        /*
        var ps = event.getParam("prodSelected");
        var showSelectedP = component.get("v.showSelectedProduct");
        if(showSelectedP == false){
            component.set("v.selectedProducts",ps);
            component.set("v.showSelectedProduct",true);
        }
        if(showSelectedP == true){
            component.set("v.selectedProducts",ps);          
        }
        */
    },
    handleSelectedAccount : function(component, event, helper) {
        var accId = event.getParam("loopkUpAccountId");
        console.log('accId' + accId);
        component.set("v.selectedProducts",[]);
        if(accId === ''){
            component.set("v.showProduct",false);   
        }
        else{
            component.set("v.showProduct",true);   
        }
      //component.set("v.accountId",accId);
      //component.set("v.accountIdProductList",accId);  
    },
    handleSave : function(component, event, helper) {
    	var orderAccount = component.find("orderAccount");
        orderAccount.orderDetails();
    },
    handleCancel : function(component, event){
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
        if(oppId != ''){
            parser.setAttribute('href',"/lightning/r/Opportunity/" + oppId + '/view');
            parser.click();
            return;
        }
        if(params.c__accountId != 'undefined'){
         /*
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/001/o"
            });
            urlEvent.fire();
         */   
            parser.setAttribute('href',"/lightning/r/Account/" + params.c__accountId + '/view');
            parser.click();
            return;
        }
        else{
         /* 
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                //"url": "/006/o" // uncomment if list view component not working
                "url":"/lightning/n/Boa_Sales_Order"
            });
            urlEvent.fire();
         */   
            //parser.setAttribute('href',"/lightning/n/Boa_Purchase_Order");
            parser.setAttribute('href',"/lightning/o/Opportunity/list?filterName=Recent");
            parser.click();
            return;
        }
    },
    toggleContent : function(component, event, helper) {
        var buttonId = event.target.id;
        
        if(buttonId == "section1Button"){
            var secIcon = component.get("v.section1Icon");
            var secDetails = component.find("section1");
            secIcon = secIcon == "utility:chevronright" ? "utility:switch" : "utility:chevronright";
            component.set("v.section1Icon",secIcon);
            $A.util.toggleClass(secDetails,"slds-is-open");
        }
        
        if(buttonId == "section2Button"){
            var secIcon = component.get("v.section2Icon");
            var secDetails = component.find("section2");
            secIcon = secIcon == "utility:chevronright" ? "utility:switch" : "utility:chevronright";
            component.set("v.section2Icon",secIcon);
            $A.util.toggleClass(secDetails,"slds-is-open");
        }
        
        if(buttonId == "section3Button"){
            var secIcon = component.get("v.section3Icon");
            var secDetails = component.find("section3");
            secIcon = secIcon == "utility:chevronright" ? "utility:switch" : "utility:chevronright";
            component.set("v.section3Icon",secIcon);
            $A.util.toggleClass(secDetails,"slds-is-open");
        }
    }
})