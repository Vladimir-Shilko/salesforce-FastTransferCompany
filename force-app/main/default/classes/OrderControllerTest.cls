@isTest
public class OrderControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test user with Sales Manager profile
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' LIMIT 1];
        UserRole srole = [SELECT Id from UserRole Where DeveloperName = 'CEO' LIMIT 1];
        User salesManager = new User(
            Username = 'salesmanagerrr@test.com',
            FirstName = 'Sales',
            LastName = 'Managerrr',
            Email = 'salesmanagerrr@test.com',
            Alias = 'sman',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US',
            UserRoleId = srole.Id
        );
        insert salesManager;

        // Create Account and Order
        Account testAccount = new Account(Name = 'Test Account' , Email__c = 'contacttt@test.com');
        System.runAs(salesManager){
            insert testAccount;
        }
		Profile profilePortal  = [SELECT Id FROM Profile WHERE Name = 'FasTTransfer Client' LIMIT 1];
        System.debug('profile portal: '+profilePortal);
        Contact shipToContact = new Contact(
            FirstName = 'Joe',
            LastName = 'ShipTo',
            AccountId = testAccount.Id
        );
         System.runAs(salesManager){
             insert shipToContact;}
		UserRole role = [SELECT Id from UserRole Where DeveloperName = 'CEO' LIMIT 1];
        User clientUser = new User(
            Username = 'clientuserrr@test.com',
            FirstName = 'Client',
            LastName = 'Userrr',
            Email = 'clientuserrr@test.com',
            Alias = 'clientu',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            
            LanguageLocaleKey = 'en_US',           
            ContactId = shipToContact.Id,
            //UserRoleId = role.Id,
            ProfileId = profilePortal.Id
        );
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];

		User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];

		
		//update adminUser;

		//System.runAs(salesManager){
        //System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
    		insert clientUser;
		//}


       

        // Create related Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1)
        );
        System.runAs(salesManager){
            insert testOpp;}
		 Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            ShipToContactId = shipToContact.Id,
            OpportunityId = testOpp.Id,
             Status = 'New'
        );
        System.runAs(salesManager){
            insert testOrder;}
        // Create Offers
        Contact shippingOwnerContact = new Contact(
            FirstName = 'Shipper',
            LastName = 'Owner',
            AccountId = testAccount.Id
        );
        System.runAs(salesManager){
            insert shippingOwnerContact;}
		Profile profilePartner  = [SELECT Id FROM Profile WHERE Name = 'FasTTransfer Partner' LIMIT 1];
        System.debug('partner profile: '+profilePartner);
        User shippingCompanyUser = new User(
            Username = 'shippingownerrr@test.com',
            FirstName = 'Shipper',
            LastName = 'Ownerrr',
            Email = 'shippingownerrr@test.com',
            Alias = 'shipown',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = shippingOwnerContact.Id,
            ProfileId = profilePartner.Id
        );
        System.runAs(new User(Id = UserInfo.getUserId())){
           insert shippingCompanyUser;
        }
        Offer__c offer1 = new Offer__c(
            Name = 'Offer 1',
            Max_Price__c = 1000,
            Min_Price__c = 800,
            Closed_Date__c = Date.today(),
            Status__c = 'New',
            Order__c = testOrder.Id,
            
            Special_Terms__c = 'Term 1',
            Shipping_Company_Owner__c = shippingCompanyUser.Id
        );
        System.runAs(new User(Id = UserInfo.getUserId())){
           insert offer1;
        }

        Offer__c offer2 = new Offer__c(
            Name = 'Offer 2',
            Max_Price__c = 1200,
            Min_Price__c = 900,
            Closed_Date__c = Date.today().addDays(10),
            Status__c = 'New',
            Order__c = testOrder.Id,
            Special_Terms__c = 'Term 2',
            Shipping_Company_Owner__c = shippingCompanyUser.Id
        );
        System.runAs(new User(Id = UserInfo.getUserId())){
           insert offer2;
        }
    }

    @isTest
    static void testGetRelatedOffers() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Order order = [SELECT Id FROM Order WHERE AccountId = :acc.Id LIMIT 1];

        Test.startTest();
        List<Offer__c> offers = OrderController.getRelatedOffers(order.Id);
        Test.stopTest();

        System.assertEquals(2, offers.size(), 'The number of related offers should be 2');
        for (Offer__c off : offers) {
            System.assertEquals('New', off.Status__c, 'Offer should have status "New"');
        }
    }

    @isTest
    static void testCreateContract() {
        User u = [SELECT Id FROM User WHERE Username = 'salesmanagerrr@test.com'];
        
        List<Offer__c> offers = [SELECT Id FROM Offer__c WHERE Name = 'Offer 1' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Order ord = [SELECT Id, OpportunityId FROM Order WHERE AccountId = :acc.Id LIMIT 1];
        
        Test.startTest();
        OrderController.createContract(offers[0].Id, ord.Id);
        Test.stopTest();

        Contract newContract = [SELECT Id, Status, SpecialTerms, CustomerSignedDate, Price__c, User__c, Order__c, Shipping_CompanyUser__c
                                FROM Contract WHERE Order__c = :ord.Id LIMIT 1];

        System.assertNotEquals(null, newContract, 'Contract should be created');
        System.assertEquals('Draft', newContract.Status, 'Contract status should be Draft');
        System.assertEquals((1000 + 800) / 2, newContract.Price__c, 'Contract price should be average of Max and Min Price');
        
        Offer__c selectedOffer = [SELECT Id, Status__c FROM Offer__c WHERE Id = :offers[0].Id LIMIT 1];
        System.assertEquals('Winner', selectedOffer.Status__c, 'Selected offer should be marked as Winner');

        List<Offer__c> loserOffers = [SELECT Id, Status__c FROM Offer__c WHERE Id != :offers[0].Id AND Order__c = :ord.Id];
        for (Offer__c loser : loserOffers) {
            System.assertEquals('Loser', loser.Status__c, 'Non-selected offers should be marked as Loser');
        }

        Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :ord.OpportunityId LIMIT 1];
        System.assertEquals('Price Quote', opp.StageName, 'Opportunity stage should be updated to Price Quote');
    }
}