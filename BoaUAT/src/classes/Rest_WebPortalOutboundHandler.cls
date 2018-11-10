/*
* Description - Class handles outbound methods for web portal operations in salesforce.
* Author - Centelon Team 
*/

public class Rest_WebPortalOutboundHandler {
    
    //method to send contact level updates to web Portal
    public static void SendContactupdatesToPortal(list<id> contactIds){
        try{
            //fetching contact + customer information
            list<contact> contactList = [select id,salutation,firstname,lastname,email,mobilePhone,otherPhone,Role__c,active__c,account.name,accountId,account.industry,
                                         account.email__c,account.phone,account.region__c,account.currencyIsoCode,account.base_price__c,account.credit_limit__c,
                                         account.stop_credit__c,account.isActive__c,account.Allow_Restricted_Goods__c,account.Open_Item__c,account.Need_Order_Number__c,
                                         account.billingstreet,account.billingCity,account.billingState,account.billingCountry,account.billingPostalCode,
                                         account.shippingstreet,account.shippingCity,account.shippingState,account.shippingCountry,account.shippingPostalCode,
                                         account.Total_Saving__c,account.Current_Spend__c,account.Hydraulic_Oil_Usage_ltrs__c,account.Down_Time_in_Hrs_per_month__c,
                                         account.override_GST_rate__c from contact where id IN: contactIds AND Active__c = true];
            
            if(!contactList.isEmpty()) {
                set<id> customerIds = new set<id>();
                map<id,list<delivery_address__c>> customerIdTodeliveryAddresses = new map<id,list<delivery_address__c>>();
                //declaring list of resposne wrapper
                list<Rest_WebPortalWrappers.accountAndContactinfo> customerNContactDetails = new list<Rest_WebPortalWrappers.accountAndContactinfo>();
                
                for(contact con: contactList){
                    customerIds.add(con.accountId);
                }
                
                //fetching delivery addresses for all the customers    
                list<delivery_address__c> deliveryAddresses = [select id,customers__c,street__c,city__c,state__c,country__c,postal_code__c,is_primary__c 
                                                               from delivery_address__c where customers__c IN:customerIds];
                
                //populating map of delivery addresses to customer
                if(!deliveryAddresses.isEmpty()){
                    for(delivery_address__c da: deliveryAddresses){
                        //if customer is very new to our map, its first entry
                        if(!customerIdTodeliveryAddresses.containsKey(da.customers__c)){
                            list<delivery_address__c> dalist = new list<delivery_address__c>();
                            dalist.add(da);
                            customerIdTodeliveryAddresses.put(da.customers__c,dalist);
                        }else{
                            list<delivery_address__c> dalist = new list<delivery_address__c>();
                            //refurbishing the list
                            dalist = customerIdTodeliveryAddresses.get(da.customers__c);
                            dalist.add(da);
                            customerIdTodeliveryAddresses.put(da.customers__c,dalist);
                        }
                    }
                    
                }
                
                for(contact con: contactList){
                    Rest_WebPortalWrappers.accountAndContactinfo customerNContactInfo = new Rest_WebPortalWrappers.accountAndContactinfo(); 
                    list<Rest_WebPortalWrappers.addressWrapper> customerDeliveryaddressList = new list<Rest_WebPortalWrappers.addressWrapper>();
                    //filling up customer details
                    customerNContactInfo.customerDetails.salesforceId = con.accountId;
                    customerNContactInfo.customerDetails.name = con.account.Name;
                    customerNContactInfo.customerDetails.email = con.account.Email__c;
                    customerNContactInfo.customerDetails.phone = con.account.phone;
                    //filling web calculator info
                    customerNContactInfo.customerDetails.overrideGSTRate = SFToExoIntegrationUtility.getPicklistLabel('account','override_GST_rate__c',con.account.override_GST_rate__c);
                    customerNContactInfo.customerDetails.downTimeInHrsPerMonth = con.account.Down_Time_in_Hrs_per_month__c;
                    customerNContactInfo.customerDetails.hydraulicOilUsage = con.account.Hydraulic_Oil_Usage_ltrs__c;
                    customerNContactInfo.customerDetails.currentSpend = con.account.Current_Spend__c;                    
                    customerNContactInfo.customerDetails.totalSaving = con.account.Total_Saving__c;
                    //getting picklist label
                    customerNContactInfo.customerDetails.region = SFToExoIntegrationUtility.getPicklistLabel('account','region__c',con.account.region__c);
                    customerNContactInfo.customerDetails.industry = con.account.Industry;
                    customerNContactInfo.customerDetails.currencyCode = con.account.CurrencyIsoCode;
                    //getting picklist label
                    customerNContactInfo.customerDetails.basePriceGroup = SFToExoIntegrationUtility.getPicklistLabel('account','base_price__c',con.account.base_price__c);
                    customerNContactInfo.customerDetails.CreditLimit = con.account.credit_limit__c;
                    customerNContactInfo.customerDetails.StopCredit = con.account.stop_credit__c;
                    customerNContactInfo.customerDetails.IsActive = con.account.isActive__c;
                    customerNContactInfo.customerDetails.AllowRestrictedGoods = con.account.allow_restricted_goods__C;
                    customerNContactInfo.customerDetails.IsOpenItem = con.account.open_item__c;
                    customerNContactInfo.customerDetails.NeedOrderNumber = con.account.need_order_number__c;
                    customerNContactInfo.customerDetails.PostalAddress.street = con.account.billingstreet;
                    customerNContactInfo.customerDetails.PostalAddress.city = con.account.billingCity;
                    customerNContactInfo.customerDetails.PostalAddress.state = con.account.billingstate;
                    customerNContactInfo.customerDetails.PostalAddress.country = con.account.billingcountry;
                    customerNContactInfo.customerDetails.PostalAddress.postalCode = con.account.billingpostalCode;
                    
                    //filling up first delivery address from customer level
                    
                    //adding it to a list of delivery addresses if delivery address on account exists
                    /*if(string.isNotBlank(con.account.shippingstreet) && string.isNotBlank(con.account.shippingCity)){
                        Rest_WebPortalWrappers.addressWrapper primaryDeliveryaddress = new Rest_WebPortalWrappers.addressWrapper();
                        primaryDeliveryaddress.street = con.account.shippingstreet;
                        primaryDeliveryaddress.city = con.account.shippingcity;
                        primaryDeliveryaddress.state = con.account.shippingstate;
                        primaryDeliveryaddress.country = con.account.shippingcountry;
                        primaryDeliveryaddress.postalCode = con.account.shippingPostalCode;
                        primaryDeliveryaddress.isPrimary = true;
                        customerDeliveryaddressList.add(primaryDeliveryaddress);    
                    }*/
                    
                    //looping in delivery address list to fill up other delivery addresses than primary
                    if(customerIdTodeliveryAddresses.containsKey(con.accountId)){
                        for(delivery_address__c da: customerIdTodeliveryAddresses.get(con.AccountId)){
                            Rest_WebPortalWrappers.addressWrapper otherDeliveryaddress = new Rest_WebPortalWrappers.addressWrapper();
                            otherDeliveryaddress.salesforceId = da.Id;
                            otherDeliveryaddress.street = da.Street__c;
                            otherDeliveryaddress.city = da.City__c;
                            otherDeliveryaddress.state = da.State__c;
                            otherDeliveryaddress.country = da.Country__c;
                            otherDeliveryaddress.postalCode = da.Postal_Code__c;
                            // by default marking isPrimary as false and not relying on delivery address objetc field. 
                            otherDeliveryaddress.isPrimary = da.Is_Primary__c;
                            customerDeliveryaddressList.add(otherDeliveryaddress);
                        }
                    }
                    
                    // now, adding primary delivery address list on customerDetails wrapper level
                    customerNContactInfo.customerDetails.deliveryAddress = customerDeliveryaddressList; 
                    
                    // filling up contact level details
                    customerNContactInfo.contactDetails.salesforceId = con.Id;
                    customerNContactInfo.contactDetails.salutation = con.Salutation;
                    customerNContactInfo.contactDetails.firstName = con.FirstName;
                    customerNContactInfo.contactDetails.lastName = con.LastName;
                    customerNContactInfo.contactDetails.email = con.Email;
                    customerNContactInfo.contactDetails.mobileNumber = con.MobilePhone;
                    customerNContactInfo.contactDetails.officePhoneNumber = con.OtherPhone;    
                    customerNContactInfo.contactDetails.userRole = con.Role__c;
                    customerNContactInfo.contactDetails.isActive = con.Active__c;
                    
                    //adding to customerNContactDetails final wrapper
                    customerNContactDetails.add(customerNContactInfo);
                }
                
                system.debug('json String--'+Json.serialize(customerNContactDetails[0]));
                
                //* intially method was designed to send bulk conatct updates to web portal, but now we are sending
                //* only 1 instance at a time, hence sending list[0] index, if we need enabale bulk update in future,
                //* then simply send full list to external system 
                
                //sending out a request 
                Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
                
                responseWrapper = Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/user/activate','',Json.serialize(customerNContactDetails[0]));
                // in case access token is expired.. retry one more time with new token
                if(responseWrapper.responseCode == 400 || responseWrapper.responseCode == 404 || responseWrapper.responseCode == 401){
                    string accessToken = Rest_outboundCaller.loginToWebPortal();
                    Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/user/activate',accessToken,Json.serialize(customerNContactDetails[0]));
                    Rest_outboundCaller.updatewebportalAccessToken(accessToken);
                    
                }
            }
            
            
        }catch(exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebPortalOutboundHandler.SendContactupdatesToPortal',e.getLineNumber());    
        }
    }
    
    
    //method to send product level updates to web Portal
    @InvocableMethod
    public static void sendProductDetailsToPortal(list<id> stockitemids){
        try{
            system.debug('stockitemids ' + stockitemids);
            List<Product2> stockItemList1 = [SELECT Id,Name,ProductCode,Primary_Group__c,Secondary_Group__c,Tertiary_Group__c FROM Product2 WHERE Id IN :stockitemids];
            String soql = 'SELECT Id,Name,UnitPrice,Product2Id,PriceBook2Id,Product2.Name,Product2.ProductCode,Product2.Description,';
            soql += 'Product2.Primary_Group__c,Product2.Secondary_Group__c,Product2.Tertiary_Group__c,Product2.Product_Family__c,';
            soql += 'Product2.Price_Group__c,Product2.Stock_Classification__c,Product2.barcode1__c,Product2.barcode2__c,Product2.barcode3__c,';
            soql += 'Product2.QuantityUnitOfMeasure__c,Product2.Weight__c,Product2.Cubic_del__c,Product2.IsActive,Product2.isLookup__c,';
            soql += 'Product2.isRestricted_Goods__c,Product2.Discountable__c,product2.stock_image_1__c,product2.stock_image_2__c,product2.stock_image_3__c,';
            soql += 'Retail_Price__c,Contractor_Price__c,Trade_Price__c,Wholesale_Price__c,Dealer_Price__c,Bulk_Buy_Price__c,currencyISOCOde,';	
            
            String stockItem = '';
            
            stockitem += 'product2.Family_Level_Description__c,Product2.Prefix_Thread_1_ID__c,Product2.Identifier_related_info_Thread_2_ID__c,Product2.Collated_Identifier__c,Product2.Thread_3_ID_SS_adaptor__c,Product2.DKOL_DKOS__c,';
            stockitem += 'Product2.Thread_Color_Code__c,Product2.Thread_Type_Filter_1__c,Product2.Thread_Type_Filter_2__c,Product2.Male_Female_Flange_Fitting_Only__c,Product2.Suits_Hose__c,Product2.Show_on_WebPortal__c,';
            stockitem += 'Product2.LC_Length__c,Product2.LD_Drop__c,Product2.H1__c,Product2.H2_Nut_Size__c,Product2.Dash_Size_1__c,Product2.Dash_Size_2__c,Product2.Dash_Size_3__c,Product2.Dash_Size_4__c,';                       
            
            stockitem += 'Product2.Nominal_Size_mm__c,Product2.Max_Work_Pressure_PSI__c,Product2.Min_Burst_Pressure_Male_PSI__c,Product2.Min_Burst_Pressure_Coupled_PSI__c,Product2.Rated_Flow_L_min__c,Product2.Max_Flow_L_Min__c,Product2.Min_Burst_Pressure_Female_PSI__c,Product2.Fluid_Spillage_cc__c,';		    
            
            stockitem += 'Product2.Hose_Inner_Diameter_Inches__c,Product2.Hose_Inner_Diameter_mm__c,Product2.Working_Pressure_PSI__c,Product2.Working_Pressure_BAR__c,Product2.Full_Coil_Size_metre__c,Product2.Hose_Outer_Diameter_mm__c,Product2.Minimum_Bend_Radius_mm__c,';    
            stockitem += 'Product2.Primary_Group_Display_Name__c,Product2.Secondary_Group_Display_Name__c,Product2.Tertiary_Group_Display_Name__c,Product2.Product_Family_Display_Name__c,';
            
            stockitem += 'Product2.Shortened_Code__c,Product2.Nominal_Thread_Size_1__c,Product2.Nominal_Thread_Size_2__c,Product2.Nominal_Thread_Size_3__c,Product2.Nominal_Thread_Size_4__c,Product2.Physical_Thread_Size_1__c,Product2.physical_thread_size_2__c,Product2.Physical_Thread_Size_3__c,Product2.Physical_Thread_Size_4__c,Product2.Thread_Type_1__c,Product2.Thread_Type_2__c,Product2.Thread_Type_3__c,Product2.Thread_Type_4__c,Product2.Orientation__c,Product2.Tail_Size_To_Suit_Hose_ID__c,Product2.Nominal_Pipe_Size__c';   
            
            
            soql = soql + stockitem + ' FROM PriceBookEntry WHERE Product2Id IN :stockItemIds AND Product2.Bill_of_Material__c = false and Product2.is_Hydraulic_Product__c = true AND PriceBook2.IsStandard=true AND currencyISOCode = \'NZD\'';
            List<PriceBookEntry> pbeList = Database.query(soql);
            List<Rest_WebPortalWrappers.priceBookEntryInfo> priceBookInfoList = new List<Rest_WebPortalWrappers.priceBookEntryInfo>();
		    system.debug('pbeList ' + pbeList);        
            for(PriceBookEntry pbe : pbeList){
                Rest_WebPortalWrappers.priceBookEntryInfo priceBookDetails = new Rest_WebPortalWrappers.priceBookEntryInfo(); 
                //price book entry variables
                priceBookDetails.priceBookEntryId = pbe.id;                
                //Populating StockItem variables
                priceBookDetails.stockCode = pbe.Product2.name;
                priceBookDetails.stockDescription = pbe.Product2.productCode;
                priceBookDetails.primarygrp = SFToExoIntegrationUtility.getPicklistLabel('product2','Primary_Group__c',pbe.Product2.Primary_Group__c);
                priceBookDetails.secondarygrp = SFToExoIntegrationUtility.getPicklistLabel('product2','Secondary_Group__c',pbe.Product2.Secondary_Group__c); 
                priceBookDetails.tertiarygrp = SFToExoIntegrationUtility.getPicklistLabel('product2','Tertiary_Group__c',pbe.Product2.Tertiary_Group__c);
                priceBookDetails.productfamily = pbe.Product2.Product_Family__c;
                priceBookDetails.pricegrp = SFToExoIntegrationUtility.getPicklistLabel('product2','Price_Group__c',pbe.Product2.Price_Group__c);
                priceBookDetails.stockclassification = SFToExoIntegrationUtility.getPicklistLabel('product2','Stock_Classification__c',pbe.Product2.Stock_Classification__c);
                priceBookDetails.barcode1 = pbe.Product2.barcode1__c;
                priceBookDetails.barcode2 = pbe.Product2.barcode2__c;
                priceBookDetails.barcode3 = pbe.Product2.barcode3__c;
                priceBookDetails.stockImage1 = pbe.product2.stock_image_1__c;
                priceBookDetails.stockImage2 = pbe.product2.stock_image_2__c;
                priceBookDetails.stockImage3 = pbe.product2.stock_image_3__c;
                priceBookDetails.familyDescription = pbe.product2.Family_Level_Description__c;
                priceBookDetails.shortenedCode = pbe.product2.Shortened_Code__c;
                priceBookDetails.showOnWebPortal = pbe.Product2.Show_on_WebPortal__c;
                priceBookDetails.pack = SFToExoIntegrationUtility.getPicklistLabel('product2','QuantityUnitOfMeasure__c',pbe.Product2.QuantityUnitOfMeasure__c);
                //stock item flags
                priceBookDetails.isActive = pbe.Product2.IsActive;
                priceBookDetails.lookup = pbe.Product2.isLookup__c;
                priceBookDetails.restrictedgoods = pbe.Product2.isRestricted_Goods__c;
                priceBookDetails.discountable = pbe.Product2.Discountable__c;
                priceBookDetails.primaryGrpDisplayName = pbe.Product2.Primary_Group_Display_Name__c;
                priceBookDetails.secondaryGrpDisplayName = pbe.Product2.Secondary_Group_Display_Name__c;
                priceBookDetails.tertiaryGrpDisplayName = pbe.Product2.Tertiary_Group_Display_Name__c;
                priceBookDetails.productFamilyDisplayName = pbe.Product2.Product_Family_Display_Name__c;
                
                //adapters and fittings dimensions
                if(pbe.product2.Secondary_Group__c == '15' || pbe.product2.Secondary_Group__c == '17'){
                    priceBookDetails.productDimensions.nominalThreadSize1 = pbe.Product2.Nominal_Thread_Size_1__c;
                    priceBookDetails.productDimensions.nominalThreadSize2 = pbe.Product2.Nominal_Thread_Size_2__c;
                    priceBookDetails.productDimensions.nominalThreadSize3 = pbe.Product2.Nominal_Thread_Size_3__c;
                    priceBookDetails.productDimensions.nominalThreadSize4 = pbe.Product2.Nominal_Thread_Size_4__c;
                    priceBookDetails.productDimensions.physicalThreadSize1 = pbe.Product2.Physical_Thread_Size_1__c;
                    priceBookDetails.productDimensions.physicalThreadSize2 = pbe.Product2.Physical_Thread_Size_2__c;
                    priceBookDetails.productDimensions.physicalThreadSize3 = pbe.Product2.Physical_Thread_Size_3__c;
                    priceBookDetails.productDimensions.physicalThreadSize4 = pbe.Product2.Physical_Thread_Size_4__c;
                    priceBookDetails.productDimensions.threadType1 = pbe.Product2.Thread_Type_1__c;
                    priceBookDetails.productDimensions.threadType2 = pbe.Product2.Thread_Type_2__c;
                    priceBookDetails.productDimensions.threadType3 = pbe.Product2.Thread_Type_3__c;
                    priceBookDetails.productDimensions.threadType4 = pbe.Product2.Thread_Type_4__c;
                    priceBookDetails.productDimensions.orientation = SFToExoIntegrationUtility.getPicklistLabel('product2','Orientation__c',pbe.Product2.Orientation__c);
                    priceBookDetails.productDimensions.tailSizeToSuitHoseID = pbe.Product2.Tail_Size_To_Suit_Hose_ID__c;
                    priceBookDetails.productDimensions.nominalPipeSize = pbe.Product2.Nominal_Pipe_Size__c;
                    priceBookDetails.productDimensions.fullCoilSizeMetre = pbe.Product2.Full_Coil_Size_metre__c;
                }
                //hose dimensions
                if(pbe.product2.Secondary_Group__c == '2'){
                    //priceBookDetails.productDimensions.hoseInnerDiameterinches = pbe.Product2.Hose_Inner_Diameter_Inches__c;
                    //priceBookDetails.productDimensions.hoseInnerDiameterMM = pbe.Product2.Hose_Inner_Diameter_mm__c;
                    priceBookDetails.productDimensions.workingPressurePSI = pbe.Product2.Working_Pressure_PSI__c;
                    //priceBookDetails.productDimensions.hoseOuterDiameterMM = pbe.Product2.Hose_Outer_Diameter_mm__c;
                    priceBookDetails.productDimensions.workingPressureBAR = pbe.Product2.Working_Pressure_BAR__c;
                    priceBookDetails.productDimensions.minimumBendRadiusMM = pbe.Product2.Minimum_Bend_Radius_mm__c;
                    priceBookDetails.productDimensions.fullCoilSizeMetre = pbe.Product2.Full_Coil_Size_metre__c;
                }
                //flange-ClampDimensions...condition needs to be identified ans enter here
                if(pbe.product2.Secondary_Group__c == ' '){
                    priceBookDetails.productDimensions.b = pbe.Product2.b_in__c ;
                    priceBookDetails.productDimensions.d = pbe.Product2.d_in__c;
                    priceBookDetails.productDimensions.e = pbe.Product2.e_in__c;
                    priceBookDetails.productDimensions.h = pbe.Product2.h_in__c;
                    priceBookDetails.productDimensions.kDrillDiameter = pbe.Product2.K_DRILL_DIA_in__c;
                    priceBookDetails.productDimensions.l = pbe.Product2.l_in__c;
                    priceBookDetails.productDimensions.m = pbe.Product2.m_in__c;
                    priceBookDetails.productDimensions.n = pbe.Product2.n_in__c;
                    priceBookDetails.productDimensions.y = pbe.Product2.y_in__c;
                    priceBookDetails.productDimensions.fullCoilSizeMetre = pbe.Product2.Full_Coil_Size_metre__c;
                }
                //QRC Dimensions
                if(pbe.product2.Secondary_Group__c == '20'){
                    priceBookDetails.productDimensions.nominalSizeMM = pbe.Product2.Nominal_Size_mm__c;
                    priceBookDetails.productDimensions.ratedFlow = pbe.Product2.Rated_Flow_L_min__c;
                    priceBookDetails.productDimensions.maxWorkpressurePSI = pbe.Product2.Max_Work_Pressure_PSI__c;
                    priceBookDetails.productDimensions.maxFlow = pbe.Product2.Max_Flow_L_Min__c;
                    priceBookDetails.productDimensions.minBurstPressureMalePSI = pbe.Product2.Min_Burst_Pressure_Male_PSI__c;
                    priceBookDetails.productDimensions.minBurstPressureFemalePSI = pbe.Product2.Min_Burst_Pressure_Female_PSI__c;
                    priceBookDetails.productDimensions.minBurstPressureCoupledPSI = pbe.Product2.Min_Burst_Pressure_Coupled_PSI__c;
                    priceBookDetails.productDimensions.fluidSpillageCC = pbe.Product2.Fluid_Spillage_cc__c;
                    priceBookDetails.productDimensions.fullCoilSizeMetre = pbe.Product2.Full_Coil_Size_metre__c;
                }
                //New dimesions
                //priceBookDetails.productDimensions.primaryGrpDisplayName = pbe.Product2.Hose_Inner_Diameter_Inches__c;
                //priceBookDetails.productDimensions.secondaryGrpDisplayName  = pbe.Product2.Hose_Inner_Diameter_Inches__c;
                //priceBookDetails.productDimensions.tertiaryGrpDisplayName  = pbe.Product2.Hose_Inner_Diameter_Inches__c;
                //priceBookDetails.productDimensions.productFamilyDisplayName  = pbe.Product2.Hose_Inner_Diameter_Inches__c;
                priceBookDetails.productDimensions.hoseInnerDiameterinches = pbe.Product2.Hose_Inner_Diameter_Inches__c;
                priceBookDetails.productDimensions.hoseInnerDiameterMM = pbe.Product2.Hose_Inner_Diameter_mm__c;
                priceBookDetails.productDimensions.hoseOuterDiameterMM = pbe.Product2.Hose_Outer_Diameter_mm__c;
                priceBookDetails.productDimensions.prefixThread1 = pbe.Product2.Prefix_Thread_1_ID__c;
                priceBookDetails.productDimensions.identifierRelatedinfoThread2ID = pbe.Product2.Identifier_related_info_Thread_2_ID__c;
                priceBookDetails.productDimensions.collatedIdentifier = pbe.Product2.Collated_Identifier__c;
                priceBookDetails.productDimensions.Thread3IDSSadaptor = pbe.Product2.Thread_3_ID_SS_adaptor__c;
                priceBookDetails.productDimensions.DKOLDKOS = pbe.Product2.DKOL_DKOS__c;
                //priceBookDetails.productDimensions.exoDescription = pbe.Product2.Exo_Description__c;
                priceBookDetails.productDimensions.threadColourCode = pbe.Product2.Thread_Color_Code__c;
                priceBookDetails.productDimensions.threadTypeFilter1 = pbe.Product2.Thread_Type_Filter_1__c;
                priceBookDetails.productDimensions.threadTypeFilter2 = pbe.Product2.Thread_Type_Filter_2__c;
                priceBookDetails.productDimensions.maleFemaleFlangeFittingOnly = pbe.Product2.Male_Female_Flange_Fitting_Only__c;
                priceBookDetails.productDimensions.suitsHose = pbe.Product2.Suits_Hose__c;
                priceBookDetails.productDimensions.lc = pbe.Product2.LC_Length__c;
                priceBookDetails.productDimensions.ld = pbe.Product2.LD_Drop__c;
                priceBookDetails.productDimensions.h1 = pbe.Product2.H1__c;
                priceBookDetails.productDimensions.h2 = pbe.Product2.H2_Nut_Size__c;
                priceBookDetails.productDimensions.dashSize1 = pbe.Product2.Dash_Size_1__c;
                priceBookDetails.productDimensions.dashSize2 = pbe.Product2.Dash_Size_2__c;
                priceBookDetails.productDimensions.dashSize3 = pbe.Product2.Dash_Size_3__c;
                priceBookDetails.productDimensions.dashSize4 = pbe.Product2.Dash_Size_4__c;
                //price related information
                priceBookDetails.productPrices.retailPrice = pbe.Retail_Price__c;
                priceBookDetails.productPrices.contractorPrice = pbe.Contractor_Price__c;
                priceBookDetails.productPrices.tradePrice = pbe.Trade_Price__c;
                priceBookDetails.productPrices.wholesalePrice = pbe.Wholesale_Price__c;
                priceBookDetails.productPrices.dealerPrice = pbe.Dealer_Price__c;
                priceBookDetails.productPrices.bulkBuyPrice = pbe.Bulk_Buy_Price__c;
                priceBookDetails.productPrices.currencyCode = pbe.currencyISOCOde;
                
                
                priceBookInfoList.add(priceBookDetails);
            }
            
            Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
            system.debug('product data--'+Json.serialize(priceBookInfoList));
            responseWrapper = Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/product','',Json.serialize(priceBookInfoList));
            // in case access token is expired.. retry one more time with new token
            if(responseWrapper.responseCode == 400 || responseWrapper.responseCode == 401){
                string accessToken = Rest_outboundCaller.loginToWebPortal();
                Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/product',accessToken,Json.serialize(priceBookInfoList));
                Rest_outboundCaller.updatewebportalAccessToken(accessToken);                
            }
        }
        catch(Exception e){
        	errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebPortalOutboundHandler.sendProductDetailsToPortal',e.getLineNumber());    
        }        
        
    }
    
