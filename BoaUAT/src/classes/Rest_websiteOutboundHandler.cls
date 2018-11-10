public class Rest_websiteOutboundHandler {
		
    //method to send product details to boa public website
     public static void sendProductDetailsToPublicSite(list<id> stockitemids){
         system.debug('Sending to website');
         try{
            String soql = 'SELECT Id,Show_on_Website__c,WordPress_Id__c,Product_Family_Display_Name__c,Name,ProductCode,Primary_Group_Display_Name__c,Secondary_Group_Display_Name__c,Tertiary_Group_Display_Name__c,';
            soql += 'Primary_Group__c,Secondary_Group__c,Tertiary_Group__c,Product_Family__c,';
            soql += 'QuantityUnitOfMeasure,Weight__c,IsActive,';
            soql += 'stock_image_1__c,stock_image_2__c,stock_image_3__c,';
            soql += 'Nominal_Size_mm__c,Max_Work_Pressure_PSI__c,Min_Burst_Pressure_Male_PSI__c,Min_Burst_Pressure_Coupled_PSI__c,Rated_Flow_L_min__c,Max_Flow_L_Min__c,Min_Burst_Pressure_Female_PSI__c,Fluid_Spillage_cc__c,';		    
            soql += 'Hose_Inner_Diameter_Inches__c,Hose_Inner_Diameter_mm__c,Working_Pressure_PSI__c,Working_Pressure_BAR__c,Full_Coil_Size_metre__c,Hose_Outer_Diameter_mm__c,Minimum_Bend_Radius_mm__c,';  
            soql += 'Nominal_Thread_Size_1__c,Nominal_Thread_Size_2__c,Nominal_Thread_Size_3__c,Nominal_Thread_Size_4__c,Physical_Thread_Size_1__c,physical_thread_size_2__c,Physical_Thread_Size_3__c,Physical_Thread_Size_4__c,Thread_Type_1__c,Thread_Type_2__c,Thread_Type_3__c,Thread_Type_4__c,Orientation__c,Tail_Size_To_Suit_Hose_ID__c,Nominal_Pipe_Size__c,';   
            soql += 'Collated_Identifier__c,Identifier_related_info_Thread_2_ID__c,Thread_3_ID_SS_adaptor__c,Prefix_Thread_1_ID__c,DKOL_DKOS__c,Male_Female_Flange_Fitting_Only__c,Suits_Hose__c,';
            soql += 'Dash_Size_1__c,Dash_Size_2__c,Dash_Size_3__c,Dash_Size_4__c,Thread_Color_Code__c,Thread_Type_Filter_1__c,Thread_Type_Filter_2__c,LC_Length__c,LD_Drop__c,H1__c,H2_Nut_Size__c'; 
            soql = soql + ' FROM Product2 WHERE Id IN :stockItemIds and is_Hydraulic_Product__c = true and Bill_of_Material__c = false';
            List<Product2> plist = Database.query(soql);
            system.debug('plist ' + plist);
            List<Rest_WebSiteWrappers.ProductToWebsiteWrapper> productList = new List<Rest_WebSiteWrappers.ProductToWebsiteWrapper>();
            
            for(Product2 prd : pList){
                Rest_WebSiteWrappers.ProductToWebsiteWrapper product = new Rest_WebSiteWrappers.ProductToWebsiteWrapper(); 
                	//product.salesforce_id = prd.Id;	
                	product.name = prd.name;
                	if(prd.WordPress_Id__c!=null)
                	product.WordPress_Id = prd.WordPress_Id__c;
                	//product.catalog_visibility = 'visible';
                    product.slug = prd.name.toLowerCase();  

                    product.type = 'external'; 
                	if(prd.Show_on_Website__c){
                    	product.status = 'publish';
                    }
               		else{
                    	product.status = 'draft';	
                	}
                     
                    product.catalog_visibility = 'visible';                     
                    product.short_description = prd.productCode; 
                    product.sku = prd.Name; 
                     
                    product.button_text = 'Buy Now'; 
                	//if(prd.IsActive){
                    	product.in_stock = true;
                	//}
                	//else{
                    //	product.in_stock = false;
                	//}
                     
                    product.weight = string.valueOf(prd.weight__c);                     
                    product.parent_id = 0;               
                                
                //adapters and fittings dimensions
                if(prd.Secondary_Group__c == '15' || prd.Secondary_Group__c == '17'){
                    
                    // adding dimension 1
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension1  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.nominal_thread_size_1__c != null){
                        prdDimension1.name = 'Nominal Thread Size 1';
                        prdDimension1.position = 0;
                        prdDimension1.visible = true;
                        prdDimension1.variation = false;
                        prdDimension1.options.add(prd.nominal_thread_size_1__c);
                        product.attributes.add(prdDimension1);
                    } 
                    
                    // adding dimension 2
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension2  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.nominal_thread_size_2__c != null){
                        prdDimension2.name = 'Nominal Thread Size 2';
                        prdDimension2.position = 1;
                        prdDimension2.visible = true;
                        prdDimension2.variation = false;
                        prdDimension2.options.add(prd.nominal_thread_size_2__c);
                        product.attributes.add(prdDimension2);
                    }
                    
                    // adding dimension 3
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension3  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.nominal_thread_size_3__c != null){
                        prdDimension3.name = 'Nominal Thread Size 3';
                        prdDimension3.position = 2;
                        prdDimension3.visible = true;
                        prdDimension3.variation = false;
                        prdDimension3.options.add(prd.nominal_thread_size_3__c);
                        product.attributes.add(prdDimension3);
                    }
                    
                    // adding dimension 4
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension4  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.nominal_thread_size_4__c != null){
                        prdDimension4.name = 'Nominal Thread Size 4';
                        prdDimension4.position = 3;
                        prdDimension4.visible = true;
                        prdDimension4.variation = false;
                        prdDimension4.options.add(prd.nominal_thread_size_4__c);
                        product.attributes.add(prdDimension4);
                    }
                    
                     // adding dimension 5
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension5  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Physical_Thread_Size_1__c != null){
                        prdDimension5.name = 'Physical Thread Size 1';
                        prdDimension5.position = 4;
                        prdDimension5.visible = true;
                        prdDimension5.variation = false;
                        prdDimension5.options.add(prd.Physical_Thread_Size_1__c);
                        product.attributes.add(prdDimension5);
                    }
                     // adding dimension 6
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension6  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Physical_Thread_Size_2__c != null){
                        prdDimension6.name = 'Physical Thread Size 2';
                        prdDimension6.position = 5;
                        prdDimension6.visible = true;
                        prdDimension6.variation = false;
                        prdDimension6.options.add(prd.Physical_Thread_Size_2__c);
                        product.attributes.add(prdDimension6);
                    }
                    
                     // adding dimension 7
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension7  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Physical_Thread_Size_3__c != null){
                        prdDimension7.name = 'Physical Thread Size 3';
                        prdDimension7.position = 6;
                        prdDimension7.visible = true;
                        prdDimension7.variation = false;
                        prdDimension7.options.add(prd.Physical_Thread_Size_3__c);
                        product.attributes.add(prdDimension7);
                    }
                     // adding dimension 8
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension8  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Physical_Thread_Size_4__c != null){
                        prdDimension8.name = 'Physical Thread Size 4';
                        prdDimension8.position = 7;
                        prdDimension8.visible = true;
                        prdDimension8.variation = false;
                        prdDimension8.options.add(prd.Physical_Thread_Size_4__c);
                        product.attributes.add(prdDimension8);
                    }
                    
                     // adding dimension 9
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension9  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Thread_Type_1__c != null){
                        prdDimension9.name = 'Thread Type 1';
                        prdDimension9.position = 8;
                        prdDimension9.visible = true;
                        prdDimension9.variation = false;
                        prdDimension9.options.add(prd.Thread_Type_1__c);
                        product.attributes.add(prdDimension9);
                    }
                    
                     // adding dimension 10
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension10  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Thread_Type_2__c != null){
                        prdDimension10.name = 'Thread Type 2';
                        prdDimension10.position = 9;
                        prdDimension10.visible = true;
                        prdDimension10.variation = false;
                        prdDimension10.options.add(prd.Thread_Type_2__c);
                        product.attributes.add(prdDimension10);
                    }
                    
                     // adding dimension 11
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension11  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Thread_Type_3__c != null){
                        prdDimension11.name = 'Thread Type 3';
                        prdDimension11.position = 10;
                        prdDimension11.visible = true;
                        prdDimension11.variation = false;
                        prdDimension11.options.add(prd.Thread_Type_3__c);
                        product.attributes.add(prdDimension11);
                    }
                    
                     // adding dimension 12
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension12  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Thread_Type_4__c != null){
                        prdDimension12.name = 'Thread Type 4';
                        prdDimension12.position = 11;
                        prdDimension12.visible = true;
                        prdDimension12.variation = false;
                        prdDimension12.options.add(prd.Thread_Type_4__c);
                        product.attributes.add(prdDimension12);
                    }
                    
                     // adding dimension 13
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension13  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Orientation__c != null){
                        prdDimension13.name = 'Orientation';
                        prdDimension13.position = 12;
                        prdDimension13.visible = true;
                        prdDimension13.variation = false;
                        prdDimension13.options.add(prd.Orientation__c);
                        product.attributes.add(prdDimension13);
                    }
                    
                     // adding dimension 14
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension14  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Tail_Size_To_Suit_Hose_ID__c != null){
                        prdDimension14.name = 'Tail Size to Suite Hose ID';
                        prdDimension14.position = 13;
                        prdDimension14.visible = true;
                        prdDimension14.variation = false;
                        prdDimension14.options.add(prd.Tail_Size_To_Suit_Hose_ID__c);
                        product.attributes.add(prdDimension14);
                    }
                    
                     // adding dimension 15
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension15  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Nominal_Pipe_Size__c != null){
                        prdDimension15.name = 'Nominal Pipe Size';
                        prdDimension15.position = 14;
                        prdDimension15.visible = true;
                        prdDimension15.variation = false;
                        prdDimension15.options.add(prd.Nominal_Pipe_Size__c);
                        product.attributes.add(prdDimension15);
                    }
                    
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension16  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Thread_Type_Filter_1__c != null){
                        prdDimension16.name = 'Thread Type Filter 1';
                        prdDimension16.position = 15;
                        prdDimension16.visible = true;
                        prdDimension16.variation = false;
                        prdDimension16.options.add(prd.Thread_Type_Filter_1__c);
                        product.attributes.add(prdDimension16);
                    }
                    
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension17  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Thread_Type_Filter_2__c != null){
                        prdDimension17.name = 'Thread Type Filter 1';
                        prdDimension17.position = 16;
                        prdDimension17.visible = true;
                        prdDimension17.variation = false;
                        prdDimension17.options.add(prd.Thread_Type_Filter_2__c);
                        product.attributes.add(prdDimension17);
                    }
                    
                }
                
                //hose dimensions
                if(prd.Secondary_Group__c == '2'){
                    //adding dimension 1
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension1  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Hose_Inner_Diameter_Inches__c != null){
                        prdDimension1.name = 'Hose Inner Diameter Inches';
                        prdDimension1.position = 0;
                        prdDimension1.visible = true;
                        prdDimension1.variation = false;
                        prdDimension1.options.add(prd.Hose_Inner_Diameter_Inches__c);
                        product.attributes.add(prdDimension1);
                    }
                    
                    //adding dimension 2
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension2  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Hose_Inner_Diameter_mm__c != null){
                        prdDimension2.name = 'Hose Inner Diameter MM';
                        prdDimension2.position = 1;
                        prdDimension2.visible = true;
                        prdDimension2.variation = false;
                        prdDimension2.options.add(string.valueOf(prd.Hose_Inner_Diameter_mm__c));
                        product.attributes.add(prdDimension2);
                    }
                    
                    //adding dimension 3
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension3  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Working_Pressure_PSI__c != null){
                        prdDimension3.name = 'Working Pressure PSI';
                        prdDimension3.position = 2;
                        prdDimension3.visible = true;
                        prdDimension3.variation = false;
                        prdDimension3.options.add(string.valueOf(prd.Working_Pressure_PSI__c));
                        product.attributes.add(prdDimension3);
                    }
                    
                    //adding dimension 4
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension4  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Hose_Outer_Diameter_mm__c != null){
                        prdDimension4.name = 'Hose Outer Diameter mm';
                        prdDimension4.position = 3;
                        prdDimension4.visible = true;
                        prdDimension4.variation = false;
                        prdDimension4.options.add(string.valueOf(prd.Hose_Outer_Diameter_mm__c));
                        product.attributes.add(prdDimension4);
                    }
                    
                    //adding dimension 5
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension5  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Working_Pressure_BAR__c != null){
                        prdDimension5.name = 'Working Pressure BAR';
                        prdDimension5.position = 4;
                        prdDimension5.visible = true;
                        prdDimension5.variation = false;
                        prdDimension5.options.add(string.valueOf(prd.Working_Pressure_BAR__c));
                        product.attributes.add(prdDimension5);
                    }
                    
                    //adding dimension 6
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension6  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Minimum_Bend_Radius_mm__c != null){
                        prdDimension6.name = 'Minumim Bend Radius mm';
                        prdDimension6.position = 5;
                        prdDimension6.visible = true;
                        prdDimension6.variation = false;
                        prdDimension6.options.add(string.valueOf(prd.Minimum_Bend_Radius_mm__c));
                        product.attributes.add(prdDimension6);
                    }
                    
                    //adding dimension 7
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension7  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Full_Coil_Size_metre__c != null){
                        prdDimension7.name = 'Full Coil Size Meter';
                        prdDimension7.position = 6;
                        prdDimension7.visible = true;
                        prdDimension7.variation = false;
                        prdDimension7.options.add(prd.Full_Coil_Size_metre__c);
                        product.attributes.add(prdDimension7);
                    }
                    
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension8  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Dash_Size_1__c != null){
                        prdDimension8.name = 'Dash Size 1';
                        prdDimension8.position = 7;
                        prdDimension8.visible = true;
                        prdDimension8.variation = false;
                        prdDimension8.options.add(prd.Dash_Size_1__c);
                        product.attributes.add(prdDimension8);
                    }
                    
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension9  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Dash_Size_2__c != null){
                        prdDimension9.name = 'Dash Size 2';
                        prdDimension9.position = 8;
                        prdDimension9.visible = true;
                        prdDimension9.variation = false;
                        prdDimension9.options.add(prd.Dash_Size_2__c);
                        product.attributes.add(prdDimension9);
                    }
                    
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension10  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Dash_Size_3__c != null){
                        prdDimension10.name = 'Dash Size 3';
                        prdDimension10.position = 9;
                        prdDimension10.visible = true;
                        prdDimension10.variation = false;
                        prdDimension10.options.add(prd.Dash_Size_3__c);
                        product.attributes.add(prdDimension10);
                    }
                    
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension11  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Dash_Size_4__c != null){
                        prdDimension11.name = 'Dash Size 4';
                        prdDimension11.position = 10;
                        prdDimension11.visible = true;
                        prdDimension11.variation = false;
                        prdDimension11.options.add(prd.Dash_Size_4__c);
                        product.attributes.add(prdDimension11);
                    }
                    
                    
                }
                
                //flange-clamp dimensions
                if(prd.Secondary_Group__c == ' '){
                    //adding dimension 1
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension1  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.b_in__c != null){
                        prdDimension1.name = 'b (Inches)';
                        prdDimension1.position = 0;
                        prdDimension1.visible = true;
                        prdDimension1.variation = false;
                        prdDimension1.options.add(prd.b_in__c);
                        product.attributes.add(prdDimension1);
                    }
                    
                    //adding dimension 2
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension2  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.d_in__c != null){
                        prdDimension2.name = 'd (Inches)';
                        prdDimension2.position = 1;
                        prdDimension2.visible = true;
                        prdDimension2.variation = false;
                        prdDimension2.options.add(prd.d_in__c);
                        product.attributes.add(prdDimension2);
                    }
                    
                    //adding dimension 3
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension3  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.e_in__c != null){
                        prdDimension3.name = 'e (Inches)';
                        prdDimension3.position = 2;
                        prdDimension3.visible = true;
                        prdDimension3.variation = false;
                        prdDimension3.options.add(prd.e_in__c);
                        product.attributes.add(prdDimension3);
                    }
                    
                    //adding dimension 4
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension4  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.h_in__c != null){
                        prdDimension4.name = 'h (Inches)';
                        prdDimension4.position = 3;
                        prdDimension4.visible = true;
                        prdDimension4.variation = false;
                        prdDimension4.options.add(prd.h_in__c);
                        product.attributes.add(prdDimension4);
                    }
                    
                    //adding dimension 5
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension5  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.l_in__c != null){
                        prdDimension5.name = 'l (Inches)';
                        prdDimension5.position = 4;
                        prdDimension5.visible = true;
                        prdDimension5.variation = false;
                        prdDimension5.options.add(prd.l_in__c);
                        product.attributes.add(prdDimension5);
                    }
                    
                    //adding dimension 6
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension6  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.m_in__c != null){
                        prdDimension6.name = 'm (Inches)';
                        prdDimension6.position = 5;
                        prdDimension6.visible = true;
                        prdDimension6.variation = false;
                        //prdDimension6.options.add(prd.m_in__c);
                        product.attributes.add(prdDimension6);
                    }
                }    
                //QRC Dimensions
                if(prd.Secondary_Group__c == '20'){
                 	//adding dimension 1
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension1  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Nominal_Size_mm__c != null){
                        prdDimension1.name = 'Nominal Size mm';
                        prdDimension1.position = 0;
                        prdDimension1.visible = true;
                        prdDimension1.variation = false;
                        prdDimension1.options.add(string.valueOf(prd.Nominal_Size_mm__c));
                        product.attributes.add(prdDimension1);
                    }
                    
                    //adding dimension 2
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension2  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Rated_Flow_L_min__c != null){
                        prdDimension2.name = 'Rated Flow ltrs/min';
                        prdDimension2.position = 1;
                        prdDimension2.visible = true;
                        prdDimension2.variation = false;
                        prdDimension2.options.add(string.valueOf(prd.Rated_Flow_L_min__c));
                        product.attributes.add(prdDimension2);
                    }
                    
                    //adding dimension 3
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension3  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Max_Work_Pressure_PSI__c != null){
                        prdDimension3.name = 'Max work pressure PSI';
                        prdDimension3.position = 2;
                        prdDimension3.visible = true;
                        prdDimension3.variation = false;
                        prdDimension3.options.add(string.valueOf(prd.Max_Work_Pressure_PSI__c));
                        product.attributes.add(prdDimension3);
                    }
                    
                    //adding dimension 4
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension4  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Max_Flow_L_Min__c != null){
                        prdDimension4.name = 'Max Flow ltr/min';
                        prdDimension4.position = 3;
                        prdDimension4.visible = true;
                        prdDimension4.variation = false;
                        //prdDimension4.options.add(string.valueOf(prd.Max_Flow_L_Min__c));
                        product.attributes.add(prdDimension4);
                    }
                    
                    //adding dimension 5
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension5  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Min_Burst_Pressure_Male_PSI__c != null){
                        prdDimension5.name = 'Min Burst Pressure Male PSI';
                        prdDimension5.position = 4;
                        prdDimension5.visible = true;
                        prdDimension5.variation = false;
                        prdDimension5.options.add(string.valueOf(prd.Min_Burst_Pressure_Male_PSI__c));
                        product.attributes.add(prdDimension5);
                    }
                    
                    //adding dimension 6
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension6  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Min_Burst_Pressure_Female_PSI__c != null){
                        prdDimension6.name = 'Min Burst Pressure Female PSI';
                        prdDimension6.position = 5;
                        prdDimension6.visible = true;
                        prdDimension6.variation = false;
                        prdDimension6.options.add(string.valueOf(prd.Min_Burst_Pressure_Female_PSI__c));
                        product.attributes.add(prdDimension6);
                    }
                    
                    //adding dimension 7
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension7  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Min_Burst_Pressure_Coupled_PSI__c != null){
                        prdDimension7.name = 'Min Burst Pressure Coupled PSI';
                        prdDimension7.position = 6;
                        prdDimension7.visible = true;
                        prdDimension7.variation = false;
                        prdDimension7.options.add(string.valueOf(prd.Min_Burst_Pressure_Coupled_PSI__c));
                        product.attributes.add(prdDimension7);
                    }
                    
                    //adding dimension 8
                    Rest_WebSiteWrappers.productToWebsiteAttributes prdDimension8  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                    if(prd.Fluid_Spillage_cc__c != null){
                        prdDimension8.name = 'Fluid Splillage CC';
                        prdDimension8.position = 7;
                        prdDimension8.visible = true;
                        prdDimension8.variation = false;
                        prdDimension8.options.add(string.valueOf(prd.Fluid_Spillage_cc__c));
                        product.attributes.add(prdDimension8);
                    }
                }
                
                //Adding uncatagerized dimesions - need to decide category
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj1  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.Prefix_Thread_1_ID__c != null){
                	prdDimensionObj1.Name = 'Prefix/Thread 1 ID';
                    prdDimensionObj1.position = 1;
                    prdDimensionObj1.visible = true;
                    prdDimensionObj1.variation = false;
                    prdDimensionObj1.options.add(string.valueOf(prd.Prefix_Thread_1_ID__c));
                    product.attributes.add(prdDimensionObj1);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj2  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.Collated_Identifier__c != null){
                	prdDimensionObj2.Name = 'Collated Identifier';
                    prdDimensionObj2.position = 2;
                    prdDimensionObj2.visible = true;
                    prdDimensionObj2.variation = false;
                    prdDimensionObj2.options.add(string.valueOf(prd.Collated_Identifier__c));
                    product.attributes.add(prdDimensionObj2);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj3  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.Identifier_related_info_Thread_2_ID__c != null){
                	prdDimensionObj3.Name = 'Identifier/related info/Thread 2 ID';
                    prdDimensionObj3.position = 3;
                    prdDimensionObj3.visible = true;
                    prdDimensionObj3.variation = false;
                    prdDimensionObj3.options.add(string.valueOf(prd.Identifier_related_info_Thread_2_ID__c));
                    product.attributes.add(prdDimensionObj3);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj4  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.Thread_3_ID_SS_adaptor__c != null){
                	prdDimensionObj4.Name = 'Thread 3 ID/SS adaptor';
                    prdDimensionObj4.position = 4;
                    prdDimensionObj4.visible = true;
                    prdDimensionObj4.variation = false;
                    prdDimensionObj4.options.add(string.valueOf(prd.Thread_3_ID_SS_adaptor__c));
                    product.attributes.add(prdDimensionObj4);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj5  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.DKOL_DKOS__c != null){
                	prdDimensionObj5.Name = 'DKOL/DKOS';
                    prdDimensionObj5.position = 5;
                    prdDimensionObj5.visible = true;
                    prdDimensionObj5.variation = false;
                    prdDimensionObj5.options.add(string.valueOf(prd.DKOL_DKOS__c));
                    product.attributes.add(prdDimensionObj5);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj6  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.Thread_Color_Code__c != null){
                	prdDimensionObj6.Name = 'Thread Color Code';
                    prdDimensionObj6.position = 6;
                    prdDimensionObj6.visible = true;
                    prdDimensionObj6.variation = false;
                    prdDimensionObj6.options.add(string.valueOf(prd.Thread_Color_Code__c));
                    product.attributes.add(prdDimensionObj6);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj7  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.Male_Female_Flange_Fitting_Only__c != null){
                	prdDimensionObj7.Name = 'Male/Female/Flange (Fitting Only)';
                    prdDimensionObj7.position = 7;
                    prdDimensionObj7.visible = true;
                    prdDimensionObj7.variation = false;
                    prdDimensionObj7.options.add(string.valueOf(prd.Male_Female_Flange_Fitting_Only__c));
                    product.attributes.add(prdDimensionObj7);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj8  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.Suits_Hose__c != null){
                	prdDimensionObj8.Name = 'Suits Hose';
                    prdDimensionObj8.position = 8;
                    prdDimensionObj8.visible = true;
                    prdDimensionObj8.variation = false;
                    prdDimensionObj8.options.add(string.valueOf(prd.Suits_Hose__c));
                    product.attributes.add(prdDimensionObj8);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj9  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.LC_Length__c	 != null){
                	prdDimensionObj9.Name = 'LC (Length)';
                    prdDimensionObj9.position = 9;
                    prdDimensionObj9.visible = true;
                    prdDimensionObj9.variation = false;
                    prdDimensionObj9.options.add(string.valueOf(prd.LC_Length__c));
                    product.attributes.add(prdDimensionObj9);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj10  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.LD_Drop__c != null){
                	prdDimensionObj10.Name = 'LD (Drop)';
                    prdDimensionObj10.position = 10;
                    prdDimensionObj10.visible = true;
                    prdDimensionObj10.variation = false;
                    prdDimensionObj10.options.add(string.valueOf(prd.LD_Drop__c));
                    product.attributes.add(prdDimensionObj10);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj11  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.H1__c != null){
                	prdDimensionObj11.Name = 'H1';
                    prdDimensionObj11.position = 11;
                    prdDimensionObj11.visible = true;
                    prdDimensionObj11.variation = false;
                    prdDimensionObj11.options.add(string.valueOf(prd.H1__c));
                    product.attributes.add(prdDimensionObj11);
                }
                
                Rest_WebSiteWrappers.productToWebsiteAttributes prdDimensionObj12  = new Rest_WebSiteWrappers.productToWebsiteAttributes();
                if(prd.H2_Nut_Size__c != null){
                	prdDimensionObj12.Name = 'H2 (Nut Size)';
                    prdDimensionObj12.position = 12;
                    prdDimensionObj12.visible = true;
                    prdDimensionObj12.variation = false;
                    prdDimensionObj12.options.add(string.valueOf(prd.H2_Nut_Size__c));
                    product.attributes.add(prdDimensionObj12);
                }
                
                
                
                //assigning categories to product
                //primary group
                
                Rest_WebSiteWrappers.productToWebsiteCategories primaryGroup = new Rest_WebSiteWrappers.productToWebsiteCategories();
                primaryGroup.name = prd.Primary_Group__c; //primaryGroup.id = 35;//primaryGroup.slug = prd.Primary_Group_Display_Name__c;
                Product_Category_Information__c pri = Product_Category_Information__c.getValues(SFToExoIntegrationUtility.getPicklistLabel('product2','Primary_Group__c',prd.Primary_Group__c));  
				primaryGroup.id = pri.Category_Id__c;		
                product.categories.add(primaryGroup);
                //secondary Group
                Rest_WebSiteWrappers.productToWebsiteCategories secondaryGroup = new Rest_WebSiteWrappers.productToWebsiteCategories();
                if(prd.Secondary_Group_Display_Name__c != 'Workshop Machinery' && prd.Secondary_Group_Display_Name__c != null){
                    secondaryGroup.name = prd.Secondary_Group_Display_Name__c; //secondaryGroup.id = 39;//secondaryGroup.slug = prd.Secondary_Group_Display_Name__c;
                    List<Product_Category_Information__c> sec = [SELECT Name,Stock_Description__c,Category_Id__c FROM Product_Category_Information__c WHERE Stock_Description__c =:prd.Secondary_Group_Display_Name__c];//Product_Category_Information__c.getValues(prd.Secondary_Group_Display_Name__c);  
                    secondaryGroup.id = sec[0].Category_Id__c;
                    product.categories.add(secondaryGroup);
                }    
                //Tertiary Group
                Rest_WebSiteWrappers.productToWebsiteCategories TertiaryGroup = new Rest_WebSiteWrappers.productToWebsiteCategories();
                if(prd.Tertiary_Group_Display_Name__c != null){
                    TertiaryGroup.name = prd.Tertiary_Group_Display_Name__c; //TertiaryGroup.id = 54;//TertiaryGroup.slug = prd.Tertiary_Group_Display_Name__c;
                    //Product_Category_Information__c ter = Product_Category_Information__c.getValues(prd.Tertiary_Group_Display_Name__c);//SFToExoIntegrationUtility.getPicklistLabel('product2','Tertiary_Group__c',prd.Tertiary_Group__c));  
                    List<Product_Category_Information__c> ter = [SELECT Name,Stock_Description__c,Category_Id__c FROM Product_Category_Information__c WHERE Stock_Description__c =:prd.Tertiary_Group_Display_Name__c];
                    TertiaryGroup.id = ter[0].Category_Id__c;
                    product.categories.add(TertiaryGroup); 
                }
                //Fourth Group - Product Family
                Rest_WebSiteWrappers.productToWebsiteCategories productFamily = new Rest_WebSiteWrappers.productToWebsiteCategories();
                if(prd.Product_Family__c != null){
                    productFamily.name = prd.Product_Family_Display_Name__c; //productFamily.id = 268;//productFamily.slug = prd.Product_Family__c;
                    //Product_Category_Information__c fam = Product_Category_Information__c.getValues(prd.Product_Family_Display_Name__c);  
                    List<Product_Category_Information__c> fam = [SELECT Name,Stock_Description__c,Category_Id__c FROM Product_Category_Information__c WHERE Stock_Description__c =:prd.Product_Family_Display_Name__c];
                    productFamily.id = fam[0].Category_Id__c;
                    product.categories.add(productFamily);
                }
                //assigning images of product
                //image 1
                if(string.isNotBlank(prd.Stock_Image_1__c)){
                	Rest_WebSiteWrappers.productToWebsiteImages stockImage1 = new Rest_WebSiteWrappers.productToWebsiteImages();
                	stockImage1.src = prd.Stock_Image_1__c; stockimage1.alt = '';
                	stockImage1.name = 'Image 1'; stockImage1.position = 0;
                	product.images.add(stockImage1);
                }
                //image 2
                if(string.isNotBlank(prd.Stock_Image_2__c)){
                	Rest_WebSiteWrappers.productToWebsiteImages stockImage2 = new Rest_WebSiteWrappers.productToWebsiteImages();
                	stockImage2.src = prd.Stock_Image_2__c; stockimage2.alt = '';
                	stockImage2.name = 'Image 2'; stockImage2.position = 1;
                	product.images.add(stockImage2);
                }
                //image 3
                if(string.isNotBlank(prd.Stock_Image_3__c)){
                	Rest_WebSiteWrappers.productToWebsiteImages stockImage3 = new Rest_WebSiteWrappers.productToWebsiteImages();
                	stockImage3.src = prd.Stock_Image_3__c; stockimage3.alt = '';
                	stockImage3.name = 'Image 3'; stockImage3.position = 2;
                	product.images.add(stockImage3);
                }
                
                //adding product to list
                productList.add(product);
                 
        }
             if(!productList.isEmpty()){
               	 system.debug('product string--'+json.serialize(productList));
                 Rest_webPortalWrappers.genericOutboundResponseWrapper response = Rest_outboundCaller.postHttpCreateProductTowebSite(json.serialize(productList[0]),productList[0].WordPress_Id);
                 system.debug('response--'+response);
             }   
             
         }      
        catch(Exception e){
            errorLogController.createErrorLog(e.getTypeName(),e.getMessage(),'Rest_WebSiteOutboundHandler.sendProductDetailsToPublicSite',e.getLineNumber());     
        }        
        
     }
    
}