({
    
    handleLoad: function(component, event, helper) {
        component.set('v.showSpinner', false);
    },
    
    handleSubmit: function(component, event, helper) {

        var stage = component.get("v.simpleRecord.StageName");
        var onboardingStartDate = component.find("onboardingStartDate").get("v.value");
        var onboardingCloseDate = component.find("onboardingCloseDate").get("v.value");
        var buisnessType = component.find("buisnessType").get("v.value");
		var onboardingContact = component.find("onboardingContact").get("v.value");
        if((stage === 'Closed Won') && (onboardingStartDate === null  || onboardingCloseDate === null)){
            event.preventDefault();
            alertify.alert('Please enter Onboarding start and end date when stage is Closed Won').setHeader('Required field missing').set('movable', false);
            component.set('v.disabled', false);
            component.set('v.showSpinner', false);
        }
        else if((buisnessType === 'New Business') && (onboardingStartDate === null || onboardingCloseDate === null || onboardingContact === null)) {
            event.preventDefault();
            alertify.alert('Please enter Onboarding start,end date and point of contact when buisness type is New Buisness').setHeader('Required field missing').set('movable', false);
            component.set('v.disabled', false);
            component.set('v.showSpinner', false);
        }
        else{
            component.set('v.disabled', true);
            component.set('v.showSpinner', true);
        }
        
    },
    
    handleError: function(component, event, helper) {
        // errors are handled by lightning:inputField and lightning:messages
        // so this just hides the spinner
        component.set('v.showSpinner', false);
    },
    
    handleSuccess: function(component, event, helper) {
        component.set('v.showSpinner', false);
        component.set('v.saved', true);
        $A.get("e.force:refreshView").fire();
    }
})