    //method to send Pricing policy and pricing policy rules updates to web Portal
    public static void sendPricingPolicyDetailsToWebPortal(list<id> pricingpolicyIds){
        //List<Rest_WebPortalWrappers.pricingPolicyInfo> pricingPolicyAndRulesDetails = new List<Rest_WebPortalWrappers.pricingPolicyInfo>();
        try{
            List<Pricing_Policy__c> ppList = [SELECT Id,Name,Start_Date__c,End_Date__c,IS_Active__c,Is_Fixed_Policy__c,Notes__c,Price_Mode__c,Customer_Reference__c FROM Pricing_Policy__c WHERE Id IN :pricingpolicyIds];
            Set<Id> ppIds = new Set<Id>();
            Map<Id,List<Pricing_Policy_Rules__c>> PricingPplicyToPPRulesMap = new Map<Id,List<Pricing_Policy_Rules__c>>();
            if(!ppList.isEmpty()){
                for(Pricing_Policy__c pp : ppList){
                    ppIds.add(pp.Id);    
                }		    
            }
            
            //Fetching Pricing policy rules
            List<Pricing_Policy_Rules__c> ppRulesList = [SELECT Id,StockCode__c,StockCode__r.Name,Name,Pricing_Policy__c,Discount__c,Minimum_Quantity__c,Price__c,Sell_Price_Band__c,Start_Date__c,Stock_Code__c,Stock_Price_Group__c,Stop_Date__c FROM Pricing_Policy_Rules__c WHERE Pricing_Policy__c IN :ppIds];
            //Popuating map
            if(!ppRulesList.isEmpty()){
                for(Pricing_Policy_Rules__c ppr : ppRulesList){
                    if(PricingPplicyToPPRulesMap.containsKey(ppr.Pricing_Policy__c)){
                        PricingPplicyToPPRulesMap.get(ppr.Pricing_Policy__c).add(ppr);
                        //System.debug('in the loop ' +PricingPplicyToPPRulesMap);
                    }else{
                        List<Pricing_Policy_Rules__c> pprList = new List<Pricing_Policy_Rules__c>();
                        pprList.add(ppr);
                        //System.debug('in another loop pprList' +pprList);
                        PricingPplicyToPPRulesMap.put(ppr.Pricing_Policy__c,pprList);
                    } 
                }	    
            }
            //system.debug('map--values'+PricingPplicyToPPRulesMap);
            
            List<Rest_WebPortalWrappers.pricingPolicyInfo> pricingPolicyAndRulesDetails = new List<Rest_WebPortalWrappers.pricingPolicyInfo>();
            for(Pricing_Policy__c pp : ppList){
                Rest_WebPortalWrappers.pricingPolicyInfo ppInfo = new Rest_WebPortalWrappers.pricingPolicyInfo();
                List<Rest_WebPortalWrappers.pricingPolicyRulesInfo> ppRInfo = new List<Rest_WebPortalWrappers.pricingPolicyRulesInfo>();
                //Rest_WebPortalWrappers.pricingPolicyIdWrapper ppIdInfo = new Rest_WebPortalWrappers.pricingPolicyIdWrapper();
                ppInfo.salesforceId = pp.Id;
                ppInfo.pricingPolicyName = pp.Name;
                ppInfo.customerReference = pp.Customer_Reference__c;
                ppInfo.startDate = pp.Start_Date__c;
                ppInfo.endDate = pp.End_Date__c;
                ppInfo.priceMode = pp.Price_Mode__c;
                ppInfo.isActive = pp.IS_Active__c;
                ppInfo.isFixedPolicy  = pp.Is_Fixed_Policy__c;
                ppInfo.notes = pp.Notes__c;
                //ppIdInfo.ppId = pp.Id;
                if(PricingPplicyToPPRulesMap.containsKey(pp.Id)){
                    for(Pricing_Policy_Rules__c ppr : PricingPplicyToPPRulesMap.get(pp.Id)){
                        Rest_WebPortalWrappers.pricingPolicyRulesInfo ppRDetails = new Rest_WebPortalWrappers.pricingPolicyRulesInfo();
                        ppRDetails.salesforceId = ppr.Id;
                        ppRDetails.startDate = ppr.Start_Date__c;
                        ppRDetails.endDate = ppr.Stop_Date__c;
                        ppRDetails.price = ppr.Price__c;
                        ppRDetails.minimumQuantity = ppr.Minimum_Quantity__c;
                        //ppRDetails.sellPriceBand = SFToExoIntegrationUtility.getPicklistLabel('Pricing_Policy_Rules__c','Sell_Price_Band__c',ppr.Sell_Price_Band__c);
                        ppRDetails.stockCode = ppr.StockCode__r.Name;
                        ppRDetails.stockPriceGrp = SFToExoIntegrationUtility.getPicklistLabel('Pricing_Policy_Rules__c','Stock_Price_Group__c',ppr.Stock_Price_Group__c);
                        ppRDetails.discount = ppr.Discount__c;
                        //ppIdInfo.pprId = ppr.Id;
                        ppRInfo.add(ppRDetails);                
                        
                    }    
                }
                
                //Adding ids to list
                //ppIdWrapList.add(ppIdInfo);
                
                ppInfo.pricingPolicyRulesWrap = ppRInfo;
                pricingPolicyAndRulesDetails.add(ppInfo);
            } 
            
            system.debug('map-- values '+PricingPplicyToPPRulesMap);
            //sending out a request 
            Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
            
            responseWrapper = Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/pricingPolicy','',Json.serialize(pricingPolicyAndRulesDetails[0]));
            // in case access token is expired.. retry one more time with new token
            if(responseWrapper.responseCode == 400 || responseWrapper.responseCode == 404){
                string accessToken = Rest_outboundCaller.loginToWebPortal();
                Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/pricingPolicy',accessToken,Json.serialize(pricingPolicyAndRulesDetails[0]));
                Rest_outboundCaller.updatewebportalAccessToken(accessToken);
                
            }            
            
        }       
        catch(Exception e){
        	
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebPortalOutboundHandler.sendPricingPolicyDetailsToWebPortal',e.getLineNumber());    
        }
        
        //return pricingPolicyAndRulesDetails;
    }
    
