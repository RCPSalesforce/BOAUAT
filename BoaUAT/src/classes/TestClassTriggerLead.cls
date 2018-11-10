@isTest
Private class TestClassTriggerLead
{
    @isTest static void myTest()
    {
        Lead l = new lead();     // new lead came on website
        l.LastName='kadam';
        l.company='abc';
        l.email='abc@gmail.com';
        l.FirstName='suraj';
        l.Phone  ='8605415046';
        l.Industry='agricultur';
        insert l;
       
       
        Lead l1 = new lead();
        l1.LastName='sameer';
        l1.company='cba';
        l1.email='abc@gmail.com';
        insert l1;
    }
}