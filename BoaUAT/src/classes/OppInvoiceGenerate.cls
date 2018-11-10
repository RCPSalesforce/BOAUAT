public class OppInvoiceGenerate {
    @AuraEnabled
    public static void Oppcon(Id DocId){
        System.debug('###'+DocId);
        try{
            String OpppdfgenId = cadmus.ConvertController.convertToPdf(system.label.InvoiceGeneratepdf,DocId);
            system.debug('OpppdfgenId'+OpppdfgenId);
            
        }
        catch(exception e){
            
        }
        System.debug('#Pass to Controller ');
    }
    



}