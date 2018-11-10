@isTest
public class Test_RestwebSiteOutboundHandler {
	
    public static testMethod void unitTest(){
        
        web_site_creds__c cred = new web_site_creds__c();
        cred.Name = 'products';
        cred.consumer_key__c = 'ck_9eed31a9207af474c8b64c9dddfd5c0de1ec06f1';
        cred.consumer_secret__c = 'cs_6af3ecb6246a155804f3e8d6c7eb45755eeef7a2';
        cred.endpoint__c = 'https://test.boa.co.nz/wp-json/wc/v2/products';
        insert cred;    
        
        Product_Category_Information__c pci = new Product_Category_Information__c();
        pci.Name = 'Adaptors';
        pci.Category_Id__c = '11';
        pci.Stock_Description__c = 'Adaptors';
        
        insert pci;
        
        Product_Category_Information__c pci1 = new Product_Category_Information__c();
        pci1.Name = 'Straight Adaptors';
        pci1.Category_Id__c = '12';
        pci1.Stock_Description__c = 'Straight Adaptors';
        
        insert pci1;
        
        Product_Category_Information__c pci2 = new Product_Category_Information__c();
        pci2.Name = 'AA - BSPT MALE X BSPT MALE';
        pci2.Category_Id__c = '13';
        pci2.Stock_Description__c = 'AA - BSPT MALE X BSPT MALE';
        
        insert pci2;
        
        Product_Category_Information__c pci3 = new Product_Category_Information__c();
        pci3.Name = 'Sales - Hydraulic Fittings';
        pci3.Category_Id__c = '14';
        pci3.Stock_Description__c = 'Sales - Hydraulic Fittings';
        
        insert pci3;
        
        product2 p = new Product2();
        p.Name = 'Test Product';
        p.QuantityUnitOfMeasure__c = 'Each';
        p.is_Hydraulic_Product__c = true;
        p.Bill_of_Material__c = false;
        p.IsActive = true;
        p.Show_on_Website__c = true;
        p.WordPress_Id__c = '12345';
        p.Primary_Group__c = '1110-10';
        p.Secondary_Group__c = '15';
        p.Secondary_Group_Display_Name__c = 'Adaptors';
        p.Tertiary_Group__c = '320';
        p.Tertiary_Group_Display_Name__c = 'Straight Adaptors';
        p.Product_Family__c = 'AA';
        p.Product_Family_Display_Name__c = 'AA - BSPT MALE X BSPT MALE';
        p.nominal_thread_size_1__c = '1';
        p.nominal_thread_size_2__c = '2';
        p.nominal_thread_size_3__c = '3';
        p.nominal_thread_size_4__c = '4';
        p.Physical_Thread_Size_1__c = '1';
        p.Physical_Thread_Size_2__c = '2';
        p.Physical_Thread_Size_3__c = '3';
        p.Physical_Thread_Size_4__c = '4'; 
        p.Thread_Type_1__c = '1';
        p.Thread_Type_2__c = '2';
        p.Thread_Type_3__c = '3';
        p.Thread_Type_4__c = '4';
        p.Orientation__c = '45';
        p.Tail_Size_To_Suit_Hose_ID__c = '11';
        p.Nominal_Pipe_Size__c = '1/4';
        p.Thread_Type_Filter_1__c = '1';
        p.Thread_Type_Filter_2__c = '2'; 
        p.Stock_Image_1__c = 'Image 1';
        p.Stock_Image_2__c = 'Image 2';
        p.Stock_Image_3__c = 'Image 3'; 
        
        p.Prefix_Thread_1_ID__c = '1';
        p.Collated_Identifier__c = '2';
        p.Identifier_related_info_Thread_2_ID__c = '3';
        p.Thread_3_ID_SS_adaptor__c = '4';
        p.DKOL_DKOS__c = '5';
        p.Thread_Color_Code__c = '6';
        p.Male_Female_Flange_Fitting_Only__c = '7';
        p.Suits_Hose__c = '8';
        p.LC_Length__c = '9';
        p.LD_Drop__c = '10';
        p.H1__c = '11';
        p.H2_Nut_Size__c = '12';
            
        insert p;
    
    List<Id> stockList = new List<Id>();
    stockList.add(p.Id); 
        //Test.setMock(HttpCalloutMock.class, new MockCallOutATTCallouts());
        
    Rest_websiteOutboundHandler.sendProductDetailsToPublicSite(stockList);
        
    }
    
