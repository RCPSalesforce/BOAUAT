public class Rest_ExoWrappers {
    
    public SalesOrdHdr salesOrdHdr;
    public PurchOrdHdr purchOrdHdr;
    
    //any chnages to this class should be communicated internally.
    public class genericOutboundResponseWrapper{
        public integer responseCode;
        public string  responseBody;
    }
    public class salesOrdDetails {
        public SalesOrdHdr salesOrdHdr;
        
    }
    
    public class SalesOrdHdr {  
        Public integer STATUS; 
        Public integer ACCNO;
        Public datetime ORDERDATE;
        Public datetime DUEDATE;
        Public string CUSTORDERNO;
        Public string REFERENCE; 
        Public string ADDRESS1;
        Public string ADDRESS2;
        Public string ADDRESS3;
        Public string ADDRESS4;
        Public Decimal SUBTOTAL;
        Public Decimal TAXTOTAL;
        Public Decimal SALESNO;
        Public datetime LAST_UPDATED;
        Public Decimal  CURRENCYNO;
        Public string DEFLOCNO;
        Public string ONHOLD;
        Public datetime CREATE_DATE;
        Public string SalesforceID;
        Public Decimal SEQNO;
        public List<SalesOrdLines> salesOrdLines;
        public SalesOrdHdr(){
            salesOrdLines = new List<SalesOrdLines>(); 
        }
    }
    
    public class SalesOrdLines {
        Public string STOCKCODE;
        Public string DESCRIPTION;
        Public decimal ORD_QUANT;
        Public decimal UNITPRICE;
        Public decimal DISCOUNT;
        Public decimal LISTPRICE;
        Public string DUEDATE;
        public decimal SEQNO;
        Public string SalesforceID;
    }
    Public class PurchOrdHdr{
        
        Public integer STATUS; 
        Public integer ACCNO;
        Public datetime ORDERDATE;
        Public datetime DUEDATE;
        Public string REFERENCE; 
        Public string ADDRESS1;
        Public string ADDRESS2;
        Public string ADDRESS3;
        Public string ADDRESS4;
        Public Decimal SUBTOTAL;
        Public Decimal TAXTOTAL;
        Public Decimal SALESNO;
        Public datetime LAST_UPDATED;
        Public Decimal  CURRENCYNO;
        Public string DEFLOCNO;
        Public datetime CREATE_DATE;
        Public string SalesforceID;     
        Public Decimal SEQNO;

        Public List<PurchOrdLines> purchOrdLines;
        public purchOrdHdr(){
            purchOrdLines = new List<PurchOrdLines>(); 
        }
    }
    Public class PurchOrdLines{
        
        Public string STOCKCODE;
        Public string DESCRIPTION;
        Public decimal ORD_QUANT;
        Public decimal UNITPRICE;
        Public decimal DISCOUNT;
        Public decimal LISTPRICE;
        Public datetime DUEDATE;
        public decimal SEQNO;
        Public string SalesforceID;
    }
    public class PurchaseOrdDetails {
        public PurchOrdHdr purchOrdHdr;
        
    }
    public class AccountDrDetails {
        public decimal ACCNO;
        public decimal STATEMENT_CONTACT_SEQNO;
        public string STATEMENT;
        public String ALPHACODE;
        public String NAME;
        public String ADDRESS1;
        public string ADDRESS2;
        public String ADDRESS3;
        public string ADDRESS4;
        public String POST_CODE;
        public String DELADDR1;
        public string DELADDR2;
        public String DELADDR3;
        public string DELADDR4;
        public string DELADDR5;
        public String EMAIL;
        public String PHONE;
        public string FAX;
        public string X_CUSCLASS;
        public Decimal X_MONTHLYTARGET;
        public string X_PPSR;
        public string ACCGROUP;
        public string ACCGROUP2;
        public decimal SALESNO;
        public string PRICENO;
        public string CREDITSTATUS;
        public Decimal CREDLIMIT;
        public string ISACTIVE;
        public string OPENITEM;
        public string STOPCREDIT;
        public string NEED_ORDERNO;
        public string ALLOW_RESTRICTED_STOCK;
        public string ALERT;
        public string PAY_TYPE;
        public datetime X_SET_UP_DATE;
        public string X_HOSE_TYPE;
        public string X_INDUSTRYTYPE;
        public string X_FITTING_TYPE;
        public string X_CRIMPER;
        public datetime STARTDATE;
        public integer HEAD_ACCNO;
        public decimal CURRENCYNO;
        public string SalesforceID;
        public string PRIVATE_ACC;
        public integer DEF_INVMODE;
                public string TAXSTATUS;

    }
    
    public class AccountCrDetails {
        public decimal ACCNO;
        public string PRIVATE_ACC;
        public String ALPHACODE;
        public String NAME;
        public String ADDRESS1;
        public string ADDRESS2;
        public String ADDRESS3;
        public string ADDRESS4;
        public string ADDRESS5;
        public String POST_CODE;
        public String DELADDR1;
        public string DELADDR2;
        public String DELADDR3;
        public string DELADDR4;
        public string DELADDR5;
        public String EMAIL;
        public String PHONE;
        public string FAX;
        public string X_CUSCLASS;
        public Decimal X_MONTHLYTARGET;
        public boolean X_PPSR;
        public string ACCGROUP;
        public string ACCGROUP2;
        public decimal SALESNO;
        public string PRICENO;
        public string CREDITSTATUS;
        public Decimal CREDLIMIT;
        public string ISACTIVE;
        public string OPENITEM;
        public string STOPCREDIT;
        public boolean NEED_ORDERNO;
        public boolean ALLOW_RESTRICTED_STOCK;
        public string ALERT;
        public string PAY_TYPE;
        public datetime X_SET_UP_DATE;
        public string X_HOSE_TYPE;
        public string X_FITTING_TYPE;
        public string X_CRIMPER;
        public datetime STARTDATE;
        public integer HEAD_ACCNO;
        public decimal CURRENCYNO;
        public string AGEDBAL0;
        public string AGEDBAL1;
        public string AGEDBAL2;
        public string AGEDBAL3;
        public string DISCOUNTLEVEL;
        public string DELADDR6;
        public string INVOICETYPE;
        public string AUTOFREIGHT;
        public string NOTES;
        public string MONTHVAL;
        public string YEARVAL;
        public string TAXSTATUS;
        ///public string HEAD_ACCNO;
        //public string CURRENCYNO;
        public string BANK_ACCOUNT;
        public string DEFAULT_CODE;
        public string BANK_ACC_NAME;
        public string LAST_UPDATED;
        public decimal LEADTIME;
        public string TAXREG;
        //public string POST_CODE;
        public string N_CR_DISC;
        public string GLCONTROLACC;
        public string GLCONTROLSUBACC;
        public string BRANCHNO;
        public string PRIOR_AGEDBAL0;
        public string PRIOR_AGEDBAL1;
        public string PRIOR_AGEDBAL2;
        public string PRIOR_AGEDBAL3;
        public string PROMPT_PAY_DISC;
        public string BSBNO;
        public string AUTO_AUTH_AMT;
        //public string PAY_TYPE;
        //public string ACCGROUP2;
        public decimal LEADTIME2;
        public string N_LAND_COST_PROVN;
        public string  PP_TOPAY;
        //public string  STOPCREDIT;
       // public string DEF_INVMODE;
        //public string  PRIVATE_ACC;
        public string WEBSITE;
        
        public string STATEMENT_TEXT;
        public string REMITTANCE_METHOD;
        //public string SEND_PAYMENT_REMITTANCE;
        public decimal STATEMENT_CONTACT_SEQNO;
        public string X_HIDE_DASKO_CODES;
        public string X_HIDE_POPRICES;
        public string LINKEDIN;
        public string TWITTER;
        public string FACEBOOK;
        //public string TRACK_CITP;
        public string LATITUDE;
        public string LONGITUDE;
        public string GEOCODE_STATUS;
        public string X_SUPPLIERS_ACCNO;
        public string EXTERNAL_ID;
        public string SalesforceID;
        
        public string KEEPTRANSACTIONS;//Y
        public string ISTEMPLATE;//N
        public string FREIGHTFREE;//N
        public integer AVE_DAYS_TO_PAY;//-1
        public integer DEF_INVMODE; //0
        public string SEND_PAYMENT_REMITTANCE; // N
         public string TRACK_CITP; //N
        
        
    }
    public class ContactDetails {
        
        public decimal SEQNO;
        public string SalesforceID;
        public String SALUTATION;
        public String FIRSTNAME;
        public String LASTNAME;
        public String TITLE;
        public String MOBILE;
        public String DIRECTPHONE;
        public String DIRECTFAX;
        public String HOMEPHONE;
        public String EMAIL;
        public String ADDRESS1;
        public String ADDRESS2;
        public String ADDRESS3;
        public String ADDRESS4;
        public String POST_CODE;
        public String DELADDR1;
        public String DELADDR2;
        public String DELADDR3;
        public String DELADDR4;
        public String DELADDR5;
        public boolean ISACTIVE;
        public decimal SALESNO;
        public decimal COMPANY_ACCNO;
        public datetime LAST_UPDATED;
        public boolean OPTOUT_EMARKETING;
        public Integer COMPANY_ACCTYPE;
    }
    public class Cr_contact{
        public decimal CONTACT_SEQNO;
        public decimal ACCNO;
        public String DEFCONTACT;
        public string DEFACCOUNT;
        public string SEQNO;
        public string SalesforceID;

    }
    public class stock_supplier{
        public string STOCKCODE;
        public string SUPPLIERCODE;
        public decimal    ACCNO;
        public decimal  PURCHPACKQUANT;
        public decimal   PURCHPACKPRICE;
        public string  IS_DEFAULT;
        public string DESCRIPTION;
        public string PACKREFERENCE;
        public decimal DISCOUNT;
        
    }
    
    public class StockItem {
        
        public String STOCKCODE;
        public String DESCRIPTION;
        public string STOCKGROUP; //int
        public string STOCKGROUP2; //int
        public string STOCK_CLASSIFICATION; //int
        public string STOCKPRICEGROUP;//int
        public String PACK;// string each
        public string ISACTIVE;// string y n 
        public string IS_DISCOUNTABLE;
        public string RESTRICTED_ITEM;
        public string STATUS;
        public decimal ECONORDERQTY;
        public decimal WEIGHT;
        public decimal CUBIC;
        public Integer SALESTAXRATE; 
        public string PURCHTAXRATE;//int
        public string SALES_GL_CODE;
        public string COS_GL_CODE;//int
        public string COS_GLSUBCODE;//int
        public string PURCH_GL_CODE;//int
        public string SALES_GLSUBCODE;//int
        public string PURCH_GLSUBCODE;//int
        public string BARCODE1;
        public string BARCODE2;
        public string BARCODE3;
        public string ALERT;
        public decimal SUPPLIERNO;
        public decimal SUPPLIERNO2;
        public decimal SUPPLIERNO3;
        public datetime LAST_UPDATED;
        public String SalesforceID;
    }
    public class priceBook{
        public String STOCKCODE;
        public decimal SELLPRICE1;
        public decimal SELLPRICE2;
        public decimal SELLPRICE3;
        public decimal SELLPRICE16;
        public decimal SELLPRICE17;
        public decimal SELLPRICE18;
        public decimal LATESTCOST;
        public decimal AVECOST;
        public decimal STDCOST;
        public decimal SUPPLIERCOST;
    }    
    
    //Bill Of Material wraapper classes
    public class bomWrapper{
        public BomHdr BomHdr;
        public bomWrapper(){
            BomHdr = new BomHdr();
        }
    }
    
    public class BomHdr {
		public String BILLCODE;
		public String DESCRIPTION;
		public decimal SELLPRICE1;
		public decimal SELLPRICE2;
		public decimal SELLPRICE3;
		//public Integer SELLPRICE4;
		public decimal COSTPRICE;
		public Integer PRICING_MODE;
		public String OUTPUT_CODE;
		public Integer BATCH_QTY;
		public String HIDE_LINES;
		//public Integer WASTAGE;
		public String NOTES;
		//public Integer SELLPRICE5;
		//public Integer SELLPRICE6;
		//public Integer SELLPRICE7;
		//public Integer SELLPRICE8;
		//public Integer SELLPRICE9;
		//public Integer SELLPRICE10;
		public String ISACTIVE;
		public Integer KIT_TYPE;
		public String BOMTYPE;//complusory
		public String AUTOBUILD;//complusory
		//public Integer SELLPRICE11;
		//public Integer SELLPRICE12;
		//public Integer SELLPRICE13;
		//public Integer SELLPRICE14;
		//public Integer SELLPRICE15;
		public decimal SELLPRICE16;
		public decimal SELLPRICE17;
		public decimal SELLPRICE18;
		//public Integer SELLPRICE19;
		Public List<BomLines> bomLines;
        public bomHdr(){
            bomLines = new List<BomLines>(); 
        }	}

	public class BomLines {
		public String BILLCODE;
		public String STOCKCODE;
		public decimal QUANTITY;
		public String DESCRIPTION;
		//public String VARIANTLINE;
	}
    
    //batch stock location get Response wrapper
    public class cls_stockLocationInfoWrapper {
        public string msg;
        public list<cls_stockLocationInfo> stockLocationData;
    }
    
    public class cls_stockLocationInfo {
        public integer LOCNO;
        public string LCODE;
        public string LNAME;
        public string ISACTIVE;
        public string EXCLUDE_FROMVALUATION;
        public string EXCLUDE_FROMFREE_STOCK;
        public string EXCLUDE_FROMSALES;
        public string DELADDR1;
        public string DELADDR2;
        public string DELADDR3;
        public string DELADDR4;
        public string DELADDR5;
        public string DELADDR6;
        public string IS_WIPLOCATION;
        public string SalesforceID;
        
    }
    
    //batch stock count get Response wrapper
    public class stockCountInfoWrapper {
        public string msg;
        public list<cls_stockCountInfo> stockinfoData;
    }
    
    public class cls_stockCountInfo {
        public string STOCKCODE;
        public integer LOCATION; 
        public string BINCODE;
        public integer MINSTOCK;
        public integer MAXSTOCK;
        public decimal QTY;
        public integer Myob;
        public string SalesforceId;
    }
    
       // batch account response wrapper
    public class getAccountWrapper {
        public String msg;
        public list<cls_accountData> accountData;
    }
    
    public class cls_accountData{
        public string ACCNO;
        public string SalesforceID;
        public decimal AGEDBAL0;
        public decimal AGEDBAL1;
        public decimal AGEDBAL2;
        public decimal AGEDBAL3;
        public decimal BALANCE;
        public decimal LASTMONTH;
        public decimal LASTYEAR;
        public decimal MONTHVAL;
        public decimal YEARVAL;
    }
 
    //batch account creditor response wrapper
    public class getCreditorWrapper {
        public String msg;
        public list<cls_accountData> cr_accountData;
    }
    
}