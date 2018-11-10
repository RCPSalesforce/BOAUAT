@istest(seeAlldata=true)
    private class LightningSelfRegisterControllerTest{
    
        public static testMethod void Method1() {
       User us= [select id,Username from user limit 1];
       Account acc=new Account(Name='Test');
       insert acc;
        LightningSelfRegisterController con=new LightningSelfRegisterController();
        LightningSelfRegisterController.isValidPassword('1234','1234');
       // LightningSelfRegisterController.siteAsContainerEnabled();
       // LightningSelfRegisterController.validatePassword(us,'1234','1234');
        LightningSelfRegisterController.selfRegister('Silver','','','1234','1234','12343456','test.sales.com','','test.sales.com',true);
        LightningSelfRegisterController.selfRegister('Silver','Group','silver@gmail.com','1234','1234','12343456','test.sales.com','','test.sales.com',true);
        LightningSelfRegisterController.selfRegister('Silver','Group','','1234','1234','12343456','test.sales.com','','test.sales.com',true);
       
         
        
        LightningSelfRegisterController.getExtraFields('Sample');
        }
    }