    public static testMethod void unitTest1(){
    	
        web_site_creds__c cred = new web_site_creds__c();
        cred.Name = 'products';
        cred.consumer_key__c = 'ck_9eed31a9207af474c8b64c9dddfd5c0de1ec06f1';
        cred.consumer_secret__c = 'cs_6af3ecb6246a155804f3e8d6c7eb45755eeef7a2';
        cred.endpoint__c = 'https://test.boa.co.nz/wp-json/wc/v2/products';
        insert cred;  
        
        Product_Category_Information__c pci = new Product_Category_Information__c();
        pci.Name = 'Hose';
        pci.Category_Id__c = '11';
        pci.Stock_Description__c = 'Hose';
        
        insert pci;
        
        Product_Category_Information__c pci1 = new Product_Category_Information__c();
        pci1.Name = 'Hydraulic Hose';
        pci1.Category_Id__c = '12';
        pci1.Stock_Description__c = 'Hydraulic Hose';
        
        insert pci1;
        
        Product_Category_Information__c pci2 = new Product_Category_Information__c();
        pci2.Name = 'SF1SN';
        pci2.Category_Id__c = '13';
        pci2.Stock_Description__c = 'SF1SN - SILFLO 1SN/1AT 1-WIRE HYDRAULIC HOSE';
        
        insert pci2;
        
        Product_Category_Information__c pci3 = new Product_Category_Information__c();
        pci3.Name = 'Sales - Hydraulic Hose';
        pci3.Category_Id__c = '14';
        pci3.Stock_Description__c = 'Sales - Hydraulic Hose';
        
        insert pci3;
        
        product2 p = new Product2();
        p.Name = 'Test Product';
        p.QuantityUnitOfMeasure__c = 'Each';
        p.is_Hydraulic_Product__c = true;
        p.Bill_of_Material__c = false;
        p.IsActive = true;
        p.Show_on_Website__c = true;
        p.WordPress_Id__c = '';
        p.Primary_Group__c = '1110-11';
        p.Secondary_Group__c = '2';
        p.Secondary_Group_Display_Name__c = 'Hose';
        p.Tertiary_Group__c = '48';
        p.Tertiary_Group_Display_Name__c = 'Hydraulic Hose';
        p.Product_Family__c = 'SF1SN';
        p.Product_Family_Display_Name__c = 'SF1SN - SILFLO 1SN/1AT 1-WIRE HYDRAULIC HOSE';
        p.Hose_Inner_Diameter_Inches__c = '1';
        p.Hose_Inner_Diameter_mm__c = 2;
        p.Working_Pressure_PSI__c = 3;
        p.Hose_Outer_Diameter_mm__c = 4;
        p.Working_Pressure_BAR__c = 1;
        p.Minimum_Bend_Radius_mm__c = 2;
        p.Full_Coil_Size_metre__c = '3';
        p.Dash_Size_1__c = '4'; 
        p.Dash_Size_2__c = '1';
        p.Dash_Size_3__c = '2';
        p.Dash_Size_4__c = '3';         
        p.Stock_Image_1__c = 'Image 1';
        p.Stock_Image_2__c = 'Image 2';
        p.Stock_Image_3__c = 'Image 3';    
        insert p;
    
    List<Id> stockList = new List<Id>();
    stockList.add(p.Id);    
    Rest_websiteOutboundHandler.sendProductDetailsToPublicSite(stockList);
        //Test.setMock(HttpCalloutMock.class, new MockCallOutATTCallouts());
    }
    
