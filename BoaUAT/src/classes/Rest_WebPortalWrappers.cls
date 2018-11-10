public class Rest_WebPortalWrappers {
	
    public class signupInformation{
        public string contactId;
        public string salutation;
        public string firstName;
        public string lastName;
        public string email;
        public string mobileNumber;
        public string officePhoneNumber;
        public string typeOfCustomer;
        Public string companyName;
        public string userRole;
        public string companyLocation;
        public string Industry;
        public string typeOfBusiness; // Need to confirm this
        // PersonAccount variables
        public string pSalutation;
        public string pFirstName;
        public string pLastName;
        public string personAssistantName;
        public string personAssistantPhone;
        public string personBirthdate; 
        public string personDepartment; 
        public string personEmail;
        public string personHomePhone; 
        public string personHasOptedOutOfEmail; 
        public string personHasOptedOutOfFax; 
        public string personLastCURequestDate; 
        public string personLastCUUpdateDate; 
        public string personLeadSource; 
        public string personMobilePhone;
        public string personTitle;
        public boolean verified;
        public addressWrapper postalAddress;
        public addressWrapper deliveryAddress;
    }
    //RP - added isPrimary boolean ...Vivek pls check if it impacts you.
    public class addressWrapper{
        public string salesforceId;
        public string street;
        public string city;
        public string state;
        public string country;
        public string postalCode;
        public boolean isPrimary;
    }
    
    //RP - this wrapper is to be used for fetching reposne from outbound request
    //any chnages to this class should be communicated internally.
    public class genericOutboundResponseWrapper{
        public integer responseCode;
        public string  responseBody;
    }
    
    public class creditAformInformation{
    	
        public string customerId;
        public string submittedby;
        public string postalAddress;
        public string physicalAddress;
        public date businessStartedDate;
        public string registeredofcadd;
        public string companyregistrationno;        
        public string typeofbusiness;
        public string fax;        
        public string phone;
        public string email;
        public string bankname;  
        public string branchname;
		public string manager;
		public string memail;
		public string accounts;
        public string aemail;
        public string purchasing;
        public string pemail;
		public string reference1;        
        public string reference2;
        public string reference3;
        public string ref1phone;
        public string ref2phone;
        public string ref3phone;
    }
    
    public class customerInformation{
        
        public string custid;
        public string contid;
        public string name;
        public string email;
        public string phone;
        public string mobilephone;
        public addressWrapper postalAddress;
        public addressWrapper deliveryAddress;
    }
    
    
    //contact and account info wrapper for webPortal - outbound request
    
    public class accountAndContactinfo{
        public customerInfoFromSF customerDetails;
        public contactInfoFromSF contactDetails;
        
        public accountAndContactinfo(){
            customerDetails = new customerInfoFromSF();
            contactDetails = new contactInfoFromSF();
        }   
    }
    
    public class accountInfoOutbound{
    	public  customerDetailsToWebportal customerDetails;
        
        public accountInfoOutbound(){
        	customerDetails = new customerDetailsToWebportal();    
        }
    }
    
    public class customerDetailsToWebportal{
    	
    	public string salesforceId; 
        public string name;
        public string email;
        public string phone;
        public string region;
        public string industry;
        public string currencyCode;
        public string basePriceGroup;
        public decimal creditLimit;
        public boolean stopCredit;
        public boolean isActive;
        public boolean allowRestrictedGoods;
        public boolean isOpenItem;
        public boolean needOrderNumber;
        public decimal remainingCreditBalance;
        public string overrideGSTRate;
        public decimal downTimeInHrsPerMonth;
        public decimal hydraulicOilUsage;
        public decimal currentSpend;
        public decimal totalSaving; 
        public boolean showAdvanceSavingsDetails;
        public boolean showFacilities;
        public addressWrapper postalAddress;
        public list<addressWrapper> deliveryAddress; 
        
        public customerDetailsToWebportal(){
            postalAddress = new addressWrapper();
            deliveryAddress = new List<addressWrapper>();
        }
    }
    
    //product info wrapper for webportal - outbound request
    public class stockItemInfoToSF{
        //public stockItemInfo stockItemDetails;
        //public priceBookEntryInfo priceBookDetails;
        
        public stockItemInfoToSF(){
        	//stockItemDetails = new stockItemInfo();
            //priceBookDetails = new priceBookEntryInfo;    
        }
    }
    
    public class priceBookEntryInfo{
        //PriceBook Entry variables
        public string priceBookEntryId;
        //Stock Item Variables
        public string stockCode;
        public string stockDescription;
        public string primaryGrp;
        public string primaryGrpDisplayName;
        public string secondaryGrp;
        public string secondaryGrpDisplayName;
        public string tertiaryGrp;
        public string tertiaryGrpDisplayName;
        public string productFamily;
        public string productFamilyDisplayName;
        public string priceGrp;
        public string stockClassification;
        public string familyDescription;
        //information
        public string barcode1;
        public string barcode2;
        public string barcode3;
        public string pack;
        public string stockImage1;
        public string stockImage2;
        public string stockImage3;
        public string shortenedCode;
        
        //Flags
        public boolean isActive;
        public boolean lookup;
        public boolean discountable;
        public boolean restrictedgoods;
        public boolean showOnWebPortal;
        
        //product dimensions related info
        public productDimensions productDimensions;
        //product price related info 
        public productPrices productPrices;
        
      
        public priceBookEntryInfo(){
            productDimensions = new productDimensions();
            productPrices = new productPrices();
        }
        
        
        
        
    }
    
//product dimensions related info
    public class productDimensions{
        //adapters and fittings dimensions
        public string nominalThreadSize1;
        public string nominalThreadSize2;
        public string nominalThreadSize3;
        public string nominalThreadSize4;
        public string physicalThreadSize1;
        public string physicalThreadSize2;
        public string physicalThreadSize3;
        public string physicalThreadSize4;
        public string threadType1;
        public string threadType2;
        public string threadType3;
        public string threadType4;
        public string orientation;
        public string tailSizeToSuitHoseID;
        public string nominalPipeSize;
        //hose dimensions
        public string hoseInnerDiameterinches;
        public decimal hoseInnerDiameterMM;
        public decimal workingPressurePSI;
        public decimal hoseOuterDiameterMM;
        public decimal workingPressureBAR;
        public decimal minimumBendRadiusMM;
        public string fullCoilSizeMetre;
        //flange-ClampDimensions
        public string b;
        public string d;
        public string e;
        public string h;
        public string kDrillDiameter;
        public string l;
        public string m;
        public string n;
        public string y;
        //QRC Dimensions
        public decimal nominalSizeMM;
        public decimal ratedFlow;
        public decimal maxWorkpressurePSI;
        public decimal maxFlow;
        public decimal minBurstPressureMalePSI;
        public decimal minBurstPressureFemalePSI;
        public decimal minBurstPressureCoupledPSI;
        public decimal fluidSpillageCC;
        //New Fields
        public string prefixThread1;
        public string identifierRelatedinfoThread2ID;
        public string collatedIdentifier;
        public string Thread3IDSSadaptor;
        public string DKOLDKOS;
        public string dashSize1;
        public string dashSize2;
        public string dashSize3;
        public string dashSize4;
        public string maleFemaleFlangeFittingOnly;
        //public string exoDescription;
        public string threadColourCode;
        public string threadTypeFilter1;
        public string threadTypeFilter2;
        public string suitsHose;
        public string lc;
        public string ld;
        public string h1;
        public string h2;
    }

//product related price information
    public class productPrices{
        //Price related data
        public decimal retailPrice;
        public decimal contractorPrice;
        public decimal tradePrice;
        public decimal wholesalePrice;
        public decimal dealerPrice;
        public decimal bulkBuyPrice;
        public string currencyCode;
    }    
    
    /*public class stockItemInfo{
        public string salesforceid;
        public string stockcode;
        public string stockdescription;
        public string primarygrp;
        public string secondarygrp;
        public string tertiarygrp;
        public string productfamily;
        public string pricegrp;
        public string stockclassification;
        //information
        public string barcode1;
        public string barcode2;
        public string barcode3;
        public string pack;
        public decimal weight;
        public decimal cubic;
        //Flags
        public boolean isActive;
        public boolean lookup;
        public boolean discountable;
        public boolean restrictedgoods;
        //stock count
        
        //
    }*/
    
    public class customerInfoFromSF {
       //account info variables from SF
        public string salesforceId; 
        public string name;
        public string email;
        public string phone;
        public string region;
        public string industry;
        public string currencyCode;
        public string basePriceGroup;
        public decimal creditLimit;
        public boolean stopCredit;
        public boolean isActive;
        public boolean allowRestrictedGoods;
        public boolean isOpenItem;
        public boolean needOrderNumber;
        public string overrideGSTRate;
        public decimal downTimeInHrsPerMonth;
        public decimal hydraulicOilUsage;
        public decimal currentSpend;
        public decimal totalSaving;
        public addressWrapper postalAddress;
        public list<addressWrapper> deliveryAddress;
        
        public customerInfoFromSF(){
            postalAddress = new addressWrapper();
            deliveryAddress = new list<addressWrapper>();
        }
    }
    
    public class contactInfoFromSF {
        //contact details variables
        public string salesforceId;
        public string salutation;
        public string firstName;
        public string lastName;
        public string email;
        public string mobileNumber;
        public string officePhoneNumber;
        public string userRole;
        public boolean isActive;
        //commented below 2, as not required by BOA anymore on contact level.
        //public addressWrapper contactPostalAddress;
        //public addressWrapper contactDeliveryAddress;
    }
    
 //name to be chnaged as inbound...   
    public class orderInfo{
        //Order info variables
        public string salesforceId;
        public string invoiceUrl;
        public string name; //--wont come through portal.
        public string orderPlacedBy;
        public string orderSource;
        //public string basePriceGroup;
        public string webPortalOrderStatus;
        public date closedDate;
        public date orderDate;
        public string orderCurrency;
        public string orderStage;
        public string customerId; //new
        public string customerCurrency; //new
        public string typeOfCustomer;
        public string customerOrderNumber;
        public string reference;
        public decimal subTotal;
        public decimal taxTotal;
        public decimal orderTotal;
        public string defaultLocation;
        //public boolean onHold;
        public string paymentType;
        public string transactionId;
        public boolean billOfMaterial;
        public string basePriceGroup;
        public List<orderProducts> orderProductsWrap;
        public addressWrapper address;        
        //bom products
        public list <bomProducts> bomProducts; 
        
        public orderInfo(){
        	orderProductsWrap = new List<orderProducts>();
            bomProducts = new List<bomProducts>();
            address = new addressWrapper();
        }
    }
	//change name as inbound--
    public class orderProducts{ 
        //orderProducts variables
        
        public string stockCode; //--make it as stockCode
        public string lineitemdescription;
        public decimal quantity;
        //public decimal suppliedQuantity;
        //public decimal invoicedQuantity;
        //public string description;
        public string discount;
        public decimal totalPrice;
        public decimal salesprice;
    }
    
    public class bomProducts{
        public string stockCode;
        public string lineItemDescription;
        public string stockCodewithQuantity; //new 
        //public string stockCode; //new
        public boolean spiral; //new 
        public boolean ferrules;      
        public string hoseImage;
        public boolean makeAtBoa;
        //public string basePriceGroup;
        public decimal totalPrice;
        public decimal salesprice;
        public decimal quantity;
        public boolean additionProducts;
        public string overAllLength;
        public List<hose> hoseWrapper;
        public List<additionalProducts> additionalProducts;
        
        public bomProducts(){
            hoseWrapper = new List<hose>();
            additionalProducts = new List<additionalProducts>();
        }
        /*public string bomName; //--concatenation of all stockcodes
        public string stockItem;
        public string description;
        public decimal isActive;
        public decimal retailPrice;
        public decimal contractorPrice;
        public decimal bulkBuyPrice;
        public decimal dealerPrice;
        public decimal teradePrice;
        public decimal wholeSalePrice;
        public string notes;*/        
    }
    
    public class hose{
        public string stockCode;
        public string position;
        public string unit;
        public decimal quantity;
        public string oriantation;
        public string angle;
        public decimal length; //for bore
        public decimal crimpSize;
        public string seatType;
        public string type;        
    }
    
    public class additionalProducts{
        public string stockCode;
        public decimal quantity;
        public string description;
        //public boolean additionalProducts;
    }
    
    // Delivery Address variables
    public class deliveryAddressInfo{        
        public string deliveryAddressId;
    }
    
    public class delAddressInfoUpdate{
        public string customerId;
        public string deliveryAddressId;
        public addressWrapper deliveryAddress;    
    }
    
    public class insertDeliveryAddress{
        public string customerId;
        public addressWrapper deliveryAddress; 
    }
    
    public class leadInfo{
       //Lead variables        
        public string firstName;
        public string lastName;
        public string fullName;
    	public string phone;
        public string company;
        public string email;
        //public string fax;
        public integer boaOfferrdCost;
        public decimal currentSpend;
        //public string description;
        public decimal downTimeInHrs;
        public decimal existingCost;
        public decimal hydraulicOilUsage;
        public string industry;
        public decimal numberOfHose;
        public boolean flagcheck;
        public boolean rquestedDemo;
        public boolean viewBoaContactDetails;
        public decimal NoOfHydraulicEquipment;
        //public integer numberOfEmployee;
        //public string role;      
        
    }
    
    //For Outbound request
    public class pricingPolicyInfo{
    	public string salesforceId;
        public string customerReference;
        public string pricingPolicyName;
        public dateTime startDate;
        public dateTime endDate;
        public boolean priceMode;
        public boolean isActive;
        public boolean isFixedPolicy;
        public string notes;
		public List<pricingPolicyRulesInfo> pricingPolicyRulesWrap;        
    }
    
    //For Outbound request
    public class pricingPolicyRulesInfo{
        public string salesforceId;
        public dateTime startDate;
        public dateTime endDate;
        //public string pricingPolicyId;
        public decimal price;
        public string sellPriceBand;
        public string stockCode;
        public string stockPriceGrp;
        public decimal discount;
        public decimal minimumQuantity;
    }
    
    //For Outbound request
    public class PricingPolicyandPPRulesInfo{
        public pricingPolicyInfo pricingPolicyDetails;
        //public pricingPolicyRulesInfo pricingPRulesDetails;
        
        public PricingPolicyandPPRulesInfo(){
        	pricingPolicyDetails = new pricingPolicyInfo();
            //pricingPRulesDetails = new  pricingPolicyRulesInfo();
        }
    }    
    
    //For Outbound request
    public class pricingPolicyWithCustomer{
        public string salesforceId;
        public string Name;
        public string accountId;
        public string pricingPolicyId;
    }
    
    //For Outbound request when Customer is detached from Pricing Policy
    public class pricingPolicyWithCustomerUponDeletion{
        public string salesforceId;
    }
    
    //Orders related wrapper for outbound request
    public class orderDetails{
        //Order info variables
        public string salesforceId;
        public string name;
        public date closedDate;
        public date orderDate;
        public string curency;
        public string orderStage;
        //public string accountId;
        public string customerOrderNumber;
        public string reference;
        public decimal subTotal;
        public decimal taxTotal;
        public decimal orderTotal;
        public string defaultLocation;
        public boolean onHold;
        public string paymentType;
        public string transactionId;
        public string invoiceUrl;
        public List<orderLineItemDetails> orderProductsWrap;
        public addressWrapper address;
        
        /*public orderDetails(){
        	orderProductsWrap = new List<orderProducts>();
        }*/
    }
    
    public class orderLineItemDetails{
        //orderProducts variables
        public string salesforceId;
        public string stockitemId;
        public string lineitemdescription;
        public decimal quantity;
        public decimal suppliedQuantity;
        public decimal invoicedQuantity;
        public string description;
        public string discount;
        public decimal totalPrice;
        public decimal salesprice;
    }
    
    public class LeadTask{
        public string leadId;
        public string subject;
        public string owner;
        public date dueDate;
        public string description;
    }
    
    
    
    
    
    
    
}