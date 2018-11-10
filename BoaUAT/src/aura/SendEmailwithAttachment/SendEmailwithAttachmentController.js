({
    doInit : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        var action = component.get("c.getAttachments");
        var options = [];
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'recordId': recId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
				                
                /*
                if(storeResponse != undefined && storeResponse.length > 0){
                    for(var i=0;i < storeResponse.length;i++){
                        alert('in here');
                        options.push({
                            label:storeResponse[i].label,
                            value:storeResponse[i].value
                        });
                    }
                }
                
                alert('options--'+options); */
                var s = JSON.parse(storeResponse);
                
                //var s = [{"value":"00P0l000001fbT3EAI","label":"2d8df586-f4b6-4f9e-8443-e5f9cf068acf_2018-07-19 03:52:55.80.pdf"},{"value":"00P0l000001fbSeEAI","label":"2d8df586-f4b6-4f9e-8443-e5f9cf068acf_2018-07-19 03:50:48.768.pdf"}];
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                component.set("v.attachments",s);
                
                //var htmlbody = '<html><body><p></p><p/><p/><p/><font face="calibri" size="3" color="blue">Thanks,</font><font face="calibri" size="3" color="black">DISCLAIMER: This electronic message together with any attachments is confidential. If you are not the intended recipient: (i) do not copy, disclose or use the contents in any way; (ii) please let us know immediately and then destroy the message. Neither Silverline Group Ltd t/a BOA [Formerly United Flexible] nor the sender accepts responsibility for any viruses contained in this email or any attachments.</font></body></html>';
				//component.set("v.body",htmlbody);				
				               
            }
 
        });
        $A.enqueueAction(action);
       
    },    
    sendMail: function(component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 
        var recId = component.get("v.recordId");	
        var getEmail = component.get("v.email");
        var getCc = component.get("v.cc");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        //var attachFlag = component.get("v.attachFlag");
        var selectedAttachments = component.get("v.value")
       // alert('selectedAttachments -- '+selectedAttachments);
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        }else if (getCc != " " && !getEmail.includes("@")) {
            alert('Please Enter valid CC Address');
        }
        else if ($A.util.isEmpty(getbody)) {
            alert('Email body cannot be blank');
        }
        else {
            helper.sendHelper(component, getEmail, getCc, getSubject, getbody, recId, selectedAttachments);
        }
    },
 
    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.cc", null);
        component.set("v.subject", null);
        component.set("v.body", null);
    },
    
    selectChange : function(component, event, helper) {
        //component.set("v.attachFlag", true);
        // first get the div element. by using aura:id
      //var changeElement = component.find("v.checker");
        //alert('Value -- '+changeElement);
        component.set("v.attachFlag",!component.get("v.attachFlag"));
        //alert("value -- "+component.get("v.attachFlag"))
        // by using $A.util.toggleClass add-remove slds-hide class
      //$A.util.toggleClass(changeElement, "slds-hide");
	  },
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    
    recordUpdated : function(component, event){
        var contactEmail = component.get("v.simpleRecord.Order_Placed_By__r.Email");
        if(contactEmail !== null){
            component.set("v.email",contactEmail);
            console.log('test1');
        }
        else{
            console.log('test2');
        }
    }
})