    public static testMethod void unitTest2(){
    	
        Product_Category_Information__c pci = new Product_Category_Information__c();
        pci.Name = 'Fittings - HYD';
        pci.Category_Id__c = '11';
        pci.Stock_Description__c = 'Swage Hose Tails';
        
        insert pci;
        
        Product_Category_Information__c pci1 = new Product_Category_Information__c();
        pci1.Name = 'HOSE TAILS - HYD';
        pci1.Category_Id__c = '12';
        pci1.Stock_Description__c = 'S-Series 2-Piece Swage Fittings';
        
        insert pci1;
        
        Product_Category_Information__c pci2 = new Product_Category_Information__c();
        pci2.Name = 'WHP';
        pci2.Category_Id__c = '13';
        pci2.Stock_Description__c = 'WHP - CODE 62 (SAE) FLANGE CLAMP';
        
        insert pci2;
        
        Product_Category_Information__c pci3 = new Product_Category_Information__c();
        pci3.Name = 'Sales - Hydraulic Fittings';
        pci3.Category_Id__c = '14';
        pci3.Stock_Description__c = 'Sales - Hydraulic Fittings';
        
        insert pci3;
        
        product2 p = new Product2();
        p.Name = 'Test Product';
        p.QuantityUnitOfMeasure__c = 'Each';
        p.is_Hydraulic_Product__c = true;
        p.Bill_of_Material__c = false;
        p.IsActive = true;
        p.Show_on_Website__c = true;
        p.WordPress_Id__c = '12345';
        p.Primary_Group__c = '1110-10';
        p.Secondary_Group__c = '17';
        p.Secondary_Group_Display_Name__c = 'Swage Hose Tails';
        p.Tertiary_Group__c = '130';
        p.Tertiary_Group_Display_Name__c = 'Hydraulic Hose';
        p.Product_Family__c = 'WHP';
        p.Product_Family_Display_Name__c = 'S-Series 2-Piece Swage Fittings';
        p.b_in__c = '111';
        p.d_in__c = '222';
        p.e_in__c = '333';
        p.h_in__c = '444';
        p.l_in__c = '555';
        p.m_in__c = '666';
                 
        p.Stock_Image_1__c = 'Image 1';
        p.Stock_Image_2__c = 'Image 2';
        p.Stock_Image_3__c = 'Image 3';    
        insert p;
    
    List<Id> stockList = new List<Id>();
    stockList.add(p.Id);    
    Rest_websiteOutboundHandler.sendProductDetailsToPublicSite(stockList);
    }
    
    public static testMethod void unitTest3(){
    	
        Product_Category_Information__c pci = new Product_Category_Information__c();
        pci.Name = 'Quick Release Couplers';
        pci.Category_Id__c = '11';
        pci.Stock_Description__c = 'Quick Release Couplers';
        
        insert pci;
        
        Product_Category_Information__c pci1 = new Product_Category_Information__c();
        pci1.Name = 'QRC';
        pci1.Category_Id__c = '12';
        pci1.Stock_Description__c = 'QRC';
        
        insert pci1;
        
        Product_Category_Information__c pci2 = new Product_Category_Information__c();
        pci2.Name = 'PAV1 - QRC POPPET (ISO A)';
        pci2.Category_Id__c = '13';
        pci2.Stock_Description__c = 'PAV1 - QRC POPPET (ISO A)';
        
        insert pci2;
        
        Product_Category_Information__c pci3 = new Product_Category_Information__c();
        pci3.Name = 'Sales - Hydraulic Fittings';
        pci3.Category_Id__c = '14';
        pci3.Stock_Description__c = 'Sales - Hydraulic Fittings';
        
        insert pci3;
        
        product2 p = new Product2();
        p.Name = 'Test Product';
        p.QuantityUnitOfMeasure__c = 'Each';
        p.is_Hydraulic_Product__c = true;
        p.Bill_of_Material__c = false;
        p.IsActive = true;
        p.Show_on_Website__c = true;
        p.WordPress_Id__c = '12345';
        p.Primary_Group__c = '1110-10';
        p.Secondary_Group__c = '20';
        p.Secondary_Group_Display_Name__c = 'Quick Release Couplers';
        p.Tertiary_Group__c = '280';
        p.Tertiary_Group_Display_Name__c = 'QRC';
        p.Product_Family__c = 'PAV1';
        p.Product_Family_Display_Name__c = 'PAV1 - QRC POPPET (ISO A)';
        p.Nominal_Size_mm__c = 1;
        p.Rated_Flow_L_min__c = 2;
        p.Max_Work_Pressure_PSI__c = 3;
        p.Max_Flow_L_Min__c = 4;
        p.Min_Burst_Pressure_Male_PSI__c = 1;
        p.Min_Burst_Pressure_Female_PSI__c = 2;
        p.Min_Burst_Pressure_Coupled_PSI__c = 3;
        p.Fluid_Spillage_cc__c = 1;
           
        p.Stock_Image_1__c = 'Image 1';
        p.Stock_Image_2__c = 'Image 2';
        p.Stock_Image_3__c = 'Image 3';    
        insert p;
    
    List<Id> stockList = new List<Id>();
    stockList.add(p.Id);    
    Rest_websiteOutboundHandler.sendProductDetailsToPublicSite(stockList);
    }
}