    //method to send Pricing policy with Customer updates to web Portal
    public static void sendCustomerWithPricingPolicyToPortal(List<Id> pricingPolicyWithCustomer){
        system.debug('Delete...');
        List<Rest_WebPortalWrappers.pricingPolicyWithCustomer> ppWithCustomerInfoList = new List<Rest_WebPortalWrappers.pricingPolicyWithCustomer>();
        try{
            List<Pricing_Policy_with_Customer__c> ppWithCustomerList = [SELECT Id, Name, Customers__c, Pricing_Policy__c FROM Pricing_Policy_with_Customer__c WHERE Id IN :pricingPolicyWithCustomer];
            if(!ppWithCustomerList.isEmpty()){
                for(Pricing_Policy_with_Customer__c ppCust : ppWithCustomerList){
                    Rest_WebPortalWrappers.pricingPolicyWithCustomer ppWithCustomerInfo = new Rest_WebPortalWrappers.pricingPolicyWithCustomer();
                    ppWithCustomerInfo.salesforceId = ppCust.Id;
                    ppWithCustomerInfo.Name = ppCust.Name;
                    ppWithCustomerInfo.accountId = ppCust.Customers__c;
                    ppWithCustomerInfo.pricingPolicyId  = ppCust.Pricing_Policy__c;
                    ppWithCustomerInfoList.add(ppWithCustomerInfo);
                }    
            }
            
            //sending out a request 
            Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
            
            responseWrapper = Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/attachPricingPolicy','',Json.serialize(ppWithCustomerInfoList[0]));
            // in case access token is expired.. retry one more time with new token
            if(responseWrapper.responseCode == 400 || responseWrapper.responseCode == 404){
                string accessToken = Rest_outboundCaller.loginToWebPortal();
                Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/attachPricingPolicy',accessToken,Json.serialize(ppWithCustomerInfoList[0]));
                Rest_outboundCaller.updatewebportalAccessToken(accessToken);                
            }
        }
        catch(Exception e){
        	errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebPortalOutboundHandler.sendCustomerWithPricingPolicyToPortal',e.getLineNumber());    
        }
        
        //return ppWithCustomerInfoList;
    }
    
