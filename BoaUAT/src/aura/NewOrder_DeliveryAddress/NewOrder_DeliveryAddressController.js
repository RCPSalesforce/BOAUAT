({
	displayAddress : function(component) {
        var addressComponent = component.get("v.showAddress");
		component.set("v.showAddress",!addressComponent);
        component.set("v.selectedDelAddr",{});
        component.set("v.showError",false);
	},
    selectDeliveryAddress : function(component, event) {
        var selectedDelAddrIndex = event.target.value;
        var selectedDelAddr = component.get("v.customerDeliveryAddress")[selectedDelAddrIndex];
        component.set("v.selectedDelAddr",selectedDelAddr);
        component.set("v.showError",false);
        //console.log(JSON.stringify(component.get("v.selectedDelAddr")));
    },
    sendDelAddr : function(component, event) {
        var selectedAddrLength  = Object.keys(component.get("v.selectedDelAddr")).length;
        if(selectedAddrLength > 0){
            var address = component.get("v.showAddress");
            component.getEvent("updateDeliveryAddress").setParams({"delAddress":component.get("v.selectedDelAddr")}).fire();
            component.set("v.showAddress",!address);
            component.set("v.selectedDelAddr",{});
            component.set("v.showError",false);
        }
        else{
            component.set("v.showError",true);
            //console.log("no addr selected");
        }        
    }
})