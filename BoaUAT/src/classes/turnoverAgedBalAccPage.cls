public class turnoverAgedBalAccPage {
	
    Public Account acc;
    public turnoverAgedBalAccPage(ApexPages.StandardController controller) {
		
    	acc = (account)controller.getRecord();
    }

}