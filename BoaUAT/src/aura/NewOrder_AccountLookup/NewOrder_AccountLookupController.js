({
    doInit : function(component, event, helper) {
        helper.accountDetails(component, event);
    },
    getAcc : function(component) {        
        var accName = component.find("accName");   
        var comboBox = component.find("combobox"); 
        $A.util.addClass(accName,"slds-has-input-focus");            
        $A.util.removeClass(comboBox,"slds-combobox-lookup");
        //$A.util.addClass(comboBox,"slds-is-open");         
    },
    accF : function(component) {        
        var accName = component.find("accName");   
        var comboBox = component.find("combobox");     
        $A.util.removeClass(accName,"slds-has-input-focus");       
        $A.util.addClass(comboBox,"slds-combobox-lookup");
    },
    getAccounts : function(component, event, helper) {
        helper.accNames(component, event);   
    },
    selectedAcc : function(component,event) {
        var comboBox = component.find("combobox"); 
        var accSelected = component.find("selectedAcc"); 
        var accountS = component.find("selectAcc"); 
        var boxInput = component.find("boxInput"); 
        var selectedItem = event.currentTarget;
        //alert(selectedItem.title);
        if(selectedItem.dataset.record){

            //if(selectedItem.dataset.popup != undefined){
                //alertify.alert(selectedItem.dataset.popup).setHeader('Customer Info').set('movable', false);
            //}
             
            component.set("v.selectedAccountName",selectedItem.title);
            component.set("v.selectedAccountId",selectedItem.dataset.record);
            document.getElementById("combobox-unique-id").value = selectedItem.title;
            
            $A.util.removeClass(comboBox,"slds-is-open"); 
            $A.util.removeClass(accSelected,"slds-hide"); 
            $A.util.removeClass(accountS,"slds-show");
            $A.util.addClass(accountS,"slds-hide");
            $A.util.addClass(boxInput,"selectedAcc");
            
            component.getEvent("selectedAccount").setParams({"loopkUpAccountId":selectedItem.dataset.record}).fire();
        }
    },
    removeSelectedItem : function(component,event) {
        var oppId = component.get("v.oppIdExists");
        if(oppId){
            //alertify.error("Cannot change the customer").set('position','top-left');
            alertify.set('notifier','position', 'top-center');
            alertify.error('Cannot change customer in an edit order');
        }
        else{
            document.getElementById("combobox-unique-id").value = '';       
            component.set("v.selectedAccountName",[]);
            component.set("v.selectedAccountId",[]);
            
            var accSelected = component.find("selectedAcc");
            var accountS = component.find("selectAcc"); 
            var boxInput = component.find("boxInput"); 
            
            $A.util.addClass(accSelected,"slds-hide"); 
            $A.util.addClass(accountS,"slds-show");
            $A.util.removeClass(accountS,"slds-hide");        
            $A.util.removeClass(boxInput,"selectedAcc");
            
            // update other fields. uncomment when other fields are added.
            component.getEvent("selectedAccount").setParams({"loopkUpAccountId":""}).fire();  
        }
        
    },
    addBackgroundColor:function(component){
        var addBackgroundC = component.find("cbox-unique-id");
        $A.util.addClass(addBackgroundC,"selectedAccBackgroundC");
    },
    removeBackgroundColor:function(component){
        var removeBackgroundC = component.find("cbox-unique-id");
        $A.util.removeClass(removeBackgroundC,"selectedAccBackgroundC");
    }
})