public class Opportunity_Qoute_generate {
@AuraEnabled
    public static void Oppcon(Id DocId){
        System.debug('###'+DocId);
        try{
            String OpppdfgenId = cadmus.ConvertController.convertToPdf(system.label.Quote_Templatepdf,DocId);
            system.debug('OpppdfgenId'+OpppdfgenId);
            
        }
        catch(exception e){
            
        }
        System.debug('#Pass to Controller ');
    }
    

}