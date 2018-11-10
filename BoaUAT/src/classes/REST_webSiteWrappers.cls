public class REST_webSiteWrappers {
    
    //wrapper to send products data to web site
    public class ProductToWebsiteWrapper {
        public string name;  //stockcode	
        public string slug;  //productDescription
        public string permalink; //web link, for Example - "https://hallio.digital/products/sales-hydraulic-fittings/3-8-bspp-female-x-3-8-ms355-ms360-1-piece-m-s-non-skive-tail/",
        public date date_created; //createddate in format - "2018-07-19T01:45:38"
        public date date_created_gmt; // createddate in GMT format "2018-07-18T13:45:38"
        public date date_modified;  //lastmodifieddate in format "2018-07-19T01:57:06",
        public date date_modified_gmt; //lastmodifieddate in gmt format "2018-07-18T13:57:06",
        public string type; //hard coded values always = "external",
        public string status; //hard coded value always = "publish"
        public boolean featured; // hard coded value always = false,
        public string catalog_visibility; //hard coded value always = "visible",
        public string description; //long description not with salesforce yet
        public string short_description; // question - should be stock description from stock item?
        public string sku; // is it stock code ? 
        public string regular_price; //kept variable ..SF wont send pricing data, will be blank always
        public string sale_price; //kept variable ..SF wont send pricing data, will be blank always
        public string total_sales; //kept variable ..SF wont send pricing data, will be blank always
       	public string WordPress_Id;
        // public boolean virtual; //hard coded value always false
       								//commented for now, as it was causing an issue with SF reserved key words..need to check
        public boolean downloadable; //hard coded value always false
        public string external_url; //what value is to be sent ? "https://centelon.com"
        public string button_text; // do we need this to come from SF ? -"Buy Now" 
        public boolean in_stock;  //hard coded value always true
        public string backorders; //hard coded value always = "no"
        public boolean backorders_allowed; //hard coded value always = false
        public boolean backordered; //hard coded value always =  false,
        public boolean sold_individually; //hard coded value always =  true,
        public string weight; // will send weight field from stock Item
        public boolean reviews_allowed; //hard coded value always =  false,
        public string average_rating; //hard coded value always = "0.00",
        public integer rating_count; //hard coded value always =  0,
        public list<string> related_ids; //will send blank list of string always ..but do we need this ?
        public integer parent_id; //hard coded value always =  0,
        public string purchase_note; //hard coded value always = blank
        public integer menu_order; //will default send as 0 ;
        //New Fields
        /*public string prefixThread1;
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
        public string h2;*/
        
        //categories
        public list<productToWebsiteCategories> categories;
        
        //tags list
        public list<string> tags;   //sending blank list
        
        //images 
        public list<productToWebsiteImages> images;
        
        //product dimensions
        public list<productToWebsiteAttributes> attributes;
        
        //default attributes
        public list<string> default_attributes;  //sending blank list
        
        //variations
        public list<string> variations;   //sending blank list
        
        //grouped_products
        public list<string> grouped_products;    //sending blank list
        
        //_links
        public productToWebsite_links links;  //not sure what to send here,  need to ask GC.
        									  //variable name changed form _link to link..need to check	
        
        //instantiation
        public ProductToWebsiteWrapper(){
            related_ids = new list<string>();
            categories = new list<productToWebsiteCategories>();
            tags = new list<string>();
            images = new list<productToWebsiteImages>();
            attributes = new list<productToWebsiteAttributes>();
            default_attributes = new list<string>();
            variations = new list<string>();
            grouped_products = new list<string>();
            links = new productToWebsite_links();
            
            
            
        }
    }
    
    
    public class productToWebsiteCategories{
        public string name; // name of category
        //public string slug; //name of category
        public string id;
        
    }
    
    public class productToWebsiteImages{
        public string src; //image link
        public string name; // image name, mostly hard coded from SF side
        public string alt; // SF doesnt have alt text , will be blank always
        public integer position; //has to be incremental ..starting from 0
        
        
    }	
    
    
    public class productToWebsiteAttributes{
        //public string id;
        public string name; //dimension type name, for example - nominal pipe size	
        public integer position; //has to be incremental ..starting from 0
        public boolean visible; // hardcoded as true
        public boolean variation; // hardcoded as false
        public list<string> options; // actual value to be sent as list of string
        
        //instatiation
        public productToWebsiteAttributes(){
            options = new list<string>();
        }
    }
    
    
    public class productToWebsite_links{
        public list<productToWebsite_self> self;
        public list<productToWebsite_collection> collection;
        
        //instantiation
        public productToWebsite_links(){
            self = new list <productToWebsite_self>();
            collection = new list <productToWebsite_collection>();
        }
        
    }
    
    public class productToWebsite_self{
        public string href;
    }
    
    public class productToWebsite_collection{
        public string href;	
    }	
    // for Parsing response from Web Site
    public class stockItemList{
        public stockItem stockDetails;
        
        /*public stockItemList(){
         	stockDetails = new List<stockItem>();   
        }*/
    }
    
    public class stockItem{
        public string stockItemId;
        public string stockName;
        //public string salesforceId;
    }
}