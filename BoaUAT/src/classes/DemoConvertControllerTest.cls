@IsTest()
public class DemoConvertControllerTest {

    static testmethod void convertLightningTest() {
        cadmus.CadmusHttpCalloutMock.setTestCalloutMockSuccess('<YOUR OBJECT ID>');
        DemoConvertController.convertToPdfLightning(null, null);
    }
}