({
    accountDetails : function(component, event) {
        
        var accRecId = component.get("v.recId");
        if(accRecId != ''){
            var action = component.get("c.selectedAccDetails");
            action.setParams({
                "accId" : accRecId
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS"){
                    var g = JSON.parse(response.getReturnValue());
                    if(g.error){
                        component.set("v.errorM",g.error); // add toast message here
                    }
                    else{
                        var comboBox = component.find("combobox"); 
                        var accSelected = component.find("selectedAcc"); 
                        var accountS = component.find("selectAcc"); 
                        var boxInput = component.find("boxInput");                             
                        
                        component.set("v.selectedAccountName",g.Name);	
                        component.set("v.selectedAccountId",g.Id);
                        component.set("v.renderDetail",false);         
                        document.getElementById("combobox-unique-id").value = g.Name;
                        
                        $A.util.removeClass(comboBox,"slds-is-open"); 
                        $A.util.removeClass(accSelected,"slds-hide"); 
                        $A.util.removeClass(accountS,"slds-show");
                        $A.util.addClass(accountS,"slds-hide");
                        $A.util.addClass(boxInput,"selectedAcc");
                    }
                }
                
            });
            $A.enqueueAction(action);                 
        }
        
    },
    accNames : function(component, event) {
        var accName = event.target.value;
        var objectType = component.get("v.objectType");
        var comboBox = component.find("combobox"); 
        var comboBoxOpen = document.getElementsByClassName('slds-is-open');
        if(event.keyCode == 27 || event.keyCode == 9 || accName.length == 0){
            if(comboBoxOpen.length > 0){
                $A.util.removeClass(comboBox,"slds-is-open"); 
            }
        }
        else{             
            if(accName.length > 0){
                var action = component.get("c.searchAcc");
                action.setParams({
                    "accountName" : accName,
                    "objType":objectType,
                    "type": component.get("v.accountType")
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if(component.isValid() && state === "SUCCESS"){
                        var g = JSON.parse(response.getReturnValue());
                        if(g.error){
                            component.set("v.errorM",g.error); // add toast message here
                            /*
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "message": "error",
                                "type":"error"
                            });
                            toastEvent.fire(); 
                            */
                        }
                        else{
                            component.set("v.accountNames",g);                                     
                            $A.util.addClass(comboBox,"slds-is-open"); 
                        }
                    }
                    
                });
                $A.enqueueAction(action);                 
            }
        }
    }
})