    //method to send updates to web Portal when Customer is detached from Pricing Policy
    public static void sendCustomerWithPricingPolicyToPortalUponDeletion(List<Id> pricingPolicyWithCustomerId){
        System.debug('pricingPolicyWithCustomerId ****' + pricingPolicyWithCustomerId);
        system.debug('In delete method of portal');
        List<Rest_WebPortalWrappers.pricingPolicyWithCustomerUponDeletion> ppWithCustomerInfoList = new List<Rest_WebPortalWrappers.pricingPolicyWithCustomerUponDeletion>();
        try{
            List<Pricing_Policy_with_Customer__c> ppWithCustomerList = [SELECT Id, Name, Customers__c, Pricing_Policy__c FROM Pricing_Policy_with_Customer__c WHERE Id IN :pricingPolicyWithCustomerId ALL ROWS];
            System.debug('ppWithCustomerList ' + ppWithCustomerList);
            if(!ppWithCustomerList.isEmpty()){
                system.debug('list not empty');
                for(Pricing_Policy_with_Customer__c ppc : ppWithCustomerList){
                    Rest_WebPortalWrappers.pricingPolicyWithCustomerUponDeletion ppWithCustomerInfo = new Rest_WebPortalWrappers.pricingPolicyWithCustomerUponDeletion();
                    ppWithCustomerInfo.salesforceId = ppc.Id;
                    ppWithCustomerInfoList.add(ppWithCustomerInfo);
                }
            }
            System.debug('ppWithCustomerInfoList ' + ppWithCustomerInfoList);
            //sending out a request 
            Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
            
            responseWrapper = Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/detachPricingPolicy','',Json.serialize(ppWithCustomerInfoList[0]));
            // in case access token is expired.. retry one more time with new token
            if(responseWrapper.responseCode == 400 || responseWrapper.responseCode == 404){
                string accessToken = Rest_outboundCaller.loginToWebPortal();
                Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/detachPricingPolicy',accessToken,Json.serialize(ppWithCustomerInfoList[0]));
                Rest_outboundCaller.updatewebportalAccessToken(accessToken);                
            }
        }
        catch(Exception e){
        	errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebPortalOutboundHandler.sendCustomerWithPricingPolicyToPortalUponDeletion',e.getLineNumber());    
        }
        
        //return ppWithCustomerInfoList;
    }
    
