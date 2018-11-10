@istest(seeAlldata=true)
    private class LightningLoginFormControllerTest{
    
        public static testMethod void Method1() {
        LightningLoginFormController con=new LightningLoginFormController ();
        LightningLoginFormController.login('Silver','1234','test.sales.com');
        LightningLoginFormController.getIsUsernamePasswordEnabled();
        LightningLoginFormController.getIsSelfRegistrationEnabled();
        LightningLoginFormController.getSelfRegistrationUrl();
        LightningLoginFormController.getForgotPasswordUrl();
        LightningLoginFormController.getAuthConfig();
        }
        }