    public static void sendOrderWithOrderProductDetailsToWebPortal(List<Id> orderIds){
        try{
            List<Opportunity> oppList = [SELECT Id,TotalAmount__c,Invoice_URL__c,name,AccountId,Order_Date__c,Order_Source__c,Payment_type__c,
                                         Web_Portal_Order_Status__c,CurrencyIsoCode,subtotal__c,tax_total__c,customer_order_number__c,
                                         reference__c,Amount,city__c,Street__c,postal_code__c,Country__c,state__c FROM Opportunity WHERE Id IN : orderIds];
            if(!oppList.isEmpty()){
                System.debug('oppList ' + oppList);
                Set<Id> oppIds = new Set<Id>();
                Map<Id,List<OpportunityLineItem>> orderToOrderLintItemMap = new Map<Id,List<OpportunityLineItem>>();
                for(Opportunity opp : oppList){
                	oppIds.add(opp.Id);    
                }
                
                List<OpportunityLineItem> oliList = [SELECT Id,Product2Id,Product2.Name,OpportunityId,ProductCode,Description,Quantity,UnitPrice,TotalPrice FROM OpportunityLineItem WHERE OpportunityId IN : oppIds];
                //Popuating map
                if(!oliList.isEmpty()){
                    for(OpportunityLineItem oli : oliList){
                        if(orderToOrderLintItemMap.containsKey(oli.OpportunityId)){
                            orderToOrderLintItemMap.get(oli.OpportunityId).add(oli);
                            //System.debug('in the loop ' +PricingPplicyToPPRulesMap);
                        }else{
                            List<OpportunityLineItem> olisList = new List<OpportunityLineItem>();
                            olisList.add(oli);
                            //System.debug('in another loop pprList' +pprList);
                            orderToOrderLintItemMap.put(oli.OpportunityId,olisList);
                        } 
                    }	    
                }
                
                List<Rest_WebPortalWrappers.orderInfo> orderInfoList = new List<Rest_WebPortalWrappers.orderInfo>();
                for(Opportunity opp : oppList){
                	Rest_WebPortalWrappers.orderInfo oderInfoDetails = new Rest_WebPortalWrappers.orderInfo();
                    List<Rest_WebPortalWrappers.orderProducts> orderProductsInfo = new List<Rest_WebPortalWrappers.orderProducts>();
                    oderInfoDetails.salesforceId = opp.Id;
                    oderInfoDetails.name = opp.Name;
                    oderInfoDetails.customerId = opp.AccountId;
                    oderInfoDetails.orderDate = opp.Order_Date__c;
                    oderInfoDetails.orderSource = opp.Order_Source__c;
                    oderInfoDetails.paymentType = opp.Payment_type__c;
                    oderInfoDetails.webPortalOrderStatus = opp.Web_Portal_Order_Status__c;
                    oderInfoDetails.orderCurrency = opp.CurrencyIsoCode;
                    oderInfoDetails.subTotal = opp.subtotal__c;
                    oderInfoDetails.taxTotal = opp.tax_total__c;
                    oderInfoDetails.customerOrderNumber = opp.customer_order_number__c;
                    oderInfoDetails.reference = opp.reference__c;
                    oderInfoDetails.orderTotal = opp.TotalAmount__c;
                    oderInfoDetails.invoiceUrl = opp.Invoice_URL__c;
                    oderInfoDetails.address.city = opp.city__c;
                    oderInfoDetails.address.street = opp.Street__c;
                    oderInfoDetails.address.postalcode = opp.postal_code__c;
                    oderInfoDetails.address.country = opp.Country__c;
                    oderInfoDetails.address.state = opp.state__c;
                    if(orderToOrderLintItemMap.containsKey(opp.Id)){
                        for(OpportunityLineItem oli : orderToOrderLintItemMap.get(opp.Id)){
                        	Rest_WebPortalWrappers.orderProducts orderProductDetails = new Rest_WebPortalWrappers.orderProducts();
                            
                            orderProductDetails.stockCode = oli.Product2.Name;
                            orderProductDetails.lineitemdescription = oli.Description;
                            orderProductDetails.quantity = oli.Quantity;
                            orderProductDetails.salesprice = oli.UnitPrice;
                            orderProductDetails.totalPrice = oli.TotalPrice;
                            orderProductsInfo.add(orderProductDetails);
                        }
                        
                       oderInfoDetails.orderProductsWrap = orderProductsInfo;
                       orderInfoList.add(oderInfoDetails); 
                    }                   
                }
                
                //sending out a request 
                Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
                
                responseWrapper = Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/order','',Json.serialize(orderInfoList[0]));
                // in case access token is expired.. retry one more time with new token
                if(responseWrapper.responseCode == 400 || responseWrapper.responseCode == 404){
                    string accessToken = Rest_outboundCaller.loginToWebPortal();
                    Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/order',accessToken,Json.serialize(orderInfoList[0]));
                    Rest_outboundCaller.updatewebportalAccessToken(accessToken);                
                }
            }
        	    
        }
        catch(Exception e){
        	errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebPortalOutboundHandler.sendOrderWithOrderProductDetailsToWebPortal',e.getLineNumber());	    
        }
    }
    
    public static void sendCustomerDetailsWithDeliveryAddress(list<id> accountIds){
        try{
            //fetching all accounts
            List<Account> accList = [SELECT id,Show_Facilities__c,Show_Advance_Savings_Details__c,Total_Saving__c,Current_Spend__c,Hydraulic_Oil_Usage_ltrs__c,Down_Time_in_Hrs_per_month__c,override_GST_rate__c,Remaining_Credit_Balance__c,shippingstreet,shippingCity,shippingState,shippingPostalCode,shippingCountry,
                                     Name,Email__c,phone,region__c,Industry,CurrencyIsoCode,base_price__c,credit_limit__c,
                                     stop_credit__c,isActive__c,allow_restricted_goods__C,open_item__c,need_order_number__c,
                                     billingstreet,billingCity,billingstate,billingcountry,billingpostalCode FROM Account WHERE Id =: accountIds]; 
            
            if(!accList.isEmpty()){
                system.debug('base_price__c ' + accList);
                Set<Id> customerIds = new Set<Id>();
                for(Account acc : accList){
                    customerIds.add(acc.Id);	    
                }
                
                Map<Id,List<Delivery_address__c>> customerToDeliveryAddressMap = new Map<Id,List<Delivery_address__c>>();
                //declaring list of resposne wrapper
                List<Rest_WebPortalWrappers.accountInfoOutbound> customerInfoDetails = new List<Rest_WebPortalWrappers.accountInfoOutbound>();
                
                //fetching delivery addresses for all the customers    
                List<delivery_address__c> deliveryAddresses = [select id,customers__c,street__c,city__c,state__c,country__c,postal_code__c,is_primary__c 
                                                               from delivery_address__c where customers__c IN:customerIds];
                System.debug('delivery_address__c ' + deliveryAddresses);
                //populating map of delivery addresses to customer
                if(!deliveryAddresses.isEmpty()){
                    System.debug('delivery adddress not empty');
                    for(delivery_address__c da: deliveryAddresses){
                        //if customer is very new to our map, its first entry
                        if(!customerToDeliveryAddressMap.containsKey(da.customers__c)){
                            list<delivery_address__c> dalist = new list<delivery_address__c>();
                            dalist.add(da);
                            customerToDeliveryAddressMap.put(da.customers__c,dalist);
                        }else{
                            list<delivery_address__c> dalist = new list<delivery_address__c>();
                            //refurbishing the list
                            dalist = customerToDeliveryAddressMap.get(da.customers__c);
                            dalist.add(da);
                            customerToDeliveryAddressMap.put(da.customers__c,dalist);
                        }
                    }                    
                }
                //accountAndContactinfo
                for(Account acc : accList){
                    System.debug('filling customer details...');
                    Rest_WebPortalWrappers.accountInfoOutbound customerInfo = new Rest_WebPortalWrappers.accountInfoOutbound();
                    List<Rest_WebPortalWrappers.addressWrapper> customerDeliveryaddressList = new List<Rest_WebPortalWrappers.addressWrapper>();
                    customerInfo.customerDetails.salesforceId = acc.Id;
                    customerInfo.customerDetails.name = acc.Name;
                    customerInfo.customerDetails.email = acc.Email__c;
                    customerInfo.customerDetails.phone = acc.phone;
                    customerInfo.customerDetails.remainingCreditBalance = acc.Remaining_Credit_Balance__c;
                    //getting picklist label
                    system.debug('REgion ' + SFToExoIntegrationUtility.getPicklistLabel('account','region__c',acc.region__c));
                    customerInfo.customerDetails.region = SFToExoIntegrationUtility.getPicklistLabel('account','region__c',acc.region__c);
                    customerInfo.customerDetails.industry = acc.Industry;
                    customerInfo.customerDetails.currencyCode = acc.CurrencyIsoCode;
                    //getting picklist label
                    system.debug('test' + SFToExoIntegrationUtility.getPicklistLabel('account','Base_Price__c',acc.Base_Price__c));
                    if(acc.Base_Price__c != 'Retail'){
                    	customerInfo.customerDetails.basePriceGroup = SFToExoIntegrationUtility.getPicklistLabel('account','Base_Price__c',acc.Base_Price__c);
                    }
                    else{
                        customerInfo.customerDetails.basePriceGroup = acc.Base_Price__c;
                    }
                        system.debug('customerInfo.customerDetails.basePriceGroup ' + customerInfo.customerDetails.basePriceGroup);
                    customerInfo.customerDetails.CreditLimit = acc.credit_limit__c;
                    customerInfo.customerDetails.StopCredit = acc.stop_credit__c;
                    customerInfo.customerDetails.IsActive = acc.isActive__c;
                    customerInfo.customerDetails.AllowRestrictedGoods = acc.allow_restricted_goods__C;
                    customerInfo.customerDetails.IsOpenItem = acc.open_item__c;
                    customerInfo.customerDetails.NeedOrderNumber = acc.need_order_number__C;
                    customerInfo.customerDetails.overrideGSTRate = SFToExoIntegrationUtility.getPicklistLabel('account','override_GST_rate__c',acc.override_GST_rate__c); //acc.override_GST_rate__c;
                    customerInfo.customerDetails.downTimeInHrsPerMonth =acc.Down_Time_in_Hrs_per_month__c;
                    customerInfo.customerDetails.hydraulicOilUsage = acc.Hydraulic_Oil_Usage_ltrs__c;
                    customerInfo.customerDetails.currentSpend = acc.Current_Spend__c;
                    customerInfo.customerDetails.totalSaving = acc.Total_Saving__c;
                    //customerInfo.customerDetails.    
                    customerInfo.customerDetails.PostalAddress.street = acc.billingstreet;
                    customerInfo.customerDetails.PostalAddress.city = acc.billingCity;
                    customerInfo.customerDetails.PostalAddress.state = acc.billingstate;
                    customerInfo.customerDetails.PostalAddress.country = acc.billingcountry;
                    customerInfo.customerDetails.PostalAddress.postalCode = acc.billingpostalCode; 
                    customerInfo.customerDetails.showAdvanceSavingsDetails = acc.Show_Advance_Savings_Details__c;
                    customerInfo.customerDetails.showFacilities = acc.Show_Facilities__c; 
                    //filling up first delivery address from customer level
                    
                    //adding it to a list of delivery addresses if delivery address on account exists
                    /*if(string.isNotBlank(acc.shippingstreet) && string.isNotBlank(acc.shippingCity)){
                        System.debug('shippeing address not blank...');
                        Rest_WebPortalWrappers.addressWrapper primaryDeliveryaddress = new Rest_WebPortalWrappers.addressWrapper();
                        
                        primaryDeliveryaddress.street = acc.shippingstreet;
                        primaryDeliveryaddress.city = acc.shippingcity;
                        primaryDeliveryaddress.state = acc.shippingstate;
                        primaryDeliveryaddress.country = acc.shippingcountry;
                        primaryDeliveryaddress.postalCode = acc.shippingPostalCode;
                        primaryDeliveryaddress.isPrimary = true;
                        customerDeliveryaddressList.add(primaryDeliveryaddress);    
                    }*/
                    
                    //looping in delivery address list to fill up other delivery addresses than primary
                    if(customerToDeliveryAddressMap.containsKey(acc.Id)){
                        System.debug('filling up delivery address');
                        for(delivery_address__c da: customerToDeliveryAddressMap.get(acc.Id)){
                            Rest_WebPortalWrappers.addressWrapper otherDeliveryaddress = new Rest_WebPortalWrappers.addressWrapper();
                            otherDeliveryaddress.salesforceId = da.Id;
                            otherDeliveryaddress.street = da.Street__c;
                            otherDeliveryaddress.city = da.City__c;
                            otherDeliveryaddress.state = da.State__c;
                            otherDeliveryaddress.country = da.Country__c;
                            otherDeliveryaddress.postalCode = da.Postal_Code__c;
                            // by default marking isPrimary as false and not relying on delivery address objetc field. 
                            otherDeliveryaddress.isPrimary = da.Is_Primary__c;
                            customerDeliveryaddressList.add(otherDeliveryaddress);
                        }
                    }
                    
                    // now, adding primary delivery address list on customerDetails wrapper level
                    customerInfo.customerDetails.deliveryAddress = customerDeliveryaddressList;
                    
                    //Adding it to final wrapper
                    
                    customerInfoDetails.add(customerInfo);
                    system.debug('json String--'+Json.serialize(customerInfoDetails[0]));
                }
                
                
                
                //* intially method was designed to send bulk conatct updates to web portal, but now we are sending
                //* only 1 instance at a time, hence sending list[0] index, if we need enabale bulk update in future,
                //* then simply send full list to external system 
                
                
                //sending out a request 
                Rest_webPortalWrappers.genericOutboundResponseWrapper responseWrapper = new Rest_webPortalWrappers.genericOutboundResponseWrapper();
                
                responseWrapper = Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/updateAccount','',Json.serialize(customerInfoDetails[0]));
                // in case access token is expired.. retry one more time with new token
                if(responseWrapper.responseCode == 400 || responseWrapper.responseCode == 404 || responseWrapper.responseCode == 401){
                    string accessToken = Rest_outboundCaller.loginToWebPortal();
                    Rest_outboundCaller.postHttpRequestPortal('/salesforce/sync/updateAccount',accessToken,Json.serialize(customerInfoDetails[0]));
                    Rest_outboundCaller.updatewebportalAccessToken(accessToken);                    
                }
            }
        }
        catch(Exception e){
        	errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebPortalOutboundHandler.sendCustomerDetailsWithDeliveryAddress',e.getLineNumber());        
        }
    }
   
    // to insert BOM and Prices
    public static Set<Id> insertBomProducts(List<Rest_WebPortalWrappers.bomProducts> receivedBomListFromPortal){
	
    //Set<Id> bomStockCodeWithQuantitySet = new Set<Id>();
    Set<String> bomStockCodeWithQuantitySet = new Set<String>();    
    //set of Ids to be returned
    Set<Id> newBomIdsInserted = new Set<Id>();    
	Map<String,Product2> existingBomMap = new Map<String,Product2>();
	List<Product2> newBomList =  new List<Product2>();
	Map<String,List<BOM_Line_Item__c>> bomCodeToLineItemMap = new Map<String,List<BOM_Line_Item__c>>();
	
	for(Rest_WebPortalWrappers.bomProducts bom: receivedBomListFromPortal){
		bomStockCodeWithQuantitySet.add(bom.stockCodewithQuantity);
	}
	System.debug('bomStockCodeWithQuantitySet--'+bomStockCodeWithQuantitySet);
	List<Product2> existingBomList = [SELECT Id,Name,BOM_Code_Name__c FROM Product2 WHERE
									  Bill_of_Material__c = true AND BOM_Code_Name__c IN: bomStockCodeWithQuantitySet];
													   
	System.debug('existingBomList--'+existingBomList);
    // getting map of existing bom products
	for(Product2 bom: existingBomList){
		existingBomMap.put(bom.BOM_Code_Name__c,bom);
	}	
	System.debug('existingBomMap--'+existingBomMap);												   
	// 
	for(Rest_WebPortalWrappers.bomProducts bomItem: receivedBomListFromPortal){
		if(!existingBomMap.containsKey(bomItem.stockCodewithQuantity)){
			// create parent BOM Item
			Product2 newBom = new Product2();
            newBom.Name = bomItem.stockCode;
            newBom.Description = bomItem.stockCode;
            newBom.Bill_of_Material__c = true;
            newBom.Overall_Length__c = bomItem.overAllLength;
            newBom.BOM_Code_Name__c = bomItem.stockCodewithQuantity;
            newBom.Pricing_Mode__c = 0;
            newBom.Stock_Image_4__c = bomItem.hoseImage;
            newBomList.add(newBom);
            system.debug('newBomList ' + newBomList);
			// list to hold bom line items
			List<BOM_Line_Item__c> bomLineItemList = new List<BOM_Line_Item__c>();
			
            // create BOM Line Items
			for(Rest_WebPortalWrappers.hose hoseWrap : bomitem.hoseWrapper){
				System.debug('hoseWrap--'+hoseWrap);
                if(hoseWrap.position.equalsIgnoreCase('Left') && hoseWrap.type == 'Fitting'){
					BOM_Line_Item__c bomLineItem = new BOM_Line_Item__c();
					bomLineItem.Name = hoseWrap.stockCode;
					//bomLineItem.Stock_Item__c = ;
					bomLineItem.Position__c = hoseWrap.position;
					bomLineItem.pack__c = hoseWrap.unit;
					bomLineItem.quantity__c = hoseWrap.quantity;
					bomLineItem.angle__c = '0';
					bomLineItem.Crimp_Size__c = hoseWrap.crimpSize;
					bomLineItem.Seat_Type__c = hoseWrap.seatType;
                    bomLineItem.Type__c = 'Fittings';
					bomLineItemList.add(bomLineItem);
					System.debug('position... L');
					
                }
                if(hoseWrap.position.equalsIgnoreCase('Middle')){
                    BOM_Line_Item__c bomLineItem = new BOM_Line_Item__c();
					bomLineItem.Name = hoseWrap.stockCode;
                    //bomLineItem.Stock_Item__c = ;
                    bomLineItem.Position__c = hoseWrap.position;
                    bomLineItem.pack__c = hoseWrap.unit;
                    bomLineItem.Quantity__c = hoseWrap.length;
					bomLineItemList.add(bomLineItem);
				 	System.debug('position... M');
                }
                 if(hoseWrap.position.equalsIgnoreCase('Right') && hoseWrap.type == 'Fitting'){
                    BOM_Line_Item__c bomLineItem = new BOM_Line_Item__c();
					bomLineItem.Name = hoseWrap.stockCode;
                    //bomLineItem.Stock_Item__c = ;
                    bomLineItem.Position__c = hoseWrap.position;
                    bomLineItem.pack__c = hoseWrap.unit;
                    bomLineItem.quantity__c = hoseWrap.quantity;
                    bomLineItem.Angle__c = hoseWrap.angle;
                    bomLineItem.Crimp_Size__c = hoseWrap.crimpSize;
                    bomLineItem.Seat_Type__c = hoseWrap.seatType;
                    bomLineItem.Type__c = 'Fittings'; 
                    bomLineItemList.add(bomLineItem);
                    System.debug('position... R');
                }
                
                if(bomitem.Spiral == true && hoseWrap.position == 'Spiral'){
                    BOM_Line_Item__c bomLineItem = new BOM_Line_Item__c();
					bomLineItem.Name = hoseWrap.stockCode;
                   // bomLineItem.Stock_Item__c = ;
                    bomLineItem.Position__c = hoseWrap.position;
                    bomLineItem.pack__c = hoseWrap.unit;
                    bomLineItem.quantity__c = hoseWrap.length;
                    bomLineItemList.add(bomLineItem);
                    System.debug('position... spiral');
                }
                
                if(bomitem.ferrules == true){
                    if(hoseWrap.position.equalsIgnoreCase('Right') && hoseWrap.type == 'ferrule'){
                        BOM_Line_Item__c bomLineItem = new BOM_Line_Item__c();
                        bomLineItem.Name = hoseWrap.stockCode;
                       // bomLineItem.Stock_Item__c = ;
                        bomLineItem.Position__c = hoseWrap.position;
                        bomLineItem.pack__c = hoseWrap.unit;
                        bomLineItem.quantity__c = hoseWrap.quantity;
                        bomLineItem.Type__c = 'Ferrules';
                        bomLineItemList.add(bomLineItem);   
                    }
                    
                    if(hoseWrap.position.equalsIgnoreCase('Left') && hoseWrap.type == 'ferrule'){
                        BOM_Line_Item__c bomLineItem = new BOM_Line_Item__c();
                        bomLineItem.Name = hoseWrap.stockCode;
                       // bomLineItem.Stock_Item__c = ;
                        bomLineItem.Position__c = hoseWrap.position;
                        bomLineItem.pack__c = hoseWrap.unit;
                        bomLineItem.quantity__c = hoseWrap.quantity;
                        bomLineItem.Type__c = 'Ferrules';
                        bomLineItemList.add(bomLineItem);   
                    }               	    
                }			
			}
            
			//add additional products
			for(Rest_WebPortalWrappers.additionalProducts ap : bomitem.additionalProducts){
            	BOM_Line_Item__c additionalBomLineItem = new BOM_Line_Item__c();
                additionalBomLineItem.Name = ap.stockCode;
                //bom.Stock_Item__c = ;
                additionalBomLineItem.quantity__c = ap.quantity;
                additionalBomLineItem.Additional_Products__c = bomitem.additionProducts;
                bomLineItemList.add(additionalBomLineItem);
                System.debug('position... additional');
             }
            
            // add to map
			System.debug('bomLineItemList--'+bomLineItemList);      
            bomCodeToLineItemMap.put(bomItem.stockCode,bomLineItemList);		
		}
        
	}
    System.debug('bomCodeToLineItemMap--'+bomCodeToLineItemMap);  
    System.debug('newBomList--'+newBomList);      
    // start inserting BOM and BOM line items
    if(!newBomList.isEmpty()){
        //inserting parent BOM first
        Map<String,Id> bomNameToIdMap = new Map<String,Id>();
        List<BOM_Line_Item__c> bomLineItemsToInsert = new List<Bom_Line_Item__c>();
        Database.saveResult[] insertedBoms = Database.insert(newBomList,true);
        System.debug('insertedBoms ' + insertedBoms);
        for(integer i=0; i < insertedBoms.size(); i++){
            bomNameToIdMap.put(newBomList[i].Name,insertedBoms[i].getId());
            newBomIdsInserted.add(insertedBoms[i].getId());
        }
        for(Database.saveResult sr : insertedBoms){
        	System.debug('sr ' + sr);	    
        }
     	// inserting child line items now...
        for(String parentBomName :bomCodeToLineItemMap.keySet()){
            for(BOM_Line_Item__c bomLineItem : bomCodeToLineItemMap.get(parentBomName)){
                bomLineItem.Stock_Item__c = bomNameToIdMap.get(parentBomName);
                bomLineItemsToInsert.add(bomLineItem);
            }
        }
        System.debug('bomLineItemsToInsert--' + bomLineItemsToInsert);	    
        insert bomLineItemsToInsert;
        
    }    
	
        //return inserted BomIds
        //insertBomPrices(newBomIdsInserted);
        return newBomIdsInserted;
  }
    
  // to insert BOM and Prices
    public static list<PriceBookEntry> insertBomPrices(set<Id> newBoms){
    
    	Set<String> BomLineItems = new Set<String>();
        Map<String,List<PriceBookEntry>> StockCodeToPbeEntries = new Map<String,List<PriceBookEntry>>();
        List<PriceBookEntry> PbeInsertionList = new List<PriceBookEntry>();
        // get all list of child bom lineitems involved in
        List<Product2> bomProducts = [SELECT Id,Name,(SELECT Id,Name FROM Bill_Of_Material__r) FROM Product2 
                                      WHERE Id IN:newBoms AND Bill_Of_Material__c = true];
        
        for(Product2 bomProduct : bomProducts){
        	for(bom_Line_Item__c bomLineItem : bomProduct.Bill_Of_Material__r){
            	BomLineItems.add(bomLineItem.Name);
        	}
        }
        
        // get price book entries for bom line items
        for(PriceBookEntry lineItemsPbe : [SELECT Id,Bulk_Buy_Price__c,Contractor_Price__c,CurrencyIsoCode,Dealer_Price__c,
                                           UnitPrice,Pricebook2Id,Retail_Price__c,Trade_Price__c,Wholesale_Price__c,Product2.Name
                                           FROM Pricebookentry WHERE Pricebook2.IsStandard = true AND Product2.Name IN: BomLineItems 
                                          ])
        {
            if(StockCodeToPbeEntries.containsKey(lineItemsPbe.Product2.Name)){
                List<PriceBookEntry> pbeList = StockCodeToPbeEntries.get(lineItemsPbe.Product2.Name);
                pbeList.add(lineItemsPbe);
            	StockCodeToPbeEntries.put(lineItemsPbe.Product2.Name,pbeList);       
            }else{
                List<PriceBookEntry> pbeList = new List<PriceBookEntry>{lineItemsPbe};
                StockCodeToPbeEntries.put(lineItemsPbe.Product2.Name,pbeList);           
            }
            
        }
        
        //create pricebookentries for newly created bom product
        for(Product2 bomProduct : bomProducts){
        	
            integer childComponentsCount = bomProduct.bill_of_material__r.size();
             Map<String,List<PriceBookEntry>> currencyCodeToPbeMap = new Map<String,List<PriceBookEntry>>();
            // loop through child bOM line items
            /* each line item can have multiple pbe records based on different currencies, but there wont be multiple
             same currency pbe records for a single product */
            for(bom_line_item__c bomLineItem:bomProduct.bill_of_material__r){
                List<priceBookEntry> allCurrenciesPbeList = StockCodeToPbeEntries.get(bomLineItem.Name);
                for(pricebookentry pbe : allCurrenciesPbeList){
                    if(currencyCodeToPbeMap.containsKey(pbe.CurrencyIsoCode)){
                        List<PriceBookEntry> pbeList = currencyCodeToPbeMap.get(pbe.CurrencyIsoCode);
                        pbeList.add(pbe);
                        currencyCodeToPbeMap.put(pbe.CurrencyIsoCode,pbeList);
                    }else{
                        List<PriceBookEntry> pbeList = new List<PriceBookEntry>{pbe};
                        currencyCodeToPbeMap.put(pbe.CurrencyIsoCode,pbeList);
                    }   
                }
            }
            
            // now will sort pricebokentries currency wise to be added for this bom product wise
            for(String currencyCode : currencyCodeToPbeMap.keySet()){
                List<PriceBookEntry> currencyWisePbeList = currencyCodeToPbeMap.get(currencyCode);
                //only create a particlular currencies bom Pricebook entry if all its component prices
                //are available in that particular currency.
                if(currencyWisePbeList.size() == childComponentsCount){
                    pricebookEntry BomPbeToInsert = new PriceBookEntry();
                    BomPbeToInsert.currencyIsoCode = currencyCode;
                    BomPbeToInsert.Product2Id = bomProduct.Id;
                    BomPbeToInsert.Pricebook2Id = currencyWisePbeList[0].pricebook2Id;
                    BomPbeToInsert.IsActive = true;
                    //initializing BOM pricebook entry fields
                    BomPbeToInsert.Bulk_Buy_Price__c = 0;
                    BomPbeToInsert.Contractor_Price__c = 0;
                    BomPbeToInsert.Dealer_Price__c = 0;
                    BomPbeToInsert.Retail_Price__c = 0;
                    BomPbeToInsert.Trade_Price__c = 0;
                    BomPbeToInsert.UnitPrice = 0;
                    BomPbeToInsert.Wholesale_Price__c = 0;
                    //aggregating all the six component prices
                    for(PriceBookEntry pbe: currencyWisePbeList){
                        BomPbeToInsert.Bulk_Buy_Price__c += pbe.Bulk_Buy_Price__c;
                        BomPbeToInsert.Contractor_Price__c += pbe.Contractor_Price__c;
                        BomPbeToInsert.Dealer_Price__c += pbe.Dealer_Price__c;
                        BomPbeToInsert.Retail_Price__c += pbe.Retail_Price__c;
                        BomPbeToInsert.Trade_Price__c += pbe.Trade_Price__c;
                        BomPbeToInsert.UnitPrice += pbe.UnitPrice;
                        BomPbeToInsert.Wholesale_Price__c += pbe.Wholesale_Price__c;
                    }
                	
                    // fianlly, add this to list of PBEs to be inserted....
                    PbeInsertionList.add(BomPbeToInsert);
                }
            }
        }    
        
        // insert list of pbe entries
        if(!PbeInsertionList.isEmpty()){
            insert PbeInsertionList;
        }
        // return list of price book inserted
        return PbeInsertionList;
    }  
    
}